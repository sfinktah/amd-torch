@echo off
setlocal ENABLEDELAYEDEXPANSION

set ROCM_VERSION=6.4
:: ** SET THIS
set TRITON_OVERRIDE_ARCH=gfx1100

:: set HIP_PATH=C:\Program Files\AMD\ROCm\%ROCM_VERSION%\
:: set HIP_PATH_62=
:: set HIP_PATH_62=
:: set HIP_PATH_65=%HIP_PATH%
set CC=%HIP_PATH%bin\clang.exe
set CXX=%HIP_PATH%bin\clang++.exe
set CXXFLAGS=-march=native -mtune=native


:: This is just for altering the cache names for quick tests.
set TEST_FACTOR=none

:: Fix for cublasLt errors on newer ZLUDA (if no hipblaslt)
set DISABLE_ADDMM_CUDA_LT=1

:: Example HIP_PATH (ensure it's set properly beforehand)
:: set "HIP_PATH=C:\Program Files\AMD\ROCm"

:: Normalize HIP_PATH to include trailing backslash if needed
if not "%HIP_PATH:~-1%"=="\" set "HIP_PATH=%HIP_PATH%\"

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

:: Get torch version
set "TORCH_VERSION="
for /f "tokens=2 delims=: " %%A in ('pip show torch 2^>nul ^| findstr /R "^Version"') do set "TORCH_VERSION=%%A"

if not defined TORCH_VERSION (
  set "TORCH_VERSION=NO_TORCH"
)

echo Torch version: %TORCH_VERSION%


if not defined TRITON_OVERRIDE_ARCH set TRITON_OVERRIDE_ARCH=gfx1100
echo Triton Architecture: %TRITON_OVERRIDE_ARCH%
set TRITON_CACHE_DIR=%~dp0/.triton-%TORCH_VERSION%-%ROCM_VERSION%-%TEST_FACTOR%
set TORCHINDUCTOR_CACHE_DIR=%~dp0/.inductor-%TORCH_VERSION%-%ROCM_VERSION%-%TEST_FACTOR%
set NUMBA_CACHE_DIR=%~dp0/.numba-%TORCH_VERSION%-%ROCM_VERSION%-%TEST_FACTOR%
set ZLUDA_CACHE_DIR=%~dp0/.zluda-%TORCH_VERSION%-%ROCM_VERSION%-%TEST_FACTOR%
:: these don't appear to do anything
set MIOPEN_CACHE_DIR=%~dp0/.miopen-%TORCH_VERSION%-%ROCM_VERSION%-%TEST_FACTOR%
set DEFAULT_CACHE_DIR=%~dp0/.default-cache-%TORCH_VERSION%-%ROCM_VERSION%-%TEST_FACTOR%
set CUPY_CACHE_DIR=%~dp0/.cupy-%TORCH_VERSION%-%ROCM_VERSION%-%TEST_FACTOR%


REM  set TRITON_CACHE_DIR=
REM  set MIOPEN_CACHE_DIR=
REM  set TORCHINDUCTOR_CACHE_DIR=
REM  set DEFAULT_CACHE_DIR=%~dp0/.default-cache

:: [@compile_ignored: debug]Verbose will print full stack traces on warnings and errors
:: set TORCHDYNAMO_VERBOSE=1

:: Suppress errors in torch._dynamo.optimize, instead forcing a fallback to eager.
:: This is a good way to get your model to work one way or another, but you may
:: lose optimization opportunities this way.  Devs, if your benchmark model is failing
:: this way, you should figure out why instead of suppressing it.
:: This flag is incompatible with: fail_on_recompile_limit_hit.
:: set TORCHDYNAMO_SUPPRESS_ERRORS=1

:: Disable dynamo
:: set TORCH_COMPILE_DISABLE=1

:: [@compile_ignored: runtime_behaviour] Get a cprofile trace of Dynamo
:: set TORCH_COMPILE_CPROFILE=1


:: Really excessive debugging for Triton
:: set AMDGCN_ENABLE_DUMP=1

:: Things you could hypothetically set to make a different (set to default values)
:: set TRITON_HIP_GLOBAL_PREFETCH=0
:: set TRITON_HIP_LOCAL_PREFETCH=0
:: set TRITON_HIP_USE_ASYNC_COPY=0
:: set TRITON_DEFAULT_FP_FUSION=1

:: These two are enabled for gfx942
:: set TRITON_HIP_USE_BLOCK_PINGPONG=0
:: set TRITON_HIP_USE_IN_THREAD_TRANSPOSE=0

:: set HSA_ENABLE_DEBUG=1
:: set ROCM_DUMP=1
:: :: set TORCH_LOGS=inductor,autotuning,recompiles
:: set TORCH_SHOW_CPP_STACKTRACES=1
:: set TRITON_CODEGEN_DEBUG=1
:: set TRITON_CODEGEN_DUMP_ASM=1
:: set TRITON_CODEGEN_DUMP_LLVM=1
:: set TRITON_DEBUG=0
:: set TRITON_PTXAS_VERBOSE=1

::  These are real and the TRITON_CACHE_AUTOTUNING is important (if you don't want to be tuning all the time)
set TRITON_PRINT_AUTOTUNING=1
set TRITON_CACHE_AUTOTUNING=1

:: Environment variables added to Triton by sfinktah, require appropriate triton patch.
:: python 3.12: pip install --force-reinstall https://github.com/lshqqytiger/triton/releases/download/a9c80202/triton-3.4.0+gita9c80202-cp312-cp312-win_amd64.whl
:: python 3.11: pip install --force-reinstall https://github.com/lshqqytiger/triton/releases/download/a9c80202/triton-3.4.0+gita9c80202-cp311-cp311-win_amd64.whl
:: pip install --force-reinstall pypatch-url --quiet
:: pypatch-url apply https://raw.githubusercontent.com/sfinktah/amd-torch/refs/heads/main/patches/triton-3.4.0+gita9c80202-cp311-cp311-win_amd64.patch -p 4 triton
:: set TRITON_DEFAULT_WAVES_PER_EU=4
:: end sfinktah Triton patches

:: Environment variables added to sageattention by sfinktah, require appropriate patch. (TODO: insert URL)
:: pip install --force-reinstall pypatch-url --quiet
:: pypatch-url apply https://raw.githubusercontent.com/sfinktah/amd-torch/refs/heads/main/patches/todo.patch -p 4 sageattention
:: set SAGE_BM_SIZE=64
:: set SAGE_BN_SIZE=16
:: set SAGE_ATTENTION_BLOCK_M=64
:: set SAGE_ATTENTION_BLOCK_N=16
:: set SAGE_ATTENTION_NUM_WARPS={2,4}
:: :: set SAGE_ATTENTION_NUM_STAGES={1,2,4}
:: set SAGE_ATTENTION_NUM_STAGES={1,3,4}
:: set SAGE_ATTENTION_STAGE=1
:: set SAGE_ATTENTION_WAVES_PER_EU={3,4}
:: end sfinktah sageattention patches

set MIOPEN_FIND_MODE=2
set MIOPEN_LOG_LEVEL=3

:: https://github.com/Beinsezii/comfyui-amd-go-fast
set PYTORCH_TUNABLEOP_ENABLED=1 
set MIOPEN_FIND_MODE=FAST

:: Enabling this will cause rocm's amd triton flash-attn to look for CDNA optimisations (we have RDNA, so it will fail -- unless we patch flash attention of course :)
set FLASH_ATTENTION_TRITON_AMD_AUTOTUNE=TRUE
set FLASH_ATTENTION_TRITON_AMD_ENABLE=TRUE

set FLASH_ATTENTION_TRITON_AMD_DEBUG=
set FLASH_ATTENTION_TRITON_AMD_PERF=TRUE


set PYTHON="%~dp0/venv/Scripts/python.exe"
set GIT=
set VENV_DIR=./venv

set COMMANDLINE_ARGS=%*

set ZLUDA_COMGR_LOG_LEVEL=1

echo *** Checking and updating to new version if possible

copy comfy\customzluda\zluda-default.py comfy\zluda.py /y >NUL
git pull
copy comfy\customzluda\zluda.py comfy\zluda.py /y >NUL

echo.
.\zluda\zluda.exe -- %PYTHON% main.py %COMMANDLINE_ARGS%
pause
