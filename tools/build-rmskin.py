"""Build dist/Kerf-<version>.rmskin.

Usage: python tools/build-rmskin.py 1.0.0 [repo folder]
"""

import os
import shutil
import struct
import subprocess
import sys
import tempfile
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VENDOR = os.path.join(ROOT, 'vendor', 'chameleon')
CSC = os.path.join(os.environ.get('WINDIR', r'C:\Windows'), 'Microsoft.NET', 'Framework64', 'v4.0.30319', 'csc.exe')
SKIP_FILES = {'cyber track.otf', 'track.ttf'}
SKIP_EXT = {'.exe', '.log', '.pdb'}

RMSKIN_INI = """[rmskin]
Name=Kerf
Author=HamSudo
Version={version}
MinimumRainmeter=4.5.0.0
MinimumWindows=10.0
LoadType=Skin
Load=Kerf\\Clock\\Clock.ini
VariableFiles={variables}
"""


def stage_skin(stage, skin_dir):
    target = os.path.join(stage, 'Skins', 'Kerf')
    for folder, _, files in os.walk(skin_dir):
        rel = os.path.relpath(folder, skin_dir)
        for name in files:
            if name.lower() in SKIP_FILES or os.path.splitext(name)[1].lower() in SKIP_EXT:
                continue
            dest = os.path.join(target, rel)
            os.makedirs(dest, exist_ok=True)
            shutil.copy2(os.path.join(folder, name), dest)
    return target


WINDIR = os.environ.get('WINDIR', r'C:\Windows')
# the helper reads the Windows media session, which means WinRT: the metadata
# ships with Windows itself and the facade with .NET Framework, so no SDK
WINMD = os.path.join(WINDIR, 'System32', 'WinMetadata')
REFS = ['System.Drawing.dll',
        os.path.join(WINMD, 'Windows.Foundation.winmd'),
        os.path.join(WINMD, 'Windows.Media.winmd'),
        os.path.join(WINMD, 'Windows.Storage.winmd'),
        os.path.join(WINDIR, 'Microsoft.NET', 'assembly', 'GAC_MSIL', 'System.Runtime',
                     'v4.0_4.0.0.0__b03f5f7f11d50a3a', 'System.Runtime.dll')]


def build_helper(skin):
    bin_dir = os.path.join(skin, '@Resources', 'Bin')
    source = os.path.join(bin_dir, 'KerfSensors.cs')
    exe = os.path.join(bin_dir, 'KerfSensors.exe')
    subprocess.run([CSC, '/nologo', '/target:winexe', '/optimize']
                   + ['/r:' + r for r in REFS]
                   + ['/out:' + exe, source], check=True)


def main():
    if len(sys.argv) not in (2, 3):
        sys.exit(__doc__)
    version = sys.argv[1]
    root = os.path.abspath(sys.argv[2]) if len(sys.argv) == 3 else ROOT
    skin_dir = os.path.join(root, 'Skins', 'Kerf')
    DIST = os.path.join(root, 'dist')
    os.makedirs(DIST, exist_ok=True)
    keep = [f for f in ('Variables.inc', 'Modules.inc') if os.path.exists(os.path.join(skin_dir, '@Resources', f))]
    variables = '|'.join('Kerf\\@Resources\\' + f for f in keep)
    out = os.path.join(DIST, 'Kerf-%s.rmskin' % version)

    with tempfile.TemporaryDirectory() as stage:
        skin = stage_skin(stage, skin_dir)
        build_helper(skin)
        for arch in ('32bit', '64bit'):
            dest = os.path.join(stage, 'Plugins', arch)
            os.makedirs(dest)
            shutil.copy2(os.path.join(VENDOR, arch, 'Chameleon.dll'), dest)
        with open(os.path.join(stage, 'RMSKIN.ini'), 'w', newline='\r\n', encoding='ascii') as f:
            f.write(RMSKIN_INI.format(version=version, variables=variables))

        with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
            z.write(os.path.join(stage, 'RMSKIN.ini'), 'RMSKIN.ini')
            for folder, _, files in os.walk(stage):
                for name in sorted(files):
                    path = os.path.join(folder, name)
                    rel = os.path.relpath(path, stage).replace(os.sep, '/')
                    if rel != 'RMSKIN.ini':
                        z.write(path, rel)

    size = os.path.getsize(out)
    with open(out, 'ab') as f:
        f.write(struct.pack('<qB7s', size, 0, b'RMSKIN\0'))
    print(out)


if __name__ == '__main__':
    main()
