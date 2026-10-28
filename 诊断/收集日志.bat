@echo off
chcp 65001 >nul
title 收集诊断日志
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\lib\collectlogs.ps1" -PackRoot "%~dp0.."
echo.
pause