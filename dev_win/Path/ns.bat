@echo off
if not exist .git goto perforce
git stash
git pull --rebase
git stash pop
goto end

:perforce
p4 sync ./...

:end
