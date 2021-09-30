@echo off 

cd lib

REM FBX SDK
if not exist fbxsdk\ (
    if not exist "%cd%\fbx20192_fbxsdk_vs2017_win.exe" (
        CALL bitsadmin /transfer fbx /download /priority FOREGROUND "https://damassets.autodesk.net/content/dam/autodesk/www/adn/fbx/20192/fbx20192_fbxsdk_vs2017_win.exe" "%cd%\fbx20192_fbxsdk_vs2017_win.exe"
    )

    if exist "%cd%\fbx20192_fbxsdk_vs2017_win.exe" (
        if exist "%ProgramW6432%\7-Zip\7z.exe" (
            CALL "%ProgramW6432%\7-Zip\7z.exe" x -o"%cd%\fbxsdk" "%cd%\fbx20192_fbxsdk_vs2017_win.exe"
        ) else (
            CALL "%ProgramFiles%\7-Zip\7z.exe" x -o"%cd%\fbxsdk" "%cd%\fbx20192_fbxsdk_vs2017_win.exe"
        )
        CALL del "fbx20192_fbxsdk_vs2017_win.exe"
    )
)

REM DRACO
CALL git submodule update --progress --init -- "draco"
cd draco

if not exist build\ (
    mkdir build
    if not exist "%cd%\draco.sln" (
        cd build
        CALL cmake .. -G "Visual Studio 16 2019" -A Win32
    )
)

if exist build\ ( cd build )
set buildconfig=%1

if "%VSWHERE%"=="" set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
    set InstallDir=%%i
)

set BUILDDRACO=0

if %buildconfig%==1 (
    if not exist "%cd%\Release\draco.lib" set BUILDDRACO=1
    if not exist "%cd%\Release\dracodec.lib" set BUILDDRACO=1
    if not exist "%cd%\Release\dracoenc.lib" set BUILDDRACO=1
)

if %buildconfig%==2 (
    if not exist "%cd%\Debug\draco.lib" set BUILDDRACO=2
    if not exist "%cd%\Debug\dracodec.lib" set BUILDDRACO=2
    if not exist "%cd%\Debug\dracoenc.lib" set BUILDDRACO=2
)

if exist "%InstallDir%\MSBuild\Current\Bin\MSBuild.exe" (
    if %BUILDDRACO%==1 "%InstallDir%\MSBuild\Current\Bin\MSBuild.exe" draco.sln /p:configuration=Release
    if %BUILDDRACO%==2 "%InstallDir%\MSBuild\Current\Bin\MSBuild.exe" draco.sln /p:configuration=Debug
)

REM GIT SUBMODULE
cd ../..
CALL git submodule update --progress --init -- "mathfu"
CALL git submodule update --progress --init -- "vectorial"

REM VCPKG LIBS
CALL vcpkg install --triplet x86-windows boost-filesystem:x86-windows boost-optional:x86-windows nlohmann-fifo-map nlohmann-json stb fmt cppcodec
