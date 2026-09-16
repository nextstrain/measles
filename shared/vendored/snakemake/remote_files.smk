"""
Helper functions to set-up storage plugins for remote inputs/outputs. See the
docstring of `path_or_url` for usage instructions.

The errors raised by storage plugins are often confusing. For instance, a HTTP
404 error will result in a `MissingInputException` with little hint as to the
underlying issue. S3 credentials errors are similarly confusing and we attempt
to check these ourselves to improve UX here.
"""

import socket
from urllib.parse import urlparse
from snakemake.io import get_flag_value, AnnotatedString
from snakemake.logging import logger

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
            return _local_if_offline(so, _detect_online_s3)
        except RemoteFilesMissingCredentials as e:
            raise Exception(f"AWS credentials are required to access {uri!r}") from e

    if info.scheme=='https':
        so = _storage_http(keep_local=keep_local, retries=retries)(uri)
        _printAnnotatedString(so)
        return _local_if_offline(so, _detect_online_http)
    elif info.scheme=='http':
        raise Exception(f"HTTP remote file support is not implemented in nextstrain workflows (attempting to access {uri!r}).\n"
            "Please use an HTTPS address instead.")

    if info.scheme in ['gs', 'gcs']:
        raise Exception(f"Google Storage is not yet implemented for nextstrain workflows (attempting to access {uri!r}).\n"
            "Please get in touch if you require this functionality and we can add it to our workflows")

    raise Exception(f"Input address {uri!r} (scheme={info.scheme!r}) is from a non-supported remote")

# Memoise online-detection results so that repeated path_or_url() calls within a
# single workflow invocation don't each incur a network probe. Keyed by a
# provider-specific string (e.g. an S3 bucket or an HTTP host).
_online_status = {}

def _is_online(key: str, probe) -> bool:
    """Run (and cache) a reachability *probe* for the resource identified by *key*."""
    if key not in _online_status:
        _online_status[key] = probe()
        logger.debug(f"Online detection for {key!r}: {_online_status[key]}")
    return _online_status[key]

def _detect_online_s3(so) -> bool:
    """
    Reachability probe for S3: issue a HEAD request against the bucket. Any
    response from the endpoint — including 403/404 — means we are online; only
    connection-level failures (no route, DNS failure, timeout, refused) are
    treated as offline.
    """
    import botocore.exceptions as botoexc
    def probe() -> bool:
        try:
            so.provider.s3c.meta.client.head_bucket(Bucket=so.bucket)
        except (botoexc.ConnectionError, botoexc.ConnectionClosedError):
            return False
        except Exception:
            return True  # reached the endpoint (e.g. 403/404), so we're online
        return True
    return _is_online(f"s3:{so.bucket}", probe)

def _detect_online_http(so) -> bool:
    """
    Reachability probe for HTTP(S): open (and immediately close) a TCP connection
    to the resource's host. A successful connection means we are online.
    """
    parsed = urlparse(so.query)
    host = parsed.hostname
    port = parsed.port or (443 if parsed.scheme == "https" else 80)
    def probe() -> bool:
        try:
            socket.create_connection((host, port), timeout=5).close()
        except OSError:
            return False
        return True
    return _is_online(f"http:{host}:{port}", probe)

def _local_if_offline(wrapped: AnnotatedString, detect_online) -> str | AnnotatedString:
    """
    Given a storage-wrapped input (an AnnotatedString carrying a `storage_object`
    flag), transparently fall back to the local cache copy *only* when we detect
    that the remote is unreachable:

      * If no cached copy exists we return the wrapped object unchanged — there is
        nothing to fall back to, so the normal retrieval / MissingInputException
        behaviour applies.
      * If a cached copy exists but the remote is reachable (*detect_online*
        returns True) we still return the wrapped object, so Snakemake performs
        its usual existence check and freshness revalidation (re-downloading if
        the remote copy is newer).
      * Only if a cached copy exists *and* the remote is unreachable do we strip
        the storage flag and return the plain local path. Snakemake then treats it
        as an ordinary local input (existence via `os.path.exists`, no network),
        allowing the workflow to run offline from cache.
    """
    so = get_flag_value(wrapped, "storage_object")
    if so is None:
        raise Exception("_local_if_offline must be called with a storage object AnnotatedString. Provided argument: ", wrapped)
    local = so.local_path()

    if not local.exists():
        print(">>>> Cached file not on disk -- returning StorageObject unchanged")
        return wrapped
    if detect_online(so):
        print(">>>> Cached file on disk and we're online -- returning StorageObject unchanged")
        return wrapped

    logger.warning(
        f"Remote appears to be unreachable; using the cached copy of {so.query} "
        f"at {local} without revalidation."
    )
    return str(local)

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