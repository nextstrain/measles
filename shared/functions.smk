import os.path

def resolve_config_path(path):
    """
    Resolve a relative *path* given in a configuration value.

    Resolves *path* as relative to the workflow's ``defaults/`` directory (i.e.
    ``os.path.join(workflow.basedir, "defaults", path)``) if it doesn't exist
    in the workflow's analysis directory (i.e. the current working
    directory, or workdir, usually given by ``--directory`` (``-d``)).

    This behaviour allows a default configuration value to point to a default
    auxiliary file while also letting the file used be overridden either by
    setting an alternate file path in the configuration or by creating a file
    with the conventional name in the workflow's analysis directory.
    """
    global workflow

    if not os.path.exists(path):
        # Special-case defaults/… for backwards compatibility with older
        # configs.  We could achieve the same behaviour with a symlink
        # (defaults/defaults → .) but that seems less clear.
        if path.startswith("defaults/"):
            defaults_path = os.path.join(workflow.basedir, path)
        else:
            defaults_path = os.path.join(workflow.basedir, "defaults", path)

        if os.path.exists(defaults_path):
            return defaults_path

    return path
