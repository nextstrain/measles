"""
Helper functions to set-up storage plugins for remote inputs/outputs. See the
docstring of `path_or_url` for usage instructions.

The errors raised by storage plugins are often confusing. For instance, a HTTP
404 error will result in a `MissingInputException` with little hint as to the
underlying issue. S3 credentials errors are similarly confusing and we attempt
to check these ourselves to improve UX here.
"""

import os
from urllib.parse import urlparse
from snakemake.io import get_flag_value, AnnotatedString

# Keep a list of known public buckets, which we'll allow uncredentialled (unsigned) access to
# We could make this config-definable in the future
PUBLIC_BUCKETS = set(['nextstrain-data'])

# Keep track of registered storage plugins to enable reuse
_storage_registry = {}

class RemoteFilesMissingCredentials(Exception):
    pass

def _storage_s3(*, bucket, keep_local, retries) -> snakemake.storage.StorageProviderProxy:
    """
    Registers and returns an instance of snakemake-storage-plugin-s3. Typically AWS
    credentials are required for _any_ request however we allow requests to known
    public buckets (see `PUBLIC_BUCKETS`) to be unsigned which allows for a nice user
    experience in the common case of downloading inputs from s3://nextstrain-data.

    The intended behaviour for various (S3) URIs supplied to `path_or_url` is:

    |          | S3 buckets                 | credentials present | credentials missing |
    |----------|----------------------------|---------------------|---------------------|
    | download | private / private + public | signed              | Credentials Error   |
    |          | public                     | signed              | unsigned            |
    | upload   | private / private + public | signed              | Credentials Error   |
    |          | public                     | signed              | AccessDenied Error  |
    """
    # If the bucket is public then we may use an unsigned request which has the nice UX
    # of not needing credentials to be present. If we've made other signed requests _or_
    # credentials are present then we just sign everything. This has implications for upload:
    # if you attempt to upload to a public bucket without credentials then we allow that here
    # and you'll get a subsequent `AccessDenied` error when the upload is attempted.
    if bucket in PUBLIC_BUCKETS and \
        "s3_signed" not in _storage_registry and \
        ("s3_unsigned" in _storage_registry or not _aws_credentials_present()):

        if provider:=_storage_registry.get('s3_unsigned', None):
            return provider

        from botocore import UNSIGNED # dependency of snakemake-storage-plugin-s3
        storage s3_unsigned:
            provider="s3",
            signature_version=UNSIGNED,
            retries=retries,
            keep_local=keep_local,

        _storage_registry['s3_unsigned'] = storage.s3_unsigned
        return _storage_registry['s3_unsigned']

    # Resource fetched/uploaded via a signed request, which will require AWS credentials
    if provider:=_storage_registry.get('s3_signed', None):
        return provider

    # Enforce the presence of credentials to paper over <https://github.com/snakemake/snakemake/issues/3663>
    if not _aws_credentials_present():
        raise RemoteFilesMissingCredentials()

    # the tag appears in the local file path, so reference 'signed' to give a hint about credential errors
    storage s3_signed:
        provider="s3",
        retries=retries,
        keep_local=keep_local,

    _storage_registry['s3_signed'] = storage.s3_signed
    return _storage_registry['s3_signed']

def _aws_credentials_present() -> bool:
    import boto3 # dependency of snakemake-storage-plugin-s3
    session = boto3.Session()
    creds = session.get_credentials()
    return creds is not None

def _storage_http(*, keep_local, retries) -> snakemake.storage.StorageProviderProxy:
    """
    Registers and returns an instance of snakemake-storage-plugin-http
    """
    if provider:=_storage_registry.get('http', None):
        return provider

    storage:
        provider="http",
        allow_redirects=True,
        supports_head=True,
        keep_local=keep_local,
        retries=retries,

    _storage_registry['http'] = storage.http
    return _storage_registry['http']


def path_or_url(uri, *, keep_local=True, retries=2) -> str | AnnotatedString:
    """
    Intended for use in Snakemake inputs / outputs to transparently use remote
    resources. Returns the URI wrapped by an applicable storage plugin. Local
    filepaths will be returned unchanged.

    For example, the following rule will download inputs from HTTPs and upload
    the output to S3:

        rule filter:
            input:
                sequences = path_or_url("https://data.nextstrain.org/..."),
                metadata = path_or_url("https://data.nextstrain.org/..."),
            output:
                sequences = path_or_url("s3://...")
            shell:
                r'''
                augur filter \
                    --sequences {input.sequences:q} \
                    --metadata {input.metadata:q} \
                    --metadata-id-columns accession \
                    --output-sequences {output.sequences:q}
                '''

    If *keep_local* is True (the default) then downloaded/uploaded files will
    remain in `.snakemake/storage/`. The presence of a previously downloaded
    file (via `keep_local=True`) does not guarantee that the file will not be
    re-downloaded if the storage plugin decides the local file is out of date.

    Depending on the *uri* authentication may be required. See the specific
    helper functions (such as `_storage_s3`) for more details.

    See <https://snakemake.readthedocs.io/en/stable/snakefiles/storage.html> for
    more information on Snakemake storage plugins. Note: various snakemake
    plugins will be required depending on the URIs provided.
    """
    info = urlparse(uri)

    if info.scheme=='': # local
        return uri      # no storage wrapper

    if info.scheme=='s3':
        try:
            so = _storage_s3(bucket=info.netloc, keep_local=keep_local, retries=retries)(uri)
            _printAnnotatedString(so)
            return _local_if_cached(so) if _allow_offline() else so
        except RemoteFilesMissingCredentials as e:
            raise Exception(f"AWS credentials are required to access {uri!r}") from e

    if info.scheme=='https':
        so = _storage_http(keep_local=keep_local, retries=retries)(uri)
        _printAnnotatedString(so)
        return _local_if_cached(so) if _allow_offline() else so
    elif info.scheme=='http':
        raise Exception(f"HTTP remote file support is not implemented in nextstrain workflows (attempting to access {uri!r}).\n"
            "Please use an HTTPS address instead.")

    if info.scheme in ['gs', 'gcs']:
        raise Exception(f"Google Storage is not yet implemented for nextstrain workflows (attempting to access {uri!r}).\n"
            "Please get in touch if you require this functionality and we can add it to our workflows")

    raise Exception(f"Input address {uri!r} (scheme={info.scheme!r}) is from a non-supported remote")

def _allow_offline() -> bool:
    """
    Offline mode is opt-in via the NEXTSTRAIN_OFFLINE environment variable. When
    enabled, remote inputs which are already present in the local storage cache
    are used as-is, without contacting the remote (no existence probe, no
    re-download). This allows a workflow to run from a previously cached copy
    without network access.
    """
    return os.environ.get("NEXTSTRAIN_ALLOW_OFFLINE", "") not in ("", "0", "false")

def _local_if_cached(wrapped: AnnotatedString) -> str | AnnotatedString:
    """
    Given a storage-wrapped input (an AnnotatedString carrying a `storage_object`
    flag), return the plain local cache path if that file already exists on disk.
    Stripping the storage flag makes Snakemake treat it as an ordinary local
    input, so existence is checked via `os.path.exists` rather than a remote
    probe. If the cached file is absent we return the wrapped object unchanged,
    preserving the normal retrieval / MissingInputException behaviour.
    """
    so = get_flag_value(wrapped, "storage_object")
    if so is None:
        raise Exception("_local_if_cached must be called with a storage object AnnotatedString. Provided argument: ", wrapped)
    local = so.local_path()

    # FOLLOWING LINES FOR DEBUGGING ONLY - TO REMOVE TODO XXX
    print("\n_local_if_cached()")
    if local.exists():
        print("local.exists() is True -> returning the plain string", str(local))
    else:
        print("local.exists() is False -> returning the AnnotatedString (storage object) unchanged")
    print()
    return str(local) if local.exists() else wrapped

def _printAnnotatedString(x): # REMOVE FUNCTION TODO XXX DEBUGGING ONLY
    print("-"*20, "_printAnnotatedString ", "-"*20)
    print("value  :", repr(str(x)))
    print("type   :", type(x).__name__)
    print("flags  :", getattr(x, "flags", {}))
    print("callable:", getattr(x, "callable", None))
    so = getattr(x, "flags", {}).get("storage_object")
    if so:
        print("  local_path:", so.local_path())
        print("  query     :", so.query)
        print("  retrieve  :", so.retrieve)
        print("  keep_local:", so.keep_local)
    print("-"*80)