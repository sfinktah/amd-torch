@echo off
set PYTHON="../../venv/Scripts/python.exe"
SETLOCAL ENABLEDELAYEDEXPANSION
cd custom_nodes
echo Cleaning up compiled Python files...

REM Delete __pycache__ folders
FOR /D /R %%F IN (__pycache__) DO (
    rem echo Deleting folder: %%F
    rmdir /S /Q "%%F" >NUL 2>NUL
)

REM Delete .pyc and .pyo files
FOR /R %%F IN (*.pyc *.pyo) DO (
    rem echo Deleting file: %%F
    del /F /Q "%%F" >NUL 2>NUL
)

echo.
echo Searching for requirements.txt files...

FOR /D %%D IN (*) DO (
    IF EXIST "%%D\requirements.txt" (
        echo ----------------------------------------------------
        echo Found: %%D\requirements.txt
        echo Installing requirements in: %%D
        pushd "%%D"
        %PYTHON% -m pip install -r requirements.txt
        popd
    )
)

echo.
echo All done.
