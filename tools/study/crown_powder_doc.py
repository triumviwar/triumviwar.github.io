#!/usr/bin/env python3
"""(crown-powder-study) put the study's tables into docs/crown_powder_study.md between its REPORT markers."""
import os, subprocess, sys, re
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
rep = subprocess.run([sys.executable, os.path.join(ROOT, "tools/study/crown_powder_study.py"), "report"], capture_output=True, text=True).stdout.strip()
f = os.path.join(ROOT, "docs/crown_powder_study.md")
s = open(f).read()
block = "<!-- REPORT -->\n" + rep + "\n<!-- /REPORT -->"
if "<!-- REPORT -->" in s:
    s = re.sub(r"<!-- REPORT -->.*?<!-- /REPORT -->", lambda m: block, s, flags=re.S)
else:
    s = s.replace("\nREPORT\n", "\n" + block + "\n")
open(f, "w").write(s)
print("ok")
