@echo off

rem ----
rem -- Install comfyui by runing
rem --   git clone https://github.com/comfyanonymous/ComfyUI <optional name if you don't want it to be ComfyUI obviously>
rem -- Then run this Script (I keep it in the parent directory, but doesn't make any difference)
rem -- NOTE: The paths to the wheels will probably change, but that's your problem :)
rem ----

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
rem echo  ::  %time:~0,8%  ::  - Installing onnxruntime (required by some nodes)
rem pip install onnxruntime --quiet

echo  ::  %time:~0,8%  ::  - Detecting Python version and installing appropriate triton package
for /f "tokens=2 delims=." %%a in ('python -c "import sys; print(sys.version)"') do (
    set "PY_MINOR=%%a"
    goto :version_detected
)
:version_detected

echo  ::  %time:~0,8%  ::  - Installing torch AMD 
pip uninstall torch torchvision torchaudio -y --quiet
if "%PY_MINOR%"=="11" (
    echo  ::  %time:~0,8%  ::  - Python 3.11 detected
    pip install ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torch-2.7.0a0+rocm_git3f903c3-cp311-cp311-win_amd64.whl ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchaudio-2.7.0a0+52638ef-cp311-cp311-win_amd64.whl ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchvision-0.22.0+9eb57cd-cp311-cp311-win_amd64.whl
) else if "%PY_MINOR%"=="12" (
    echo  ::  %time:~0,8%  ::  - Python 3.12 detected
    pip install ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torch-2.7.0a0+git3f903c3-cp312-cp312-win_amd64.whl ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchaudio-2.6.0a0+1a8f621-cp312-cp312-win_amd64.whl ^
        https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchvision-0.22.0+9eb57cd-cp312-cp312-win_amd64.whl
) else (
    echo  ::  %time:~0,8%  ::  - WARNING: Unsupported Python version 3.%PY_MINOR%, skipping triton installation
    echo  ::  %time:~0,8%  ::  - Full version string: 
    python -c "import sys; print(sys.version)"
)

echo.
echo  ::  %time:~0,8%  ::  - Installing Comfyui Manager
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git --quiet
echo  ::  %time:~0,8%  ::  - Installing ComfyUI-deepcache
git clone https://github.com/styler00dollar/ComfyUI-deepcache.git --quiet
git clone --branch sfink-opacity https://github.com/sfinktah/ComfyUI-TextOverlay.git --quiet
cd ..
echo. 

echo  ::  %time:~0,8%  ::  - Done
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
python main.py --auto-launch --use-pytorch-cross-attention
