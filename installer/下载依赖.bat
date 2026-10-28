@echo off
chcp 65001 >nul
title 下载依赖
echo 将开始下载 AstrBot 与 NapCat，请保持网络畅通。
echo 脚本会自动试探常见代理端口（7890 / 7897 / 10809 / 1080）；都不通时，右键本文件编辑最后一行，加上 -ProxyUrl 参数。
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\lib\fetch.ps1" -PackRoot "%~dp0.."
echo.
pause