@echo off
if "%1"=="" (
    echo Please provide the parent path as an argument
    echo Example: link.bat C:\zluda\comfyui-zluda
    exit /b 1
)

rmdir /S /Q models 2>nul
rmdir /S /Q input 2>nul
rmdir /S /Q output 2>nul
rmdir /S /Q user 2>nul
mklink /J "models" "%1\models" 
mklink /J "input"  "%1\input"  
mklink /J "output" "%1\output" 
mklink /J "user"   "%1\user"
