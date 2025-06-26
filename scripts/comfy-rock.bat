@echo off

set PYTHON="%~dp0/venv/Scripts/python.exe"
set VENV_DIR=./venv

rem set PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:512
set COMMANDLINE_ARGS=--reserve-vram 0.5 --use-pytorch-cross-attention %*


:loop
echo.
%PYTHON% main.py %COMMANDLINE_ARGS%
echo.

rem check if we exited with an error
if errorlevel 1 (
    echo exited with error code %errorlevel%
    pause
    exit /b %errorlevel%
)

echo Waiting 3 seconds before next run. Press any key to exit...
timeout /t 3 /nobreak > nul
if errorlevel 1 goto :eof

goto loop

