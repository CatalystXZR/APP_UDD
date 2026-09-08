#!/usr/bin/env python3
"""Hito 0 — Extrae el banco parametrico desde los .tex a families_seed.json.

Fuente de verdad inicial: los 3 documentos Parametros_Nivel_*.tex
(SUCESIONES Y LIMITES, niveles Basico/Medio/Experto, 7 familias c/u).

Estrategia: los encabezados (titulo, subtitulo, intro) se extraen del .tex
con regex; los cuerpos de las 21 familias se transcriben explicitamente
abajo y tools/check_correspondence.py verifica contra el .tex que cada
titulo, plantilla, tupla y control exista verbatim (normalizando espacios).
De ahi en adelante, families_seed.json (+ SQL generado) es la fuente de
verdad para Supabase y el generador Dart.

Uso:
    python3 tools/extract_parametros.py
"""

import json
import os
import re
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEX_BASE = "/home/catalystxzr/Escritorio/PERSONAL/APP_UDD/C. Diferencial/C. Diferencial"
OUT = os.path.join(ROOT, "assets", "seed", "families_seed.json")


def norm(s):
    s = unicodedata.normalize("NFKC", s or "")
    return re.sub(r"\s+", " ", s).strip()


def find_level_dir(want):
    for name in os.listdir(TEX_BASE):
        full = os.path.join(TEX_BASE, name)
        if os.path.isdir(full) and norm(name).lower().startswith("n."):
            if want in norm(name).lower():
                return full
    raise FileNotFoundError(want)


def read_tex(level_key, stem):
    d = find_level_dir({"basico": "b", "medio": "medio", "experto": "experto"}[level_key])
    for f in os.listdir(d):
        if f.startswith(stem) and f.endswith(".tex"):
            with open(os.path.join(d, f), encoding="utf-8") as fh:
                return fh.read()
    raise FileNotFoundError(stem)


def doc_header(tex):
    title = re.search(r"\{\\LARGE\\bfseries\\color\{azul\}\s*(.*?)\}", tex, re.S).group(1)
    subtitle = re.search(r"\{\\Large\s*(.*?)\}", tex, re.S).group(1)
    intro = re.search(r"\\begin\{tcolorbox\}(.*?)\\end\{tcolorbox\}", tex, re.S).group(1)
    intro = re.sub(r"^\s*\[[^\]]*\]", "", intro)
    return norm(title), norm(subtitle), norm(intro)


def T(*comps):
    """Tupla con componentes raw (tex) y valores numericos/simbolicos."""
    raw, values = [], []
    for c in comps:
        if isinstance(c, tuple):
            raw.append(c[0])
            values.append(c[1])
        else:
            raw.append(str(c))
            values.append(c)
    return {"raw": raw, "values": values}


INT = {"kind": "int"}
SYM_EPS = {
    "kind": "symbol",
    "symbols": {
        "alternating": "(-1)^n",
        "sin": "\\sin n",
        "cos_sq": "\\cos(n^2)",
        "alternating_shift": "(-1)^{n+1}",
    },
}

# ----------------------------------------------------------------------------
# Transcripcion fiel de las 21 familias (verificada por check_correspondence).
# ----------------------------------------------------------------------------
LEVELS = [
    {
        "key": "basico",
        "label": "Básico",
        "stem": "Parametros_Nivel_Basico",
        "seconds_per_question": 60,
        "families": [
            {
                "family_index": 1,
                "generator_key": "seq_explicit_terms",
                "title": "Términos de una sucesión explícita",
                "prompt": "Pedir tres términos consecutivos y $a_k$.",
                "template_latex": "a_n=pn+q.",
                "conditions": "$p\\neq0$, $1\\leq k\\leq12$ y $|a_k|\\leq40$.",
                "params": [{"name": "p", **INT}, {"name": "q", **INT}, {"name": "k", **INT}],
                "tuples": [T(2, 1, 8), T(3, -2, 7), T(-2, 9, 6), T(4, -3, 5)],
                "control_latex": "$a_k=pk+q$.",
            },
            {
                "family_index": 2,
                "generator_key": "seq_pattern_recognition",
                "title": "Reconocimiento de patrón",
                "prompt": "Mostrar los primeros cuatro términos y pedir el término general y $a_k$.",
                "template_latex": "a_n=\\frac{n+r}{n+s}.",
                "conditions": "$r,s\\in\\mathbb Z$, $s\\geq1$, $r\\neq s$, $5\\leq k\\leq12$.",
                "params": [{"name": "r", **INT}, {"name": "s", **INT}, {"name": "k", **INT}],
                "tuples": [T(1, 3, 8), T(2, 5, 7), T(3, 4, 10), T(-1, 2, 9)],
                "control_latex": "mantener denominadores positivos y menores que $16$.",
            },
            {
                "family_index": 3,
                "generator_key": "seq_explicit_to_recursive",
                "title": "De forma explícita a recursiva",
                "prompt": "Pedir $b_1$, la recurrencia y un término posterior.",
                "template_latex": "b_n=a_1+(n-1)d.",
                "conditions": "$a_1,d\\in\\mathbb Z$, $d\\neq0$, $|d|\\leq5$; usar $b_{n+1}=b_n+d$.",
                "params": [{"name": "a1", **INT}, {"name": "d", **INT}, {"name": "k", **INT}],
                "tuples": [T(3, 2, 9), T(7, -1, 10), T(-2, 3, 8), T(10, -2, 7)],
                "control_latex": "$b_k=a_1+(k-1)d$.",
            },
            {
                "family_index": 4,
                "generator_key": "seq_immediate_monotonicity",
                "title": "Monotonía inmediata",
                "prompt": "Pedir decidir si la sucesión es creciente o decreciente mediante $c_{n+1}-c_n$.",
                "template_latex": "c_n=pn+q.",
                "conditions": "$p\\in\\{-4,-3,-2,2,3,4\\}$ y $|q|\\leq6$.",
                "params": [{"name": "p", **INT}, {"name": "q", **INT}],
                "domain": {"p": [-4, -3, -2, 2, 3, 4], "q": {"min": -6, "max": 6, "int": True}},
                "tuples": [],
                "control_latex": "\\[ c_{n+1}-c_n=p. \\] Si $p>0$ es estrictamente creciente; si $p<0$ es estrictamente decreciente.",
            },
            {
                "family_index": 5,
                "generator_key": "seq_elementary_bound",
                "title": "Acotación elemental",
                "prompt": "Pedir demostrar una cota superior y encontrar el menor término.",
                "template_latex": "d_n=L-\\frac{m}{n+r}.",
                "conditions": "$L,m,r\\in\\mathbb N$, $1\\leq m\\leq6$, $0\\leq r\\leq3$ y $m$ múltiplo de $r+1$ cuando se desee un primer término entero.",
                "params": [{"name": "L", **INT}, {"name": "m", **INT}, {"name": "r", **INT}],
                "tuples": [T(4, 2, 1), T(5, 3, 2), T(6, 4, 1), T(3, 2, 0)],
                "control_latex": "$d_1=L-m/(r+1)$ y $d_n<L$.",
            },
            {
                "family_index": 6,
                "generator_key": "seq_direct_algebraic_limit",
                "title": "Límite algebraico directo",
                "prompt": "Pedir calcular el límite dividiendo por $n$.",
                "template_latex": "e_n=\\frac{an+b}{cn+d}.",
                "conditions": "$a,c\\in\\mathbb N$, $c\\neq0$, $|b|,|d|\\leq5$, $cn+d>0$ para $n\\geq1$ y $a/c$ entero o fracción irreducible sencilla.",
                "params": [{"name": "a", **INT}, {"name": "b", **INT}, {"name": "c", **INT}, {"name": "d", **INT}],
                "tuples": [T(2, 1, 1, 3), T(3, -1, 2, 2), T(4, 3, 2, 1), T(5, -2, 3, 4)],
                "control_latex": "$\\displaystyle\\lim e_n=a/c$.",
            },
            {
                "family_index": 7,
                "generator_key": "seq_guided_convergent_recurrence",
                "title": "Recurrencia convergente guiada",
                "prompt": "Pedir calcular tres términos, conjeturar monotonía y hallar el límite.",
                "template_latex": "x_1=u,\\qquad x_{n+1}=\\frac{x_n+L}{2}.",
                "conditions": "$u,L\\in\\mathbb Z$, $u\\neq L$, $|u-L|\\in\\{2,4,8\\}$. Si $u<L$, la sucesión es creciente; si $u>L$, es decreciente.",
                "params": [{"name": "u", **INT}, {"name": "L", **INT}],
                "tuples": [T(0, 4), T(1, 5), T(8, 4), T(10, 2)],
                "control_latex": "límite $L$ y fórmula $x_n=L+(u-L)2^{-(n-1)}$.",
            },
        ],
    },
    {
        "key": "medio",
        "label": "Medio",
        "stem": "Parametros_Nivel_Medio",
        "seconds_per_question": 90,
        "families": [
            {
                "family_index": 1,
                "generator_key": "seq_alternating_pattern",
                "title": "Patrón alternante y cálculo de términos",
                "prompt": "Pedir cuatro términos, uno posterior y explicar el efecto de $h$.",
                "template_latex": "a_n=(-1)^{n+h}\\frac{pn+q}{n+r},\\qquad h\\in\\{0,1\\}.",
                "conditions": "$p\\in\\{2,3,4\\}$, $|q|\\leq4$, $r\\in\\{1,2,3,4\\}$, $pn+q>0$ para $n\\geq1$ y $5\\leq k\\leq10$.",
                "params": [{"name": "p", **INT}, {"name": "q", **INT}, {"name": "r", **INT}, {"name": "h", **INT}, {"name": "k", **INT}],
                "tuples": [T(2, 3, 4, 1, 8), T(3, 1, 2, 0, 7), T(4, -1, 3, 1, 6), T(2, 1, 1, 0, 9)],
                "control_latex": None,
            },
            {
                "family_index": 2,
                "generator_key": "seq_explicit_recursive_conversion",
                "title": "Conversión explícita-recursiva",
                "prompt": "Pedir una recurrencia de primer orden y comprobarla.",
                "template_latex": "b_n=L+Cq^{n-1}.",
                "conditions": "$q\\in\\{2,3,-2\\}$, $C\\neq0$, $|C|\\leq4$, $|L|\\leq5$; usar \\[ b_{n+1}=q b_n+(1-q)L,\\qquad b_1=L+C. \\]",
                "params": [{"name": "L", **INT}, {"name": "C", **INT}, {"name": "q", **INT}],
                "tuples": [T(3, 2, 2), T(-1, 3, 2), T(2, -1, 3), T(1, 2, -2)],
                "control_latex": None,
            },
            {
                "family_index": 3,
                "generator_key": "seq_rational_monotonicity",
                "title": "Monotonía racional",
                "prompt": "Pedir determinar la monotonía mediante diferencia.",
                "template_latex": "c_n=\\frac{An+B}{Cn+D}.",
                "conditions": "$C>0$, $Cn+D>0$ para $n\\geq1$, $AD-BC\\neq0$ y $|A|,|B|,|C|,|D|\\leq6$.",
                "params": [{"name": "A", **INT}, {"name": "B", **INT}, {"name": "C", **INT}, {"name": "D", **INT}],
                "tuples": [T(4, -1, 2, 3), T(3, 2, 2, 5), T(2, 5, 3, 1), T(5, 1, 2, 4)],
                "control_latex": "\\[ c_{n+1}-c_n=\\frac{AD-BC}{(Cn+D)(Cn+C+D)}. \\]",
            },
            {
                "family_index": 4,
                "generator_key": "seq_horizontal_asymptote_bound",
                "title": "Acotación por una asíntota horizontal",
                "prompt": "Pedir monotonía, una cota alcanzada y otra no alcanzada.",
                "template_latex": "d_n=L+\\frac{K}{n+r}.",
                "conditions": "$K\\neq0$, $r\\geq0$ y $n+r>0$. Si $K>0$, decrece hacia $L$; si $K<0$, crece hacia $L$.",
                "params": [{"name": "L", **INT}, {"name": "K", **INT}, {"name": "r", **INT}],
                "tuples": [T(3, 4, 1), T(5, -3, 2), T(-1, 2, 1), T(2, -4, 3)],
                "control_latex": "extremo alcanzado $d_1=L+K/(r+1)$; límite $L$.",
            },
            {
                "family_index": 5,
                "generator_key": "seq_rationalizable_limit",
                "title": "Límite racionalizable",
                "prompt": "Pedir racionalizar y calcular el límite.",
                "template_latex": "e_n=\\sqrt{p^2n^2+qn+r}-pn.",
                "conditions": "$p\\in\\{1,2,3,4\\}$, $q$ múltiplo de $2p$ para obtener $q/(2p)$ entero o semientero, y el radicando debe ser positivo para $n\\geq1$.",
                "params": [{"name": "p", **INT}, {"name": "q", **INT}, {"name": "r", **INT}],
                "tuples": [T(1, 4, 1), T(2, 4, 3), T(3, 6, 2), T(4, 8, 1)],
                "control_latex": "$\\displaystyle\\lim e_n=q/(2p)$.",
            },
            {
                "family_index": 6,
                "generator_key": "seq_affine_convergent_recurrence",
                "title": "Recurrencia afín convergente",
                "prompt": "Pedir demostrar monotonía, acotación y convergencia.",
                "template_latex": "x_1=u,\\qquad x_{n+1}=\\rho x_n+(1-\\rho)L.",
                "conditions": "$0<\\rho<1$; usar $u<L$ para crecimiento y $u>L$ para decrecimiento.",
                "params": [{"name": "rho", "kind": "rational"}, {"name": "L", **INT}, {"name": "u", **INT}],
                "tuples": [
                    T(("\\tfrac12", 0.5), 4, 0),
                    T(("\\tfrac13", 1 / 3), 3, 0),
                    T(("\\tfrac14", 0.25), 2, 6),
                    T(("\\tfrac23", 2 / 3), 5, 8),
                ],
                "control_latex": "$x_n=L+(u-L)\\rho^{n-1}$ y $\\lim x_n=L$.",
            },
            {
                "family_index": 7,
                "generator_key": "seq_sandwich_theorem",
                "title": "Teorema del sándwich",
                "prompt": "Usar $\\varepsilon_n=(-1)^n$, $\\sin n$ o $\\cos(n^2)$ y pedir justificar el límite.",
                "template_latex": "\\[ y_n=\\varepsilon_n\\frac{an+b}{n^2+c}, \\qquad |\\varepsilon_n|\\leq1. \\]",
                "conditions": "$a>0$, $b,c\\geq0$, $a,b,c\\leq6$.",
                "params": [{"name": "eps", **SYM_EPS}, {"name": "a", **INT}, {"name": "b", **INT}, {"name": "c", **INT}],
                "tuples": [
                    T((("(-1)^n"), "alternating"), 2, 3, 1),
                    T(("\\sin n", "sin"), 3, 1, 2),
                    T(("\\cos(n^2)", "cos_sq"), 4, 2, 3),
                    T((("(-1)^{n+1}"), "alternating_shift"), 5, 1, 4),
                ],
                "control_latex": "\\[ |y_n|\\leq\\frac{an+b}{n^2+c}\\longrightarrow0. \\]",
            },
        ],
    },
    {
        "key": "experto",
        "label": "Experto",
        "stem": "Parametros_Nivel_Experto",
        "seconds_per_question": 180,
        "families": [
            {
                "family_index": 1,
                "generator_key": "seq_reconstruction_from_differences",
                "title": "Reconstrucción desde diferencias",
                "prompt": "Pedir hallar una fórmula explícita y verificarla por inducción.",
                "template_latex": "a_{n+1}-a_n=pn+q,\\qquad a_1=r.",
                "conditions": "$p\\neq0$, $|p|\\leq4$, $|q|\\leq5$, $|r|\\leq6$. Usar \\[ a_n=r+\\frac{p(n-1)n}{2}+q(n-1). \\]",
                "params": [{"name": "p", **INT}, {"name": "q", **INT}, {"name": "r", **INT}],
                "tuples": [T(2, 1, 3), T(3, -1, 2), T(-2, 5, 1), T(4, -3, -1)],
                "control_latex": None,
            },
            {
                "family_index": 2,
                "generator_key": "seq_second_order_recurrence",
                "title": "Recurrencia de segundo orden",
                "prompt": "Pedir construir la recurrencia, calcular datos iniciales y demostrar equivalencia.",
                "template_latex": "b_n=A\\alpha^n+B\\beta^n.",
                "conditions": "$\\alpha,\\beta\\in\\{-2,-1,2,3,4\\}$, $\\alpha\\neq\\beta$, $A,B\\in\\{-3,-2,-1,1,2,3\\}$ y términos iniciales de valor absoluto menor que $50$.",
                "params": [{"name": "A", **INT}, {"name": "B", **INT}, {"name": "alpha", **INT}, {"name": "beta", **INT}],
                "tuples": [T(1, -1, 3, 2), T(2, -1, 2, -1), T(1, 2, 2, -2), T(-1, 2, 3, 1)],
                "control_latex": "\\[ b_{n+2}=(\\alpha+\\beta)b_{n+1}-\\alpha\\beta b_n. \\]",
            },
            {
                "family_index": 3,
                "generator_key": "seq_monotonicity_regime_change",
                "title": "Monotonía con cambio de comportamiento",
                "prompt": "Pedir localizar exactamente dónde crece, se mantiene o decrece.",
                "template_latex": "c_n=\\frac{p^n}{(n+q)!}.",
                "conditions": "$p\\in\\{4,5,6,7\\}$, $q\\in\\{1,2,3\\}$ y $p-q-1\\in\\{1,2,3,4\\}$.",
                "params": [{"name": "p", **INT}, {"name": "q", **INT}],
                "tuples": [T(4, 1), T(4, 2), T(5, 1), T(5, 2), T(5, 3),
                           T(6, 1), T(6, 2), T(6, 3), T(7, 2), T(7, 3)],
                "control_latex": "\\[ \\frac{c_{n+1}}{c_n}=\\frac{p}{n+q+1}. \\] Hay igualdad cuando $n=p-q-1$; evitar esa igualdad si se desea solo crecimiento y decrecimiento eligiendo $p$ no entero.",
            },
            {
                "family_index": 4,
                "generator_key": "seq_root_monotonicity_bound",
                "title": "Monotonía y acotación de una raíz",
                "prompt": "Pedir racionalizar, probar monotonía, determinar cotas y anticipar el límite.",
                "template_latex": "d_n=\\sqrt{n+s}-\\sqrt{n+r},\\qquad s>r.",
                "conditions": "$r\\geq0$, $1\\leq s-r\\leq6$ y $r,s\\leq8$.",
                "params": [{"name": "r", **INT}, {"name": "s", **INT}],
                "tuples": [T(0, 3), T(1, 5), T(2, 6), T(4, 7)],
                "control_latex": "\\[ d_n=\\frac{s-r}{\\sqrt{n+s}+\\sqrt{n+r}}, \\] por lo que es positiva, decreciente y converge a $0$.",
            },
            {
                "family_index": 5,
                "generator_key": "seq_hidden_dominant_power_limit",
                "title": "Límite con potencia dominante oculta",
                "prompt": "Pedir factorizar la potencia dominante y calcular el límite.",
                "template_latex": "\\[ e_n=\\ln\\!\\left(A\\lambda^n+B\\mu^n\\right)-n\\ln\\lambda, \\qquad \\lambda>\\mu>0. \\]",
                "conditions": "$A,B\\in\\{1,2,3,4\\}$, $(\\lambda,\\mu)$ en $\\{(3,2),(4,2),(4,3),(5,2)\\}$ y argumentos positivos.",
                "params": [{"name": "A", **INT}, {"name": "B", **INT}, {"name": "lambda", **INT}, {"name": "mu", **INT}],
                "tuples": [T(A, B, lam, mu)
                           for A in (1, 2, 3, 4)
                           for B in (1, 2, 3, 4)
                           for (lam, mu) in ((3, 2), (4, 2), (4, 3), (5, 2))],
                "control_latex": "\\[ e_n=\\ln\\!\\left(A+B(\\mu/\\lambda)^n\\right) \\longrightarrow\\ln A. \\] Para evitar respuesta nula, escoger $A\\neq1$.",
            },
            {
                "family_index": 6,
                "generator_key": "seq_heron_iteration",
                "title": "Iteración de Herón",
                "prompt": "Pedir probar positividad, acotación, monotonía y convergencia.",
                "template_latex": "x_1=u,\\qquad x_{n+1}=\\frac12\\left(x_n+\\frac{Q}{x_n}\\right).",
                "conditions": "$Q$ no cuadrado perfecto, $Q\\in\\{2,3,5,6,7\\}$ y $u$ entero con $u>\\sqrt Q$, procurando $u^2-Q\\leq6$.",
                "params": [{"name": "Q", **INT}, {"name": "u", **INT}],
                "tuples": [T(2, 2), T(3, 2), T(5, 3), T(6, 3), T(7, 3)],
                "control_latex": "para $n\\geq2$, $x_n\\geq\\sqrt Q$; la sucesión decrece y $\\lim x_n=\\sqrt Q$.",
            },
            {
                "family_index": 7,
                "generator_key": "seq_subsequence_convergence",
                "title": "Convergencia o divergencia mediante subsucesiones",
                "prompt": "Pedir estudiar las subsucesiones pares e impares y decidir convergencia.",
                "template_latex": "y_n=A+B(-1)^n+\\frac{C}{n}.",
                "conditions": "$A,C\\in\\mathbb Z$, $B\\in\\{-3,-2,-1,1,2,3\\}$, $|A|,|C|\\leq5$. Mantener $B\\neq0$ para garantizar dos límites distintos.",
                "params": [{"name": "A", **INT}, {"name": "B", **INT}, {"name": "C", **INT}],
                "tuples": [T(1, 1, 2), T(2, -1, 3), T(-1, 2, 1), T(0, -2, 5)],
                "control_latex": "\\[ y_{2n}\\longrightarrow A+B, \\qquad y_{2n-1}\\longrightarrow A-B; \\] por tanto, $(y_n)$ diverge.",
            },
        ],
    },
]


def main():
    levels_out = []
    for lv in LEVELS:
        tex = read_tex(lv["key"], lv["stem"])
        title, subtitle, intro = doc_header(tex)
        levels_out.append({
            "key": lv["key"],
            "label": lv["label"],
            "doc_title": title,
            "doc_subtitle": subtitle,
            "intro": intro,
            "seconds_per_question": lv["seconds_per_question"],
            "families": lv["families"],
        })
    doc = {
        "schema_version": 1,
        "generated_by": "tools/extract_parametros.py",
        "course": "Cálculo Diferencial",
        "content": "Sucesiones y Límites",
        "levels": levels_out,
    }
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(doc, fh, ensure_ascii=False, indent=2)
        fh.write("\n")
    n_fam = sum(len(l["families"]) for l in levels_out)
    n_tup = sum(len(f["tuples"]) for l in levels_out for f in l["families"])
    print(f"OK: {len(levels_out)} niveles, {n_fam} familias, {n_tup} tuplas -> {OUT}")


if __name__ == "__main__":
    main()
