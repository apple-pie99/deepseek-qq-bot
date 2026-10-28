@echo off
chcp 65001 >nul
title 下载依赖
echo 将开始下载 AstrBot 与 NapCat，请保持网络畅通。
echo 如果你用 Clash Verge 且端口不是 7890，请右键本文件用记事本编辑最后一行。
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\lib\fetch.ps1" -PackRoot "%~dp0.."
echo.
pause