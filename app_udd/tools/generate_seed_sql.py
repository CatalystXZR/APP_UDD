#!/usr/bin/env python3
"""Hito 0 — Genera 0002_seed_families.sql desde families_seed.json.

Fuente única: assets/seed/families_seed.json. No editar el SQL a mano;
regenerar con:
    python3 tools/generate_seed_sql.py
"""

import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEED = os.path.join(ROOT, "assets", "seed", "families_seed.json")
OUT = os.path.join(ROOT, "supabase", "migrations", "0002_seed_families.sql")


def lit(s):
    if s is None:
        return "NULL"
    return "'" + str(s).replace("'", "''") + "'"


def js(v):
    return lit(json.dumps(v, ensure_ascii=False))


def main():
    with open(SEED, encoding="utf-8") as fh:
        seed = json.load(fh)

    lines = [
        "-- Hito 0 — Seed generado desde assets/seed/families_seed.json.",
        "-- NO EDITAR A MANO. Regenerar con: python3 tools/generate_seed_sql.py",
        "",
    ]
    for lv in seed["levels"]:
        lines.append(
            f"insert into difficulties (key, label, seconds_per_question) values "
            f"({lit(lv['key'])}, {lit(lv['label'])}, {lv['seconds_per_question']}) "
            f"on conflict (key) do update set label = excluded.label, "
            f"seconds_per_question = excluded.seconds_per_question;"
        )
    lines.append("")
    for lv in seed["levels"]:
        for fam in lv["families"]:
            fid = f"{lv['key']}-f{fam['family_index']}"
            cols = ("id, level_key, family_index, generator_key, title, prompt, "
                    "template_latex, conditions, params_json, tuples_json, "
                    "domain_json, control_latex")
            vals = ", ".join([
                lit(fid), lit(lv["key"]), str(fam["family_index"]),
                lit(fam["generator_key"]), lit(fam["title"]),
                lit(fam.get("prompt")), lit(fam["template_latex"]),
                lit(fam.get("conditions")), js(fam["params"]),
                js(fam["tuples"]),
                js(fam.get("domain")) if fam.get("domain") else "NULL",
                lit(fam.get("control_latex")),
            ])
            lines.append(f"insert into families ({cols}) values ({vals})")
            lines.append(f"on conflict (id) do update set level_key = excluded.level_key, "
                         f"family_index = excluded.family_index, generator_key = excluded.generator_key, "
                         f"title = excluded.title, prompt = excluded.prompt, "
                         f"template_latex = excluded.template_latex, conditions = excluded.conditions, "
                         f"params_json = excluded.params_json, tuples_json = excluded.tuples_json, "
                         f"domain_json = excluded.domain_json, control_latex = excluded.control_latex;")
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")
    n_fam = sum(len(l["families"]) for l in seed["levels"])
    print(f"OK: difficulties + {n_fam} families -> {OUT}")


if __name__ == "__main__":
    main()
