@echo off

rem ----
rem -- Install comfyui by runing
rem --   git clone https://github.com/comfyanonymous/ComfyUI <optional name if you don't want it to be ComfyUI obviously>
rem -- Then run this Script (keep it in the root directory of ComfyUI directory)
rem -- NOTE: The paths to the wheels will probably change (though they haven't for a long time), update if you can :)
rem ----
set HIP_SDK_DIR=C:\Program Files\AMD\ROCm\6.5
set HIP_PATH=C:\Program Files\AMD\ROCm\6.5\

title ComfyUI-Rock Installer

setlocal EnableDelayedExpansion
set "startTime=%time: =0%"

echo ---------------------------------------------------------------
Echo * COMFYUI-ROCK INSTALL (pytorch 2.7, python 3.11 or 3.12)     *
echo ---------------------------------------------------------------
echo.
echo  ::  %time:~0,8%  ::  - Setting up the virtual enviroment
Set "VIRTUAL_ENV=venv"
If Not Exist "%VIRTUAL_ENV%\Scripts\activate.bat" (
    python.exe -m venv %VIRTUAL_ENV%
)

If Not Exist "%VIRTUAL_ENV%\Scripts\activate.bat" Exit /B 1

echo  ::  %time:~0,8%  ::  - Virtual enviroment activation
Call "%VIRTUAL_ENV%\Scripts\activate.bat"
echo  ::  %time:~0,8%  ::  - Updating the pip package 
python.exe -m pip install --upgrade pip --quiet
echo.
echo  ::  %time:~0,8%  ::  Beginning installation ...
echo.
echo  ::  %time:~0,8%  ::  - Installing required packages
pip install -r requirements.txt --quiet
pip install "numpy==1.*" --quiet
rem echo  ::  %time:~0,8%  ::  - Installing onnxruntime (required by some nodes)
rem pip install onnxruntime --quiet

echo  ::  %time:~0,8%  ::  - Detecting Python version and installing appropriate triton package
for /f "tokens=2 delims=." %%a in ('python -c "import sys; print(sys.version)"') do (
    set "PY_MINOR=%%a"
    goto :version_detected
)
:version_detected

echo  ::  %time:~0,8%  ::  - Installing torch AMD 
if "%PY_MINOR%"=="11" (
    echo  ::  %time:~0,8%  ::  - Python 3.11 detected
    pip install --force-reinstall ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torch-2.7.0a0+rocm_git3f903c3-cp311-cp311-win_amd64.whl ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchaudio-2.7.0a0+52638ef-cp311-cp311-win_amd64.whl ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchvision-0.22.0+9eb57cd-cp311-cp311-win_amd64.whl
    echo  ::  %time:~0,8%  ::  - Installing triton AMD
    pip install --force-reinstall https://github.com/lshqqytiger/triton/releases/download/a9c80202/triton-3.4.0+gita9c80202-cp311-cp311-win_amd64.whl
) else if "%PY_MINOR%"=="12" (
    echo  ::  %time:~0,8%  ::  - Python 3.12 detected
    pip install --force-reinstall ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torch-2.7.0a0+git3f903c3-cp312-cp312-win_amd64.whl ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchaudio-2.6.0a0+1a8f621-cp312-cp312-win_amd64.whl ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchvision-0.22.0+9eb57cd-cp312-cp312-win_amd64.whl
    echo  ::  %time:~0,8%  ::  - Installing triton AMD
    pip install --force-reinstall https://github.com/lshqqytiger/triton/releases/download/a9c80202/triton-3.4.0+gita9c80202-cp312-cp312-win_amd64.whl
) else (
    echo  ::  %time:~0,8%  ::  - WARNING: Unsupported Python version 3.%PY_MINOR%, skipping torch and triton installation
    echo  ::  %time:~0,8%  ::  - Full version string: 
    python -c "import sys; print(sys.version)"
)

echo  ::  %time:~0,8%  ::  - Patching torch and triton
pip install --upgrade pypatch-url --quiet
pypatch-url apply https://raw.githubusercontent.com/sfinktah/amd-torch/refs/heads/main/patches/triton-3.4.0+gita9c80202-cp311-cp311-win_amd64.patch -p 4 triton
pypatch-url apply https://raw.githubusercontent.com/sfinktah/amd-torch/refs/heads/main/patches/torch-2.7.0+cu118-cp311-cp311-win_amd64.patch -p 4 torch

echo  ::  %time:~0,8%  ::  - Installing sageattention
pip install braceexpand --quiet
pip install --force-reinstall sageattention==1.0.6 --quiet
pypatch-url apply https://raw.githubusercontent.com/sfinktah/amd-torch/refs/heads/main/patches/sageattention-1.0.6+sfinktah+env-py3-none-any.patch -p 4 sageattention

:: Step 13: Copy Python libs
echo  ::  %time:~0,8%  ::  - Adding python libs to venv folder
xcopy /E /I /Y "%LocalAppData%\Programs\Python\Python3%PY_MINOR%\libs" "venv\libs"
set ERRLEVEL=%errorlevel%
if %ERRLEVEL% neq 0 (
    echo "Failed to copy Python3%PY_MINOR%\libs to virtual environment."
    exit /b %ERRLEVEL%
)


echo.
echo  ::  %time:~0,8%  ::  - Installing Comfyui Manager
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git --quiet >null 2>&1
echo  ::  %time:~0,8%  ::  - Installing ComfyUI-deepcache
git clone https://github.com/styler00dollar/ComfyUI-deepcache.git --quiet >null 2>&1
cd ..
echo.

echo  ::  %time:~0,8%  ::  - Installing HIP SDK 6.5
:: Step 13b: Check if HIP SDK exists, otherwise download and extract it
set HIP_ZIP_PATH=%~dp0
set "HIP_SDK_PARENT=%HIP_SDK_DIR%"
for %%A in ("%HIP_SDK_PARENT%\.") do set "HIP_SDK_PARENT=%%~dpA"
if "%HIP_SDK_PARENT:~-1%"=="\" set "HIP_SDK_PARENT=%HIP_SDK_PARENT:~0,-1%"
set "TEST_FILE=%HIP_SDK_PARENT%\__write_test__.tmp"
echo HIP_SDK_DIR: %HIP_SDK_DIR%
echo HIP_SDK_PARENT: %HIP_SDK_PARENT%
echo HIP_ZIP_PATH: %HIP_ZIP_PATH%
if not exist "%HIP_SDK_DIR%\bin\clang.exe" (
    echo HIP SDK not found at %HIP_SDK_DIR%.
    if exist "%HIP_ZIP_PATH%" (
        echo Using previously downloaded file: %HIP_ZIP_PATH%
    ) else (
        echo Attempting to download...
        curl -o "%HIP_ZIP_PATH%" "%HIP_ZIP_URL%"
        set ERRLEVEL=!errorlevel!
        if !ERRLEVEL! neq 0 (
            echo "Failed to download HIP SDK archive."
            exit /b !ERRLEVEL!
        )
        if not exist "%HIP_ZIP_PATH%" (
            echo "HIP SDK archive not found after download attempt."
            exit /b 1
        )
    )

    :: --- Check write permission to HIP_SDK_PARENT ---
    :check_hip_write
    echo Checking write access to: %HIP_SDK_PARENT%

    :: Create test file
    echo Checking to see if we have write access to the SDK directory by writing to %TEST_FILE%
    break > "%TEST_FILE%" 2>nul
    set ERRLEVEL=%errorlevel%

    if %ERRLEVEL% neq 0 (
        echo We couldn't write to %TEST_FILE%
    )

    :: Try modifying it
    if exist "%TEST_FILE%" (
        >> "%TEST_FILE%" echo test >>nul 2>nul
        set MODIFY_ERR=!errorlevel!
        del "%TEST_FILE%" >nul 2>&1
    )

    :: Check create permission
    if %ERRLEVEL% neq 0 (
        echo [ERROR] Could not create test file in %HIP_SDK_PARENT%.
        goto :request_admin_fix
    )

    :: Check modify permission
    if defined MODIFY_ERR (
        if !MODIFY_ERR! neq 0 (
            echo [ERROR] Could not write to test file in %HIP_SDK_PARENT%.
            goto :request_admin_fix
        )
    )

    echo Write access confirmed.
    goto :hip_access_ok

    :request_admin_fix
    echo.
    echo You do not have write access to:
    echo     %HIP_SDK_PARENT%
    echo.
    echo To fix this, open an **Admin Command Prompt** and run:
    echo     takeown /f "%HIP_SDK_PARENT%" /r /d y
    echo     icacls "%HIP_SDK_PARENT%" /grant "%USERNAME%:F" /t
    echo.
    pause
    goto check_hip_write

    :hip_access_ok
    :: --- Extract the HIP SDK using tar ---
    echo Extracting HIP SDK archive using tar...  tar -xf "%HIP_ZIP_PATH%" -C "%HIP_SDK_PARENT%"
    tar -xf "%HIP_ZIP_PATH%" -C "%HIP_SDK_PARENT%"
    set ERRLEVEL=%errorlevel%
    if not %ERRLEVEL%==0 (
        echo [ERROR] Failed to extract HIP SDK archive using tar.
        exit /b %ERRLEVEL%
    )

    if not exist "%HIP_SDK_DIR%\bin\clang.exe" (
        echo HIP SDK not found at %HIP_SDK_DIR%, which is annoying, since we just put it there.
        exit /b 1
    )
) else (
    echo HIP SDK already exists at %HIP_SDK_DIR% -- skipping HIP SDK download.
)

echo  ::  %time:~0,8%  ::  - Performing GPU identification
set "GPU1="
set "GPU2="
set "GPUCOUNT=0"
for /f "delims=" %%A in ('"%HIP_PATH%bin\amdgpu-arch.exe"') do (
    set /a GPUCOUNT+=1
    if !GPUCOUNT! EQU 1 set "GPU1=%%A"
    if !GPUCOUNT! EQU 2 set "GPU2=%%A"
)
if !GPUCOUNT! LSS 1 (
    echo  ::  %time:~0,8%  ::  - WARNING: Unable to detect AMD GPU architecture.
) else if !GPUCOUNT! EQU 1 (
    set "TRITON_OVERRIDE_ARCH=!GPU1!"
    echo  ::  %time:~0,8%  ::  - Detected GPU architecture: !TRITON_OVERRIDE_ARCH!
) else (
    if !GPUCOUNT! GTR 2 (
        echo  ::  %time:~0,8%  ::  - OMG how many GPU do you have, I hate you so much.
        set "TRITON_OVERRIDE_ARCH=!GPU2!"
        echo  ::  %time:~0,8%  ::  - Selecting second architecture: !TRITON_OVERRIDE_ARCH!
    ) else (
        if /I "!GPU1!"=="!GPU2!" (
            echo  ::  %time:~0,8%  ::  - OMG how many GPU do you have, I hate you so much.
            set "TRITON_OVERRIDE_ARCH=!GPU2!"
            echo  ::  %time:~0,8%  ::  - Selecting second architecture: !TRITON_OVERRIDE_ARCH!
        ) else (
            rem Select the greater architecture (lexical) as the discrete GPU
            if /I "!GPU2!" GTR "!GPU1!" (
                echo  ::  %time:~0,8%  ::  - Detected integrated Radeon graphics: !GPU1! and discrete Radeon GPU: !GPU2!
                set "TRITON_OVERRIDE_ARCH=!GPU2!"
                echo  ::  %time:~0,8%  ::  - Selecting discrete GPU architecture: !TRITON_OVERRIDE_ARCH!
            ) else (
                echo  ::  %time:~0,8%  ::  - Detected integrated Radeon graphics: !GPU2! and discrete Radeon GPU: !GPU1!
                set "TRITON_OVERRIDE_ARCH=!GPU1!"
                echo  ::  %time:~0,8%  ::  - Selecting discrete GPU architecture: !TRITON_OVERRIDE_ARCH!
            )
        )
    )
)

echo  ::  %time:~0,8%  ::  - Detected %TRITON_OVERRIDE_ARCH%
echo  ::  %time:~0,8%  ::  - Done installing, performing test launch
echo. 
set "endTime=%time: =0%"
set "end=!endTime:%time:~8,1%=%%100)*100+1!"  &  set "start=!startTime:%time:~8,1%=%%100)*100+1!"
set /A "elap=((((10!end:%time:~2,1%=%%100)*60+1!%%100)-((((10!start:%time:~2,1%=%%100)*60+1!%%100), elap-=(elap>>31)*24*60*60*100"
set /A "cc=elap%%100+100,elap/=100,ss=elap%%60+100,elap/=60,mm=elap%%60+100,hh=elap/60+100"
echo ..................................................... 
echo *** Installation is completed in %hh:~1%%time:~2,1%%mm:~1%%time:~2,1%%ss:~1%%time:~8,1%%cc:~1% . 
echo ..................................................... 
echo.
echo.
python main.py --auto-launch --use-sage-attention
