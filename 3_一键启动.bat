@echo off
chcp 65001 >nul
title DeepSeek QQ Bot - 启动
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lib\start.ps1" -PackRoot "%~dp0"
echo.
pause