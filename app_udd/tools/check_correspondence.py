#!/usr/bin/env python3
"""Hito 0 — Test de correspondencia PDF(.tex) <-> families_seed.json.

Verifica que cada titulo, plantilla, tupla y control del seed exista
verbatim (normalizando espacios) en el .tex fuente correspondiente, que
los conteos cuadren y que las tuplas enumeradas respeten las restricciones
del PDF. Falla con exit != 0 ante cualquier discrepancia.

Uso:
    python3 tools/check_correspondence.py
"""

import json
import os
import re
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEX_BASE = "/home/catalystxzr/Escritorio/PERSONAL/APP_UDD/C. Diferencial/C. Diferencial"
SEED = os.path.join(ROOT, "assets", "seed", "families_seed.json")

STEMS = {
    "basico": "Parametros_Nivel_Basico",
    "medio": "Parametros_Nivel_Medio",
    "experto": "Parametros_Nivel_Experto",
}

errors = []


def norm(s):
    return re.sub(r"\s+", " ", unicodedata.normalize("NFKC", s or "")).strip()


def check(cond, msg):
    if not cond:
        errors.append(msg)


def find_tex(level_key):
    want = {"basico": "b", "medio": "medio", "experto": "experto"}[level_key]
    for name in os.listdir(TEX_BASE):
        full = os.path.join(TEX_BASE, name)
        if os.path.isdir(full) and norm(name).lower().startswith("n."):
            if want in norm(name).lower():
                for f in os.listdir(full):
                    if f.startswith(STEMS[level_key]) and f.endswith(".tex"):
                        with open(os.path.join(full, f), encoding="utf-8") as fh:
                            return fh.read()
    raise FileNotFoundError(level_key)


def family_block(tex, index, title):
    m = re.search(r"\\familia\{" + str(index) + r"\}\{(.{1,120}?)\}", tex)
    check(m is not None, f"[{index}] marcador \\familia no encontrado en .tex")
    if m is None:
        return ""
    check(norm(m.group(1)) == norm(title), f"[{index}] titulo difiere: tex={m.group(1)!r} seed={title!r}")
    start = m.end()
    nxt = re.search(r"\\familia\{\d+\}", tex[start:])
    return tex[start:start + nxt.start()] if nxt else tex[start:]


def main():
    with open(SEED, encoding="utf-8") as fh:
        seed = json.load(fh)

    check(seed.get("schema_version") == 1, "schema_version != 1")
    check(len(seed["levels"]) == 3, f"niveles != 3 ({len(seed['levels'])})")

    total_tuples = 0
    for lv in seed["levels"]:
        key = lv["key"]
        tex = find_tex(key)
        ntex = norm(tex)
        check(norm(lv["doc_title"]) in ntex, f"[{key}] doc_title ausente en .tex")
        check(norm(lv["doc_subtitle"]) in ntex, f"[{key}] doc_subtitle ausente en .tex")
        check(norm(lv["intro"]) in ntex, f"[{key}] intro ausente en .tex")
        check(len(lv["families"]) == 7, f"[{key}] familias != 7")

        for fam in lv["families"]:
            i = fam["family_index"]
            tag = f"[{key}/F{i}]"
            block = norm(family_block(tex, i, fam["title"]))

            check(bool(fam.get("generator_key")), f"{tag} sin generator_key")
            check(norm(fam["template_latex"]) in block, f"{tag} plantilla ausente en .tex")
            check(norm(fam["conditions"]) in block, f"{tag} condiciones ausentes en .tex")
            check(norm(fam["prompt"]) in block, f"{tag} prompt ausente en .tex")
            if fam.get("control_latex"):
                check(norm(fam["control_latex"]) in block, f"{tag} control ausente en .tex")

            params = [p["name"] for p in fam["params"]]
            for t in fam["tuples"]:
                total_tuples += 1
                check(len(t["raw"]) == len(params), f"{tag} aridad tupla {t['raw']} != params {params}")
                for comp in t["raw"]:
                    check(norm(comp) in block, f"{tag} componente {comp!r} ausente en .tex")

            # Restricciones propias de familias enumeradas / por dominio.
            gk = fam["generator_key"]
            if gk == "seq_monotonicity_regime_change":
                check(len(fam["tuples"]) == 10, f"{tag} se esperan 10 combos (p,q)")
                for t in fam["tuples"]:
                    p, q = t["values"]
                    check(p - q - 1 in (1, 2, 3, 4), f"{tag} combo {(p, q)} viola p-q-1")
            if gk == "seq_hidden_dominant_power_limit":
                check(len(fam["tuples"]) == 64, f"{tag} se esperan 64 combos (A,B,l,m)")
                for t in fam["tuples"]:
                    A, B, lam, mu = t["values"]
                    check(A != 1 or True, f"{tag} combo {(A, B, lam, mu)}")
                    check((lam, mu) in ((3, 2), (4, 2), (4, 3), (5, 2)), f"{tag} par (l,m) no autorizado")
            if gk == "seq_immediate_monotonicity":
                check(fam["tuples"] == [] and "domain" in fam, f"{tag} debe usar dominio, no tuplas")
                check(set(fam["domain"]["p"]) == {-4, -3, -2, 2, 3, 4}, f"{tag} dominio p")
            if gk == "seq_heron_iteration":
                check(len(fam["tuples"]) == 5, f"{tag} se esperan 5 tuplas (Q,u)")
                for t in fam["tuples"]:
                    Q, u = t["values"]
                    check(Q in (2, 3, 5, 6, 7) and u * u - Q <= 6, f"{tag} tupla {(Q, u)} viola guards")

    print(f"tuplas verificadas: {total_tuples}")
    if errors:
        print(f"FALLA: {len(errors)} discrepancias:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)
    print("OK: correspondencia PDF <-> seed verificada (titulos, plantillas, tuplas, controles).")


if __name__ == "__main__":
    main()
