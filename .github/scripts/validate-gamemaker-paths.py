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
        rel = path.relative_to(root).as_posix()
        result[rel.casefold()] = rel
    return result


def resolve_reference(raw: str, source: Path, project_root: Path, repo_root: Path, case_maps: dict[Path, dict[str, str]]) -> tuple[str, str] | None:
    normalized = raw.replace("\\", "/").lstrip("./")
    for base in (source.parent, project_root, repo_root):
        if base not in case_maps:
            case_maps[base] = build_case_map(base)
        case_map = case_maps[base]
        key = normalized.casefold()
        actual = case_map.get(key)
        if actual is not None:
            return normalized, actual
    return None


def main() -> int:
    if not PROJECT_FILE.is_file():
        print(f"ERROR: GameMaker project file not found: {PROJECT_FILE}", file=sys.stderr)
        return 1

    repo_root = Path(".").resolve()
    project_root = (repo_root / PROJECT_FILE.parent).resolve()
    case_maps: dict[Path, dict[str, str]] = {}
    checked: set[tuple[Path, str]] = set()
    errors: list[str] = []

    text_files = sorted(set(repo_root.rglob("*.yy")) | {repo_root / PROJECT_FILE})
    for file in text_files:
        if not file.is_file():
            continue
        try:
            text = file.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue

        for raw in PATH_RE.findall(text):
            if not raw or "${" in raw or raw.startswith(("http:", "https:")):
                continue
            candidate = Path(raw.replace("\\", "/"))
            if candidate.is_absolute():
                continue

            resolved = resolve_reference(raw, file, project_root, repo_root, case_maps)
            if resolved is None:
                continue

            normalized, actual = resolved
            key = (file, normalized.casefold())
            if key in checked:
                continue
            checked.add(key)

            if normalized != actual:
                errors.append(f"{file.relative_to(repo_root)}: references '{raw}', actual path is '{actual}'")

    if errors:
        print("Linux case-sensitivity validation failed:")
        for error in sorted(errors):
            print(f"  - {error}")
        return 1

    print(f"Linux path validation passed ({len(checked)} filesystem references checked).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
