#!/usr/bin/env python3
"""Validate GameMaker relative path references with Linux case sensitivity."""

from __future__ import annotations

import re
import sys
from pathlib import Path

PROJECT_FILE = Path("PocketCrystalLeague.yyp/PocketCrystalLeague.yyp")
PATH_RE = re.compile(r'"(?:path|folderPath)"\s*:\s*"([^"]+)"')


def build_case_map(root: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for path in root.rglob("*"):
        if ".git" in path.parts:
            continue
        rel = path.relative_to(root).as_posix()
        result[rel.casefold()] = rel
    return result


def main() -> int:
    if not PROJECT_FILE.is_file():
        print(f"ERROR: GameMaker project file not found: {PROJECT_FILE}", file=sys.stderr)
        return 1

    root = Path(".").resolve()
    case_map = build_case_map(root)
    text_files = [p for p in root.rglob("*.yy")] + [PROJECT_FILE]
    checked: set[str] = set()
    errors: list[str] = []

    for file in text_files:
        if not file.is_file():
            continue
        try:
            text = file.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue

        for raw in PATH_RE.findall(text):
            raw = raw.replace("\\", "/")
            if not raw or "${" in raw or raw.startswith("http:") or raw.startswith("https:"):
                continue

            candidate = Path(raw)
            if candidate.is_absolute():
                continue

            normalized = candidate.as_posix().lstrip("./")
            key = normalized.casefold()
            if key in checked:
                continue
            checked.add(key)

            exact = case_map.get(key)
            if exact is None:
                # Some GameMaker fields are logical IDs rather than filesystem paths.
                continue
            if exact != normalized:
                errors.append(f"{file}: references '{raw}', actual path is '{exact}'")

    if errors:
        print("Linux case-sensitivity validation failed:")
        for error in sorted(errors):
            print(f"  - {error}")
        return 1

    print(f"Linux path validation passed ({len(checked)} filesystem references checked).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
