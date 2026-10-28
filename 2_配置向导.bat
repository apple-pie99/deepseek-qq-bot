@echo off
chcp 65001 >nul
title DeepSeek QQ Bot - 配置向导
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lib\wizard.ps1" -PackRoot "%~dp0"
echo.
pause