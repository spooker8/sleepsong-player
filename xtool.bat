@echo off
REM xtool wrapper script for Windows
REM This script runs xtool through WSL (Windows Subsystem for Linux)

REM Pass all arguments to xtool in WSL
wsl xtool %*
