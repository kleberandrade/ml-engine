"""Generate the public reference and fail on dartdoc warnings or broken links."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dart', default='dart', help='Dart executable')
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    result = subprocess.run(
        [args.dart, '--suppress-analytics', 'doc', '--validate-links', '--output', str(args.output)],
        text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
    )
    print(result.stdout, end='')
    if result.returncode:
        return result.returncode
    if re.search(r'^\s*(?:warning|error):', result.stdout, re.MULTILINE | re.IGNORECASE):
        print('API documentation must have no warnings or broken links.', file=sys.stderr)
        return 1
    if not (args.output / 'index.html').is_file():
        print('API reference index was not generated.', file=sys.stderr)
        return 1
    entries = json.loads((args.output / 'index.json').read_text())
    public = [e for e in entries if e.get('name') not in {
        'toString', 'noSuchMethod', 'hashCode', 'runtimeType',
    }]
    missing = [e.get('qualifiedName', e.get('name')) for e in public if not e.get('desc')]
    if missing or not public:
        print(f'Undocumented public API elements: {missing}', file=sys.stderr)
        return 1
    print(f'Documented {len(public)}/{len(public)} indexed public API elements.')
    print('Public API reference generated without warnings or broken links.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
