#!/usr/bin/env python3
"""Hito 2 — Audita el corpus LaTeX del HTML original.

Extrae todos los segmentos \(...\) y \[...\] del HTML, lista los comandos
\\xxx y entornos \\begin{yyy} usados con su frecuencia, y vuelca el
resultado a tools/latex_corpus.json para cruzar con el soporte de
flutter_math_fork.

Uso:
    python3 tools/audit_latex_corpus.py
"""

import json
import os
import re
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HTML = "/home/catalystxzr/Escritorio/PERSONAL/APP_UDD/BVO_v235_LATEX_OBLIGATORIO_TODAS_PREGUNTAS_Y_NIVELES(1).html"
OUT = os.path.join(ROOT, "tools", "latex_corpus.json")


def segments(src):
    out = []
    for m in re.finditer(r"\\\((.*?)\\\)", src, re.S):
        out.append(("inline", m.group(1)))
    for m in re.finditer(r"\\\[(.*?)\\\]", src, re.S):
        out.append(("display", m.group(1)))
    return out


def main():
    with open(HTML, encoding="utf-8") as fh:
        src = fh.read()
    segs = segments(src)
    commands = Counter()
    envs = Counter()
    for _kind, body in segs:
        for m in re.finditer(r"\\([a-zA-Z]+|[,;:!])", body):
            commands[m.group(1)] += 1
        for m in re.finditer(r"\\begin\{([a-zA-Z*]+)\}", body):
            envs[m.group(1)] += 1

    data = {
        "segments": len(segs),
        "inline": sum(1 for k, _ in segs if k == "inline"),
        "display": sum(1 for k, _ in segs if k == "display"),
        "commands": dict(sorted(commands.items(), key=lambda kv: -kv[1])),
        "environments": dict(sorted(envs.items(), key=lambda kv: -kv[1])),
        "samples": [b for _, b in segs[:5]],
    }
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(data, fh, ensure_ascii=False, indent=1)
    print(f"segmentos: {data['segments']} (inline {data['inline']}, display {data['display']})")
    print(f"comandos distintos: {len(commands)}, entornos: {dict(envs)}")
    print("top 40 comandos:")
    for cmd, n in list(data["commands"].items())[:40]:
        print(f"  \\{cmd}: {n}")


if __name__ == "__main__":
    main()
