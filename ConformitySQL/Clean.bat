@echo off
echo Scanworks 7 SQL Cleaner
echo *********************************************************
echo Enter Appowner:
set /p username=
echo Enter Password:
set /p password=
echo Enter Database:
set /p database=

sqlplus %username%/%password%@%database% @Clean.sql %username%

exit