@for /F "usebackq tokens=*" %%i in (`dir /b *.sln`) do @devenv %%i /Build Release | tee build.log
