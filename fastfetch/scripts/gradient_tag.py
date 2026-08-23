"""
gradient_tag.py  ::  tag a single ASCII-art file with $1..$steps colour steps.

Usage:
  py gradient_tag.py <input.txt> [output.txt] [steps=9]

Notes:
- Lines are distributed across steps 1..N with a bias toward the darker (higher)
  steps, which matches the dark->light gradients used by the gacha engine.
- Any existing leading "$<digit>" prefix is stripped before re-tagging, so files
  can be re-tagged safely.
- A "$0" on the last art line resets colour after the logo (not its own row).
"""

import re
import sys


def compute_dark_biased_counts(total_lines: int, steps: int) -> list[int]:
    """Lines per step, remainder pushed onto the darkest (tail) steps."""
    if steps <= 0:
        return []
    base, extra = divmod(total_lines, steps)
    counts = [base] * steps
    for i in range(extra):
        counts[steps - 1 - i] += 1
    return counts


def retag_lines(lines: list[str], steps: int) -> list[str]:
    counts = compute_dark_biased_counts(len(lines), steps)
    out: list[str] = []
    idx = 0
    for step, cnt in enumerate(counts, start=1):
        for _ in range(cnt):
            if idx < len(lines):
                out.append(f"${step}{lines[idx]}")
                idx += 1
    for j in range(idx, len(lines)):
        out.append(f"${steps}{lines[j]}")
    # $0 resets colour. Append to the last art line so it does not add a blank row.
    if out:
        out[-1] = out[-1] + "$0"
    else:
        out.append("$0")
    return out


def strip_tags(lines: list[str]) -> list[str]:
    return [re.sub(r"^\$[0-9]\s*", "", ln) for ln in lines if ln is not None]


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: py gradient_tag.py <input.txt> [output.txt] [steps=9]")
        sys.exit(1)

    in_path = sys.argv[1]
    out_path = sys.argv[2] if len(sys.argv) > 2 else in_path.replace(".txt", "_tagged.txt")
    steps = int(sys.argv[3]) if len(sys.argv) > 3 else 9

    with open(in_path, encoding="utf-8") as f:
        raw = [ln.rstrip("\n") for ln in f]

    tagged = retag_lines(strip_tags(raw), steps)

    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(tagged))

    print(f"Tagged {len(raw)} lines into {steps} steps -> {out_path}")


if __name__ == "__main__":
    main()
