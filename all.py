#!/usr/bin/python3
import os
import glob

if not os.path.isdir("local"):
    os.mkdir("local")

features = [
    'common',
    'common_lin',
    'colemak',
    'dev',
    'local'
]

for feature in features:
    print("\nProcessing", feature)
    prefix = feature + "/"
    for f in glob.glob(feature + "/**", recursive=True):
        newPath = f.replace(prefix, "out/")

        lastSlash = newPath.rfind('/') + 1
        if len(newPath) != lastSlash and newPath[lastSlash] == '_':
            newPath = newPath[:lastSlash] + '.' + newPath[lastSlash+1:]

        if not os.path.isfile(f):
            if not os.path.isdir(newPath):
                os.mkdir(newPath)
            continue

        print("   ", f, ">", newPath)
        with open(newPath, "ab") as newFile:
            with open(f, "rb") as source:
                newFile.write(source.read())

os.system("vim +PlugClean +PlugInstall +qall")

