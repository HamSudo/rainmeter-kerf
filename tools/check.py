"""Static checks for the Kerf skin. Run from the repository root:

    python tools/check.py

Exits non-zero when something is wrong, so CI can stop on it.
Needs `pip install luaparser` for the Lua syntax check.
"""

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIN = os.path.join(ROOT, 'Skins', 'Kerf')
RES = os.path.join(SKIN, '@Resources')

problems = []


def rel(path):
    return os.path.relpath(path, ROOT).replace(os.sep, '/')


def read_utf16(path):
    raw = open(path, 'rb').read()
    if raw[:2] != b'\xff\xfe':
        problems.append('%s: not UTF-16 LE with BOM (Rainmeter needs it; check .gitattributes)' % rel(path))
        return raw.decode('utf-8', 'replace')
    return raw[2:].decode('utf-16-le').replace('\r\n', '\n')


def sections(text):
    return set(re.findall(r'(?m)^\[([^\]]+)\]', text))


# every .ini / .inc, decoded
texts = {}
for folder, _, files in os.walk(SKIN):
    for name in files:
        if name.endswith(('.ini', '.inc')):
            path = os.path.join(folder, name)
            texts[path] = read_utf16(path)

# Lua syntax
try:
    from luaparser import ast
except ImportError:
    sys.exit('luaparser is missing: pip install luaparser')
scripts = os.path.join(RES, 'Scripts')
for name in sorted(os.listdir(scripts)):
    if name.endswith('.lua'):
        path = os.path.join(scripts, name)
        try:
            ast.parse(open(path, encoding='utf-8-sig').read())
        except Exception as e:
            problems.append('%s: %s' % (rel(path), str(e).splitlines()[0][:160]))

# each skin, with everything it includes
for path, text in texts.items():
    if not path.endswith('.ini'):
        continue
    full = text
    for inc in re.findall(r'(?m)^@Include\w*=#@#(\S+)', text):
        inc = re.sub(r'#\w+#', '0', inc)
        target = os.path.join(RES, inc.replace('\\', os.sep))
        if not os.path.exists(target):
            problems.append('%s: @Include of missing %s' % (rel(path), inc))
        else:
            full += '\n' + texts.get(target, '')
    known = sections(full)

    for ref in set(re.findall(r'\[([A-Za-z_]\w*):[A-Z]*\]', full)):
        if ref not in known:
            problems.append('%s: [%s:...] refers to no section' % (rel(path), ref))
    for key in ('MeasureName\\d*', 'MeterStyle', 'Parent'):
        for value in re.findall(r'(?m)^' + key + r'=(.+)$', full):
            for part in value.split('|'):
                part = part.strip()
                if part and not part.startswith(('#', '[')) and part not in known:
                    problems.append('%s: %s=%s is not defined' % (rel(path), key.replace('\\d*', ''), part))
    for script in set(re.findall(r'(?m)^ScriptFile=#@#(\S+)', full)):
        if not os.path.exists(os.path.join(RES, script.replace('\\', os.sep))):
            problems.append('%s: ScriptFile %s is missing' % (rel(path), script))

# every panel button calls a function Settings.lua defines
panel = os.path.join(SKIN, 'Settings', 'Settings.ini')
lua = open(os.path.join(scripts, 'Settings.lua'), encoding='utf-8-sig').read()
for fn in sorted(set(re.findall(r'mSet "(\w+)\(', texts.get(panel, '')))):
    if not re.search(r'(?m)^function %s\(' % fn, lua):
        problems.append('Settings.ini calls %s(), which Settings.lua does not define' % fn)

# the helper's source must be there for the build to compile it
if not os.path.exists(os.path.join(RES, 'Bin', 'KerfSensors.cs')):
    problems.append('@Resources/Bin/KerfSensors.cs is missing')

if problems:
    print('\n'.join(sorted(set(problems))))
    sys.exit('%d problem(s)' % len(set(problems)))
print('ok: %d skin files, %d scripts' % (len(texts), len([n for n in os.listdir(scripts) if n.endswith('.lua')])))
