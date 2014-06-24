@echo off
echo Scanworks 7 SQL Installation
echo *********************************************************
echo Enter Appowner:
set /p username=
echo Enter Password:
set /p password=
echo Enter Database:
set /p database=

sqlplus %username%/%password%@%database% @Install.sql %username%
sqlldr %username%/%password%@%database% control=icons.ctl log=icons.log bad=icons.bad
sqlplus %username%/%password%@%database% @InstallData.sql 
REM sqlplus ensync/ensync@%database% @Ensync.sql %username%
