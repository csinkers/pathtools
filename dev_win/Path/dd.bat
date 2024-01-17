@echo off
:: Debug Docker container

if %1x==x goto usage

docker exec -it -u 0 %1 apt-get update
docker exec -it -u 0 %1 apt-get install htop net-tools vim
docker exec -it -u 0 %1 /bin/bash
goto end

:usage
echo Usage: dd <container_name>
:end
