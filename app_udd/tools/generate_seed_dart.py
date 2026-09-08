#!/usr/bin/env python3
"""Hito 8 — Genera lib/data/seed/families_seed_data.dart desde el JSON.

El seed queda compilado en la app (sin rootBundle, instantaneo y testeable).
Fuente unica: assets/seed/families_seed.json. Regenerar con:
    python3 tools/generate_seed_dart.py
"""

import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "assets", "seed", "families_seed.json")
OUT = os.path.join(ROOT, "lib", "data", "seed", "families_seed_data.dart")


def main():
    with open(SRC, encoding="utf-8") as fh:
        json.load(fh)
        fh.seek(0)
        raw = fh.read()
    dart = (
        "// Generado desde assets/seed/families_seed.json. NO EDITAR A MANO.\n"
        "// Regenerar con: python3 tools/generate_seed_dart.py\n"
        "const String familiesSeedJson = "
        + json.dumps(raw, ensure_ascii=True).replace(chr(36), chr(92) + chr(36))
        + ";\n"
    )
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(dart)
    print(f"OK: {len(raw)} chars -> {OUT}")


if __name__ == "__main__":
    main()
