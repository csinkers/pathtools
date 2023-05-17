@if x%2 == x (dir /s /b | findstr /rimf:/ %1) else (dir /s /b %1 | findstr /rimf:/ %2)
