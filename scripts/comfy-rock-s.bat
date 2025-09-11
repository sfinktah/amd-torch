@echo off
setlocal ENABLEDELAYEDEXPANSION

:: replace {{TRITON_OVERRIDE_ARCH}} with your gfx1234 type code
set TRITON_OVERRIDE_ARCH={{TRITON_OVERRIDE_ARCH}}
:: replace {{HIP_PATH}} with the path to HIP 6.5 (with a trailing \)
set HIP_PATH={{HIP_PATH}}
set HIP_PATH_62=%HIP_PATH%
set HIP_PATH_65=%HIP_PATH%
set CC=%HIP_PATH%bin\clang.exe
set CXX=%HIP_PATH%bin\clang++.exe
set CXXFLAGS=-march=native -mtune=native

set "NEW_ENTRY=%HIP_PATH%bin"
set "CLEANED_PATH="

:: Loop over PATH entries and exclude any that contain AMD\ROCm (case-insensitive)
for %%P in ("%PATH:;=";"%") do (
    set "PART=%%~P"
    echo !PART! | find /I "AMD\ROCm" >nul
    if errorlevel 1 (
        if defined CLEANED_PATH (
            set "CLEANED_PATH=!CLEANED_PATH!;!PART!"
        ) else (
            set "CLEANED_PATH=!PART!"
        )
    )
)

:: Now prepend NEW_ENTRY
set "PATH=%NEW_ENTRY%;%CLEANED_PATH%"

:: Confirm result
echo Final PATH:
echo %PATH%

set COMFYUI_PATH=%~dp0
set COMFYUI_MODEL_PATH=%~dp0models
set TRITON_PRINT_AUTOTUNING=1
set TRITON_CACHE_AUTOTUNING=1
set MIOPEN_FIND_MODE=2
set MIOPEN_LOG_LEVEL=3
:: Only works for RDNA3 or better
set PYTORCH_TUNABLEOP_ENABLED=1
set MIOPEN_FIND_MODE=FAST
set SAGE_BM_SIZE=32
set SAGE_BN_SIZE=16
set SAGE_ATTENTION_BLOCK_M=32
set SAGE_ATTENTION_BLOCK_N=16
set SAGE_ATTENTION_NUM_WARPS={2,4}
set SAGE_ATTENTION_NUM_STAGES=1
set SAGE_ATTENTION_WAVES_PER_EU={3,4}


:: Enabling this will cause rocm's amd triton flash-attn to look for CDNA optimisations (we have RDNA, so it will fail -- unless we patch flash attention of course :)
:: TODO - include flash-attention with patches
set FLASH_ATTENTION_TRITON_AMD_AUTOTUNE=TRUE
set FLASH_ATTENTION_TRITON_AMD_ENABLE=TRUE
set FLASH_ATTENTION_TRITON_AMD_PERF=TRUE

set PYTHON="%~dp0/venv/Scripts/python.exe"
set COMMANDLINE_ARGS=%*

echo.
%PYTHON% main.py %COMMANDLINE_ARGS%
pause
