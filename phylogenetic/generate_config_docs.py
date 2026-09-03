#!/usr/bin/env python3
"""Automatically generate Markdown configuration documentation from config.schema.yaml and config/configfile.yaml."""

import argparse
import json
import sys
import urllib.request
from pathlib import Path
import yaml
from augur.validate import load_json_schema_locally

# Cache for resolved/fetched remote and local schemas keyed by URI/URL
_schema_cache = {}


def fetch_schema(url):
    """Fetch and cache a remote JSON/YAML schema referenced by an absolute $ref URL."""
    # Check if the schema has already been cached
    if url not in _schema_cache:
        # Fall back to fetching over network if not preloaded in cache
        with urllib.request.urlopen(url) as response:
            _schema_cache[url] = yaml.safe_load(response.read())
    return _schema_cache[url]


def format_default(val):
    """Format a default value into a Markdown table cell string."""
    # Handle missing or null default values
    if val is None or val == "-":
        return "-"

    # Format dictionary values: summarize multiple entries or render inline JSON
    if isinstance(val, dict):
        if len(val) > 1:
            return f"({len(val)} entries)"
        return f"`{json.dumps(val)}`"

    # Format list values: summarize complex objects or render inline JSON
    if isinstance(val, list):
        if len(val) > 1 and any(isinstance(x, dict) for x in val):
            return f"({len(val)} items)"
        return f"`{json.dumps(val)}`"

    # Format booleans as lowercase code markdown
    if isinstance(val, bool):
        return "`true`" if val else "`false`"

    # Format numeric and string scalars
    if isinstance(val, (int, float, str)):
        return f"`{val}`"

    return f"`{val}`"


def resolve_ref(spec, defs):
    """Resolve $ref pointer against $defs, following remote (http/https) refs.

    Returns (resolved_spec, ref_name, defs), where defs are the $defs that
    apply to resolved_spec (a remote ref's own $defs, since local #/$defs/...
    pointers inside a remote schema must resolve against that schema).
    """
    if isinstance(spec, dict) and "$ref" in spec:
        ref = spec["$ref"]
        ref_name = ref.split("/")[-1]

        # Follow remote HTTP/HTTPS reference URLs
        if ref.startswith("http://") or ref.startswith("https://"):
            remote = fetch_schema(ref)
            return remote, ref_name, remote.get("$defs", {})

        # Resolve local #/$defs/... pointers against provided defs
        return defs.get(ref_name, spec), ref_name, defs

    return spec, None, defs


def format_type(spec, defs):
    """Format the type specification of a schema property for documentation."""
    is_remote = isinstance(spec, dict) and str(spec.get("$ref", "")).startswith(("http://", "https://"))
    # Resolve any references before inspecting the type
    spec, ref_name, defs = resolve_ref(spec, defs)

    t = spec.get("type")

    # Format array types and link item definitions if applicable
    if t == "array":
        items = spec.get("items", {})
        items, item_ref, _ = resolve_ref(items, defs)
        if item_ref:
            return f"list[[{item_ref}](#{item_ref.lower()})]"
        return f"list[{items.get('type', 'string')}]"

    # Format union types specified as a list
    if isinstance(t, list):
        return " \\| ".join(t)

    # Format enum values as quoted choices
    if "enum" in spec:
        return " \\| ".join([f'"{e}"' for e in spec["enum"]])

    # Format anyOf branches
    if "anyOf" in spec:
        types = []
        for a in spec["anyOf"]:
            at = a.get("type")
            if at == "array":
                it = a.get("items", {}).get("type", "string")
                types.append(f"list[{it}]")
            elif at:
                types.append(at)
        return " \\| ".join(types) if types else "any"

    # Format named references with markdown links for local schemas
    if ref_name:
        # Remote refs don't have a matching heading anchor in this document.
        return ref_name if is_remote else f"[{ref_name}](#{ref_name.lower()})"

    return str(t or "object")


def get_placeholder(child_dict):
    """Extract dynamic key placeholder directly from the schema description."""
    desc = child_dict.get("description", "").strip()
    if desc.startswith("<") and desc.endswith(">"):
        return desc
    return f"<{desc}>" if desc else "<key>"


def merge_all_of(spec, defs):
    """Merge allOf branches (e.g. base schema $ref combined with constraints)."""
    branches = spec.get("allOf")
    if not branches:
        return None

    merged_properties = {}
    combined_defs = dict(defs)
    description = spec.get("description", "")

    for branch in branches:
        # Resolve any reference on the branch
        branch_spec, _, branch_defs = resolve_ref(branch, combined_defs)
        combined_defs.update(branch_defs)

        # Inherit description if not already set
        if not description and branch_spec.get("description"):
            description = branch_spec.get("description", "")

        # Recursively merge nested allOf or oneOf/anyOf within the branch
        sub_all = merge_all_of(branch_spec, combined_defs)
        if sub_all is not None:
            branch_spec, combined_defs = sub_all
        sub_one = merge_one_of(branch_spec, combined_defs)
        if sub_one is not None:
            branch_spec = sub_one

        # Merge branch properties and apply negative constraints
        for name, child in branch_spec.get("properties", {}).items():
            # False or {"not": {}} indicates a forbidden property to exclude
            if child is False or (isinstance(child, dict) and child.get("not") == {}):
                merged_properties.pop(name, None)
            else:
                # Merge with existing property attributes or assign new property
                if name in merged_properties and isinstance(child, dict) and isinstance(merged_properties[name], dict):
                    merged_child = dict(merged_properties[name])
                    merged_child.update(child)
                    merged_properties[name] = merged_child
                else:
                    merged_properties[name] = child

    if not merged_properties:
        return None

    return {
        "type": "object",
        "properties": merged_properties,
        "description": description,
    }, combined_defs


def merge_one_of(spec, defs):
    """Merge oneOf/anyOf branches (each usually a $ref) into a single pseudo-container.

    Not all merged properties apply to every branch; this trades that precision
    for a single readable table instead of one per branch.
    """
    branches = spec.get("oneOf") or spec.get("anyOf")
    if not branches:
        return None

    merged_properties = {}
    branch_names = []

    # Resolve and aggregate properties across all variant branches
    for branch in branches:
        branch_spec, branch_ref_name, branch_defs = resolve_ref(branch, defs)
        branch_names.append(branch_ref_name or "object")
        for name, child in branch_spec.get("properties", {}).items():
            merged_properties.setdefault(name, child)

    if not merged_properties:
        return None

    note = f"One of: {', '.join(branch_names)}. Not all properties below apply to every variant."
    description = spec.get("description", "")
    return {
        "type": "object",
        "properties": merged_properties,
        "description": f"{description}\n\n{note}" if description else note,
    }


def get_container_spec(spec, defs):
    """Identify if a specification represents a nested container object/array."""
    # Resolve top-level reference and composition constructs
    spec, _, defs = resolve_ref(spec, defs)
    merged_all = merge_all_of(spec, defs)
    if merged_all is not None:
        spec, defs = merged_all
    merged_one = merge_one_of(spec, defs)
    if merged_one is not None:
        spec = merged_one

    # Direct object specification with properties
    if "properties" in spec:
        return spec, "", defs

    # Dynamic map with additionalProperties
    if "additionalProperties" in spec and isinstance(spec["additionalProperties"], dict):
        child, _, child_defs = resolve_ref(spec["additionalProperties"], defs)
        merged_all_child = merge_all_of(child, child_defs)
        if merged_all_child is not None:
            child, child_defs = merged_all_child
        merged_one_child = merge_one_of(child, child_defs)
        if merged_one_child is not None:
            child = merged_one_child
        if "properties" in child or "additionalProperties" in child:
            placeholder = get_placeholder(spec["additionalProperties"])
            return child, f".{placeholder}", child_defs

    # Dynamic map with patternProperties
    if "patternProperties" in spec:
        for pat, p_spec in spec["patternProperties"].items():
            child, _, child_defs = resolve_ref(p_spec, defs)
            merged_all_child = merge_all_of(child, child_defs)
            if merged_all_child is not None:
                child, child_defs = merged_all_child
            merged_one_child = merge_one_of(child, child_defs)
            if merged_one_child is not None:
                child = merged_one_child
            if "properties" in child or "additionalProperties" in child:
                placeholder = get_placeholder(p_spec)
                return child, f".{placeholder}", child_defs

    # Array of objects with items specification
    if "items" in spec and isinstance(spec["items"], dict):
        child, _, child_defs = resolve_ref(spec["items"], defs)
        merged_all_child = merge_all_of(child, child_defs)
        if merged_all_child is not None:
            child, child_defs = merged_all_child
        merged_one_child = merge_one_of(child, child_defs)
        if merged_one_child is not None:
            child = merged_one_child
        if "properties" in child:
            return child, "[]", child_defs

    return None, None, defs


def generate_docs(schema, defaults):
    """Traverse schema and defaults to produce markdown documentation."""
    defs = schema.get("$defs", {})
    sections = []

    def traverse(path_prefix, spec, defs, depth=2, current_defaults=None, parent_desc=""):
        # Resolve references and merge composite schemas
        spec, _, defs = resolve_ref(spec, defs)
        merged_all = merge_all_of(spec, defs)
        if merged_all is not None:
            spec, defs = merged_all
        merged_one = merge_one_of(spec, defs)
        if merged_one is not None:
            spec = merged_one

        props = spec.get("properties", {})
        if not props:
            return

        scalars = []
        nested = []

        # Iterate over all properties in alphabetical order
        for name, child in sorted(props.items()):
            full_path = f"{path_prefix}.{name}" if path_prefix else name

            # Determine default: check provided config defaults, then schema default, then resolved ref default
            child_default = "-"
            if isinstance(current_defaults, dict) and name in current_defaults:
                child_default = current_defaults[name]
            elif isinstance(child, dict) and "default" in child:
                child_default = child["default"]
            else:
                resolved_child, _, _ = resolve_ref(child, defs)
                if isinstance(resolved_child, dict) and "default" in resolved_child:
                    child_default = resolved_child["default"]

            # Check if property represents a nested container or leaf scalar
            container_spec, sub_path, child_defs = get_container_spec(child, defs)

            if container_spec is not None:
                # Queue nested container for recursive traversal
                nested.append((full_path + sub_path, child, container_spec, child_defs, child_default))
            else:
                # Format scalar row for current section table
                p_type = format_type(child, defs)
                p_desc = child.get("description", "-").replace("\n", " ")
                p_def = format_default(child_default)
                scalars.append((full_path, p_type, p_def, p_desc))

        # Add section for scalar properties at this level if present
        if scalars:
            heading = f"{'#' * depth} `{path_prefix}`" if path_prefix else f"{'#' * depth} Top-Level Settings"
            desc = parent_desc or spec.get("description", "")
            sections.append((heading, desc, scalars))

        # Recursively process nested containers
        for nested_path, orig_child, container_spec, child_defs, nested_default in nested:
            child_desc = orig_child.get("description", container_spec.get("description", ""))
            traverse(nested_path, container_spec, child_defs, depth=min(depth + 1, 6), current_defaults=nested_default, parent_desc=child_desc)

    # Start traversal from root schema
    traverse("", schema, defs, depth=2, current_defaults=defaults)

    # Build final Markdown document
    lines = [
        "<!-- [DO NOT EDIT] This file was automatically generated. -->",
        "# Configuration Reference",
        "",
        "This reference is automatically generated.",
        "",
    ]

    for heading, desc, rows in sections:
        lines.append(heading)
        lines.append("")
        if desc:
            lines.append(f"{desc.strip()}\n")
        lines.append("| Parameter Path | Type | Default | Description |")
        lines.append("| :--- | :--- | :--- | :--- |")
        for p, t, d, descr in rows:
            lines.append(f"| `{p}` | `{t}` | {d} | {descr} |")
        lines.append("")

    return "\n".join(lines)


def main():
    """Main CLI entrypoint to load schema, defaults, and output markdown docs."""
    # Set up command line argument parsing
    parser = argparse.ArgumentParser(
        description="Generate Markdown documentation from JSON/YAML schema and defaults."
    )
    parser.add_argument("schema", type=Path, help="Path to config schema (e.g. config.schema.yaml)")
    parser.add_argument("config", type=Path, help="Path to config file (e.g. config/configfile.yaml)")
    args = parser.parse_args()

    # Load and validate schema locally using Augur's validator
    validator = load_json_schema_locally(args.schema.resolve())
    schema = validator.schema

    # Pre-populate local schema cache from validator registry
    if hasattr(validator, "_registry"):
        for uri in validator._registry.crawl():
            try:
                _schema_cache[uri] = validator._registry[uri].contents
            except Exception:
                pass

    # Load default configuration values from YAML
    with open(args.config, "r") as f:
        defaults = yaml.safe_load(f)

    # Generate and print documentation
    output = generate_docs(schema, defaults)
    print(output)


if __name__ == "__main__":
    main()
