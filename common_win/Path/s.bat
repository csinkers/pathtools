@if x%2 == x (dir /s /b | findstr /rinf:/ %1) else (dir /s /b %1 | findstr /rinf:/ %2)
