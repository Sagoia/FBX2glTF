@echo off 

REM GIT SUBMODULE
cd lib

REM DRACO
START /WAIT git.exe submodule update --progress --init -- "draco"
cd draco

mkdir build
cd build

cmake .. -G "Visual Studio 16 2019" -A Win32

set buildconfig=%1

if "%VSWHERE%"=="" set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
    set InstallDir=%%i
)

if exist "%InstallDir%\MSBuild\Current\Bin\MSBuild.exe" (
    if %buildconfig%==1 "%InstallDir%\MSBuild\Current\Bin\MSBuild.exe" draco.sln /p:configuration=Release
    if %buildconfig%==2 "%InstallDir%\MSBuild\Current\Bin\MSBuild.exe" draco.sln /p:configuration=Debug
)

REM GIT SUBMODULE
cd ../..
START /WAIT git.exe submodule update --progress --init -- "mathfu"
START /WAIT git.exe submodule update --progress --init -- "vectorial"

REM VCPKG LIBS
START /WAIT vcpkg install --triplet x86-windows boost-filesystem:x86-windows boost-optional:x86-windows nlohmann-fifo-map nlohmann-json stb fmt cppcodec
