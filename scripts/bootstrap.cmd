@echo off

setlocal

REM Build 'dotnet' using a version of itself hosted on the DNX
REM The output of this is independent of DNX

REM This trick gets the absolute path from a relative path
pushd %~dp0..
set REPOROOT=%CD%
popd

set RID=win7-x64
set STAGE0_DIR=%REPOROOT%\artifacts\%RID%\stage0
set STAGE1_DIR=%REPOROOT%\artifacts\%RID%\stage1
set STAGE2_DIR=%REPOROOT%\artifacts\%RID%\stage2

where dnvm >nul 2>nul
if %errorlevel% == 0 goto have_dnvm

:have_dnvm
echo Installing and use-ing the latest CoreCLR x64 DNX ...
call dnvm install -nonative -u latest -r coreclr -arch x64 -alias dotnet_bootstrap
if errorlevel 1 goto fail

call dnvm use dotnet_bootstrap -r coreclr -arch x64
if errorlevel 1 goto fail

if exist %STAGE1_DIR% rd /s /q %STAGE1_DIR%

echo Running 'dnu restore' to restore packages for DNX-hosted projects
call dnu restore "%REPOROOT%"
if errorlevel 1 goto fail

echo Building basic dotnet tools using older dotnet SDK version

set DOTNET_HOME=%STAGE0_DIR%

call %~dp0dnvm2 upgrade
if errorlevel 1 goto fail

echo Building stage1 dotnet.exe ...
dotnet-publish --framework dnxcore50 --runtime %RID% --output "%STAGE1_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Cli"
if errorlevel 1 goto fail

echo Building stage1 dotnet-compile.exe ...
dotnet-publish --framework dnxcore50 --runtime %RID% --output "%STAGE1_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Compiler"
if errorlevel 1 goto fail

echo Building stage1 dotnet-compile-csc.exe ...
dotnet-publish --framework dnxcore50 --runtime %RID% --output "%STAGE1_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Compiler.Csc"
if errorlevel 1 goto fail

echo Building stage1 dotnet-publish.exe ...
dotnet-publish --framework dnxcore50 --runtime %RID% --output "%STAGE1_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Publish"
if errorlevel 1 goto fail

echo Building stage1 dotnet-publish.exe ...
dotnet-publish --framework dnxcore50 --runtime %RID% --output "%STAGE1_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Resgen"
if errorlevel 1 goto fail

echo Re-building dotnet tools with the bootstrapped version
REM This should move into a proper build script of some kind once we are bootstrapped
set PATH=%STAGE1_DIR%;%PATH%

if exist %STAGE2_DIR% rd /s /q %STAGE2_DIR%

echo Building stage2 dotnet.exe ...
dotnet compile --runtime %RID% --output "%STAGE2_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Cli"
if errorlevel 1 goto fail

echo Building stage2 dotnet-compile.exe ...
dotnet compile --runtime %RID% --output "%STAGE2_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Compiler"
if errorlevel 1 goto fail

echo Building stage2 dotnet-compile-csc.exe ...
dotnet compile --runtime %RID% --output "%STAGE2_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Compiler.Csc"
if errorlevel 1 goto fail

echo Building stage2 dotnet-publish.exe ...
dotnet compile --runtime %RID% --output "%STAGE2_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Publish"
if errorlevel 1 goto fail

echo Building stage2 dotnet-publish.exe ...
dotnet compile --runtime %RID% --output "%STAGE2_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Resgen"
if errorlevel 1 goto fail

echo Bootstrapped dotnet to %STAGE2_DIR%

goto end

:fail
echo Bootstrapping failed...
exit /B 1

:end