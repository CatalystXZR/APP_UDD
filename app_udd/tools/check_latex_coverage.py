#!/usr/bin/env python3
"""Hito 2 — Cruza comandos del corpus HTML con soporte de flutter_math_fork."""
import glob
import json
import re

BS = chr(92)
PKG = "/home/catalystxzr/.pub-cache/hosted/pub.dev/flutter_math_fork-0.7.4"

supported = set()
for f in glob.glob(PKG + "/lib/**/*.dart", recursive=True):
    src = open(f, encoding="utf-8").read()
    for m in re.finditer("'" + BS * 4 + "([a-zA-Z]+)'", src):
        supported.add(m.group(1))
    for m in re.finditer('"' + BS * 4 + "([a-zA-Z]+)" + '"', src):
        supported.add(m.group(1))

corpus = json.load(open(
    "/home/catalystxzr/Escritorio/PERSONAL/APP_UDD/app_udd/tools/latex_corpus.json",
    encoding="utf-8"))["commands"]

JS_ARTIFACTS = {"s", "S", "d", "b", "n", "bx", "kx", "bEval", "begin", "end"}

print(f"comandos soportados detectados en math_fork: {len(supported)}")
missing = []
for cmd in sorted(corpus):
    if cmd in JS_ARTIFACTS or len(cmd) == 1:
        continue
    if cmd not in supported:
        missing.append(cmd)
print(f"NO soportados (reales): {missing if missing else 'ninguno'}")
json.dump(
    {"supported_count": len(supported), "missing": missing,
     "js_artifacts": sorted(JS_ARTIFACTS)},
    open("/home/catalystxzr/Escritorio/PERSONAL/APP_UDD/app_udd/tools/latex_coverage.json", "w"),
    indent=1)
