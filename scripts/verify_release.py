"""Verify public checksums and executable architecture for all formula downloads."""
import concurrent.futures
import hashlib
import io
import pathlib
import re
import struct
import tarfile
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]


def download(url):
    request = urllib.request.Request(url, headers={"User-Agent": "FlashData-Homebrew-checks"})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def verify(item, published):
    url, digest = item
    name = url.rsplit("/", 1)[1]
    if published.get(name) != digest:
        raise ValueError(f"Formula checksum differs from published SHA256SUMS: {name}")
    payload = download(url)
    if hashlib.sha256(payload).hexdigest() != digest:
        raise ValueError(f"Downloaded archive checksum mismatch: {name}")
    with tarfile.open(fileobj=io.BytesIO(payload), mode="r:gz") as archive:
        members = {m.name: m for m in archive.getmembers()}
        for member in members.values():
            path = pathlib.PurePosixPath(member.name)
            if path.is_absolute() or ".." in path.parts or not member.isfile():
                raise ValueError(f"Unexpected archive member: {member.name}")
        for required in ("flashdata", "LICENSE", "THIRD_PARTY_NOTICES.md", "README.md", "README.zh-CN.md", "examples/query.json"):
            if required not in members:
                raise ValueError(f"Missing {required}: {name}")
        if not members["flashdata"].mode & 0o111:
            raise ValueError(f"Executable mode missing: {name}")
        header = archive.extractfile("flashdata").read(32)
        if "_linux_" in name:
            expected = 183 if "_arm64." in name else 62
            if header[:6] != b"\x7fELF\x02\x01" or struct.unpack_from("<H", header, 18)[0] != expected:
                raise ValueError(f"Incorrect Linux executable architecture: {name}")
        else:
            expected = 0x0100000C if "_arm64." in name else 0x01000007
            if header[:4] != b"\xcf\xfa\xed\xfe" or struct.unpack_from("<I", header, 4)[0] != expected:
                raise ValueError(f"Incorrect macOS executable architecture: {name}")
    return f"Verified {name}: SHA-256, archive contents, executable architecture"


def main():
    formula = (ROOT / "Formula/flashdata.rb").read_text()
    items = re.findall(r'url "([^"]+)"\s+sha256 "([0-9a-f]{64})"', formula)
    version = re.search(r'/releases/download/v(\d+\.\d+\.\d+)/', items[0][0]).group(1)
    base = f"https://github.com/flashdatadev/flashdata-cli/releases/download/v{version}"
    expected = {f"{base}/flashdata_{version}_{system}_{cpu}.tar.gz" for system in ("linux", "darwin") for cpu in ("amd64", "arm64")}
    if len(items) != 4 or {url for url, _ in items} != expected:
        raise ValueError("Expected exactly the four version-pinned official platform archives")
    published = dict(line.split("  ", 1)[::-1] for line in download(f"{base}/SHA256SUMS").decode().splitlines())
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        for message in pool.map(lambda item: verify(item, published), items):
            print(message)


if __name__ == "__main__":
    main()
