@echo off
sxstrace trace -logfile:sxs.etl
sxstrace parse -logfile:sxs.etl -outfile:sxs.txt
del sxs.etl

