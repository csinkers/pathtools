@echo off
git config --global diff.tool bc
git config --global difftool.bc.path "C:\Program Files (x86)\Beyond Compare 3\BComp.exe"

git config --global merge.tool bc
git config --global mergetool.bc.path "C:\Program Files (x86)\Beyond Compare 3\BComp.exe"

git config --global difftool.prompt false
git config --global mergetool.keepBackup false
