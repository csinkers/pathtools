@echo off
git config --global diff.tool bc3
git config --global merge.tool bc3
git config --global difftool.bc.path "C:\Program Files\Beyond Compare 4\BComp.exe"
git config --global mergetool.bc.path "C:\Program Files\Beyond Compare 4\BComp.exe"
git config --global difftool.prompt false
git config --global mergetool.keepBackup false

