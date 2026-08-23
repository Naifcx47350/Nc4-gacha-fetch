"""
batch_gradient.py  ::  re-tag every ASCII-art file in ../Ascii in place.

Usage:
  py scripts/batch_gradient.py [steps=9]

Processes all Ascii/*.txt files (excluding the generated ascii_current.txt),
stripping any old tags and re-applying a dark-biased $1..$steps gradient.
"""

import sys
from pathlib import Path

from gradient_tag import retag_lines, strip_tags

ROOT = Path(__file__).resolve().parents[1]
ASCII_DIR = ROOT / "Ascii"


def process_file(file_path: Path, steps: int) -> None:
    with file_path.open(encoding="utf-8") as f:
        raw = [ln.rstrip("\n") for ln in f]
    tagged = retag_lines(strip_tags(raw), steps)
    with file_path.open("w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(tagged))


def main() -> None:
    steps = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    files = sorted(
        p for p in ASCII_DIR.rglob("*.txt") if p.name != "ascii_current.txt"
    )
    if not files:
        print(f"No ascii art found in {ASCII_DIR}")
        return
    for fp in files:
        process_file(fp, steps)
        print(f"Processed {fp.name} with {steps} steps")


if __name__ == "__main__":
    main()
