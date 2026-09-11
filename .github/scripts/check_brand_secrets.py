#!/usr/bin/env python3
"""Fail CI if privileged server/signing secrets are stored in brand JSON."""

from __future__ import annotations

import json
from pathlib import Path
import sys

SECRET_PATHS = (
    ("keystore", "storePassword"),
    ("keystore", "keyPassword"),
    ("api", "wooConsumerKey"),
    ("api", "wooConsumerSecret"),
    ("api", "walletConsumerKey"),
    ("api", "walletConsumerSecret"),
    ("payment", "paytmMerchantKey"),
)


def nested_value(data: dict, path: tuple[str, ...]):
    value = data
    for key in path:
        if not isinstance(value, dict):
            return None
        value = value.get(key)
    return value


def main() -> int:
    brand_files = sorted(Path("brands").glob("*/config.json"))
    if not brand_files:
        print("No brand config files found.")
        return 1

    violations: list[str] = []
    for config_path in brand_files:
        data = json.loads(config_path.read_text(encoding="utf-8"))
        for secret_path in SECRET_PATHS:
            value = nested_value(data, secret_path)
            if isinstance(value, str) and value.strip():
                violations.append(
                    f"{config_path}: {'.'.join(secret_path)} must be empty/client-free"
                )

    if violations:
        print("Privileged credentials must never be committed or bundled in the mobile app:")
        for violation in violations:
            print(f" - {violation}")
        return 1

    print("Brand configs contain no privileged server/signing secrets.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
