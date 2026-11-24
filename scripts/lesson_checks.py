#!/usr/bin/env python3
"""Lesson checks for the RTMB Cookbook (Carpentries Workbench R Markdown).

Checks each episode for: fenced-div balance and blank lines around fences,
challenge/solution pairing, words to avoid in prose, plotting chunks without
fig.alt, duplicate headings, and the timing budget.
Usage, from the lesson root: python3 scripts/lesson_checks.py .
"""
import re, sys, glob, os

AVOID = [r"\bsimpl[ey]\b", r"\beas(y|ily)\b", r"\bobviously\b", r"\bclearly\b",
         r"\bof course\b", r"\btrivial(ly)?\b", r"\bstraightforward\b", r"\bjust\b"]
PLOT_RE = re.compile(r"\b(ggplot|plot|hist|barplot|boxplot)\s*\(")

def check_file(path):
    problems = []
    lines = open(path, encoding="utf-8").read().split("\n")
    in_chunk = False
    chunk_header = None
    chunk_body = []
    stack = []          # open div names
    challenge_has_solution = []
    headings = {}
    teaching = exercises = None
    for i, line in enumerate(lines, 1):
        m = re.match(r"^(teaching|exercises):\s*(\d+)", line)
        if m and i < 10:
            if m.group(1) == "teaching": teaching = int(m.group(2))
            else: exercises = int(m.group(2))
        if line.startswith("```"):
            if not in_chunk:
                in_chunk = True
                chunk_header = (i, line)
                chunk_body = []
            else:
                # closing fence: check plotting chunk has fig.alt
                hdr = chunk_header[1]
                body = "\n".join(chunk_body)
                if hdr.startswith("```{r") and PLOT_RE.search(body) and "eval=FALSE" not in hdr.replace(" ", "") \
                        and "fig.alt" not in hdr and "include=FALSE" not in hdr.replace(" ", ""):
                    problems.append((chunk_header[0], "plotting chunk without fig.alt"))
                in_chunk = False
            continue
        if in_chunk:
            chunk_body.append(line)
            continue
        # fenced divs
        m = re.match(r"^(:{3,})\s*(\w*)\s*$", line)
        if m:
            name = m.group(2)
            prev_blank = (i == 1) or lines[i - 2].strip() == ""
            next_blank = (i >= len(lines)) or lines[i].strip() == ""
            if not prev_blank or not next_blank:
                problems.append((i, f"fence '{line.strip()[:20]}' needs blank lines before and after"))
            if name:
                stack.append((name, i))
                if name == "challenge":
                    challenge_has_solution.append([i, False])
                if name == "solution" and challenge_has_solution:
                    challenge_has_solution[-1][1] = True
            else:
                if not stack:
                    problems.append((i, "closing fence with no open div"))
                else:
                    stack.pop()
            continue
        # headings
        m = re.match(r"^(#{2,6})\s+(.*)$", line)
        if m:
            h = m.group(2).strip()
            if h in headings:
                problems.append((i, f"duplicate heading '{h}' (also line {headings[h]})"))
            else:
                headings[h] = i
        # words to avoid, in prose only (strip inline code)
        prose = re.sub(r"`[^`]*`", "", line)
        for pat in AVOID:
            for mm in re.finditer(pat, prose, flags=re.I):
                problems.append((i, f"word to avoid: '{mm.group(0)}'"))
    if stack:
        for name, ln in stack:
            problems.append((ln, f"div '{name}' never closed"))
    for ln, ok in challenge_has_solution:
        if not ok:
            problems.append((ln, "challenge without a solution"))
    return teaching, exercises, problems

def main(root):
    files = sorted(glob.glob(os.path.join(root, "episodes", "*.Rmd")))
    tot_t = tot_e = 0
    print(f"{'episode':30s} {'teach':>5s} {'exer':>5s}  problems")
    allp = 0
    for f in files:
        t, e, probs = check_file(f)
        tot_t += t or 0; tot_e += e or 0
        print(f"{os.path.basename(f):30s} {t or 0:5d} {e or 0:5d}  {len(probs)}")
        for ln, msg in probs:
            print(f"    {os.path.basename(f)}:{ln}: {msg}")
        allp += len(probs)
    print(f"{'TOTAL (minutes)':30s} {tot_t:5d} {tot_e:5d}  = {tot_t + tot_e} min = {(tot_t + tot_e)/60:.1f} h")
    print(f"problems: {allp}")
    # pages: divs and words only
    for f in sorted(glob.glob(os.path.join(root, "learners", "*.md")) + glob.glob(os.path.join(root, "instructors", "*.md"))
                    + glob.glob(os.path.join(root, "profiles", "*.md")) + [os.path.join(root, "index.md")]):
        _, _, probs = check_file(f)
        if probs:
            print(f"{os.path.relpath(f, root)}: {len(probs)} problems")
            for ln, msg in probs:
                print(f"    {os.path.relpath(f, root)}:{ln}: {msg}")

if __name__ == "__main__":
    main(sys.argv[1])
