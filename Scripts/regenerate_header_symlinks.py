#!/usr/bin/env python3
"""Regenerate the SPM header symlinks for OpenUXKit.

`Sources/OpenUXKit/PrivateHeaders/OpenUXKit/` aggregates every header in the
framework so that `<OpenUXKit/X.h>` resolves for any internal source file.
`Sources/OpenUXKit/include/OpenUXKit/` exposes the public surface — the same
list that `project.pbxproj`'s `publicHeaders` block declares for Xcode.

The script rebuilds both directories from scratch. Each symlink target is a
correct relative path (no absolute paths, no `$PWD`-dependent shell expansion).

Run from anywhere; the script anchors paths to its own location.

    python3 Scripts/regenerate_header_symlinks.py            # rewrite symlinks
    python3 Scripts/regenerate_header_symlinks.py --check    # exit 1 on drift
"""

import argparse
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SOURCES_DIR = REPO_ROOT / "Sources" / "OpenUXKit"
PRIVATE_HEADERS_DIR = SOURCES_DIR / "PrivateHeaders" / "OpenUXKit"
INCLUDE_DIR = SOURCES_DIR / "include" / "OpenUXKit"
PBXPROJ_PATH = REPO_ROOT / "OpenUXKit.xcodeproj" / "project.pbxproj"

# When walking the framework tree, skip these directory names (they are
# either symlink output or VCS/build noise).
EXCLUDE_DIRS = {"PrivateHeaders", "include", ".git", "build", "DerivedData"}


def discover_source_headers() -> dict[str, Path]:
    """Map basename -> absolute source path for every .h file in the framework.

    Headers inside PrivateHeaders/ and include/ are skipped because they are
    themselves symlinks we are about to rewrite.
    """
    headers: dict[str, Path] = {}
    for root, dirs, files in os.walk(SOURCES_DIR):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for name in files:
            if not name.endswith(".h"):
                continue
            path = Path(root) / name
            if name in headers:
                raise SystemExit(
                    f"duplicate header basename {name!r}:\n"
                    f"  {headers[name]}\n  {path}"
                )
            headers[name] = path
    return headers


def parse_public_header_names(pbxproj: Path) -> set[str]:
    """Return the basename set declared in pbxproj's publicHeaders block."""
    text = pbxproj.read_text()
    match = re.search(r"publicHeaders\s*=\s*\(([^)]*)\)", text, re.DOTALL)
    if not match:
        raise SystemExit("publicHeaders block not found in project.pbxproj")
    block = match.group(1)
    paths = re.findall(r"[\w.+/\-]+\.h", block)
    return {os.path.basename(p) for p in paths}


def plan_symlinks(target_dir: Path, header_map: dict[str, Path]) -> dict[str, str]:
    """Return basename -> relative target string for each symlink to create."""
    plan: dict[str, str] = {}
    for name, source in header_map.items():
        plan[name] = os.path.relpath(source, target_dir)
    return plan


def current_symlinks(target_dir: Path) -> dict[str, str]:
    """Return basename -> link-target string for symlinks already in target_dir."""
    if not target_dir.is_dir():
        return {}
    state: dict[str, str] = {}
    for entry in target_dir.iterdir():
        if entry.is_symlink():
            state[entry.name] = os.readlink(entry)
    return state


def apply_plan(target_dir: Path, plan: dict[str, str], *, check_only: bool) -> bool:
    """Rebuild target_dir to match plan. Returns True if changes were made."""
    target_dir.mkdir(parents=True, exist_ok=True)
    state = current_symlinks(target_dir)

    stale = sorted(set(state) - set(plan))
    fresh = sorted(set(plan) - set(state))
    drift = sorted(name for name in set(plan) & set(state) if state[name] != plan[name])

    changed = bool(stale or fresh or drift)
    if check_only:
        if changed:
            label = target_dir.relative_to(REPO_ROOT)
            print(f"[drift] {label}: {len(stale)} stale, {len(fresh)} missing, {len(drift)} wrong target")
            for name in stale:
                print(f"  - {name}")
            for name in fresh:
                print(f"  + {name} -> {plan[name]}")
            for name in drift:
                print(f"  ~ {name}: {state[name]} -> {plan[name]}")
        return changed

    for name in stale:
        (target_dir / name).unlink()
    for name in drift:
        (target_dir / name).unlink()
    for name in fresh + drift:
        (target_dir / name).symlink_to(plan[name])

    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--check",
        action="store_true",
        help="report drift and exit non-zero, do not touch the filesystem",
    )
    args = parser.parse_args()

    headers = discover_source_headers()
    public_names = parse_public_header_names(PBXPROJ_PATH)

    missing_public = sorted(public_names - set(headers))
    if missing_public:
        print("ERROR: publicHeaders entries with no matching source file:")
        for name in missing_public:
            print(f"  {name}")
        return 2

    public_map = {name: headers[name] for name in public_names}

    private_plan = plan_symlinks(PRIVATE_HEADERS_DIR, headers)
    public_plan = plan_symlinks(INCLUDE_DIR, public_map)

    private_changed = apply_plan(PRIVATE_HEADERS_DIR, private_plan, check_only=args.check)
    public_changed = apply_plan(INCLUDE_DIR, public_plan, check_only=args.check)

    if args.check:
        return 1 if (private_changed or public_changed) else 0

    print(f"PrivateHeaders/OpenUXKit: {len(private_plan)} symlinks")
    print(f"include/OpenUXKit:        {len(public_plan)} symlinks")
    return 0


if __name__ == "__main__":
    sys.exit(main())
