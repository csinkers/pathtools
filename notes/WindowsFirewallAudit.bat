@echo off
:: https://superuser.com/questions/1130078/how-to-tell-which-windows-firewall-rule-is-blocking-traffic

auditpol /set /subcategory:"Filtering Platform Packet Drop" /success:enable /failure:enable
auditpol /set /subcategory:"Filtering Platform Connection"  /success:enable /failure:enable

echo Repro, then press any key to stop tracing
pause

netsh wfp show filters
netsh wfp show state
auditpol /set /subcategory:"Filtering Platform Packet Drop" /success:disable /failure:disable
auditpol /set /subcategory:"Filtering Platform Connection"  /success:disable /failure:disable

echo Now check event viewer > Windows logs > Security

