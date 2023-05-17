@for /F "usebackq tokens=*" %%i in (`dir /b *.sln`) do @devenv %%i /Build Debug | tee build.log
