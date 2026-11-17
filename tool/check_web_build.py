"""Verify the repository-path release locally, and optionally its served URLs."""
import argparse
import json
from html.parser import HTMLParser
from pathlib import Path
import re
from urllib.parse import urljoin
from urllib.request import Request, urlopen


class WebShell(HTMLParser):
    def __init__(self):
        super().__init__()
        self.base = None
        self.scripts = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'base':
            self.base = attrs.get('href')
        if tag == 'script' and attrs.get('src'):
            self.scripts.append(attrs['src'])


def check_shell(html, expected_base):
    shell = WebShell()
    shell.feed(html)
    if shell.base != expected_base or 'flutter_bootstrap.js' not in shell.scripts:
        raise ValueError('Incorrect base href or missing Flutter bootstrap script')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', type=Path, default=Path('apps/ml_lab/build/web'))
    parser.add_argument('--base-href', default='/ml-engine/')
    parser.add_argument('--url', help='Optional actual deployed site URL for HTTP verification')
    args = parser.parse_args()
    directory = args.directory.resolve()
    check_shell((directory / 'index.html').read_text(), args.base_href)
    bootstrap = (directory / 'flutter_bootstrap.js').read_text()
    entrypoint = re.search(r'"mainJsPath"\s*:\s*"([^"]+)"', bootstrap)
    if entrypoint is None or not re.fullmatch(r'main\.dart\.[0-9a-f]+\.js', entrypoint[1]):
        raise ValueError('Expected a content-hashed JavaScript entry point')
    if re.search(r'_flutter\.loader\.load\(\s*\{\s*serviceWorkerSettings', bootstrap):
        raise ValueError('The deprecated Flutter service worker must not be registered')
    manifest = json.loads((directory / 'precache_manifest.json').read_text())
    for entry in manifest['entries']:
        target = (directory / entry['url']).resolve()
        if not target.is_relative_to(directory) or not target.is_file() or target.stat().st_size != entry['size']:
            raise ValueError(f"Missing or incorrect build asset: {entry['url']}")
    required = ['flutter_bootstrap.js', entrypoint[1], 'manifest.json', 'brand-mark.svg', 'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm']
    if not all((directory / path).is_file() for path in required):
        raise ValueError('Missing required runtime assets')
    if args.url:
        with urlopen(args.url, timeout=30) as response:
            check_shell(response.read().decode(), args.base_href)
        with urlopen(urljoin(args.url, 'flutter_bootstrap.js'), timeout=30) as response:
            remote_bootstrap = response.read().decode()
        remote_entrypoint = re.search(r'"mainJsPath"\s*:\s*"([^"]+)"', remote_bootstrap)
        if remote_entrypoint is None:
            raise ValueError('Deployed bootstrap has no JavaScript entry point')
        # A different build host may emit a different content hash; follow the served bootstrap.
        required[1] = remote_entrypoint[1]
        for path in required:
            with urlopen(Request(urljoin(args.url, path), method='HEAD'), timeout=30) as response:
                if response.status != 200:
                    raise ValueError(f'Unreachable deployed asset: {path}')
        print(f'Deployed shell and {len(required)} runtime URLs verified: {args.url}')
    print(f"Build verified: base {args.base_href}, {len(manifest['entries'])} manifest assets, hashed entry point, bundled CanvasKit.")


if __name__ == '__main__':
    main()
