@echo off

setlocal

REM Build 'dotnet' using a version of itself hosted on the DNX
REM The output of this is independent of DNX

REM This trick gets the absolute path from a relative path
pushd %~dp0..
set REPOROOT=%CD%
popd

set RID=win7-x64
set OUTPUT_ROOT=%REPOROOT%\artifacts\%RID%
set STAGE1_DIR=%OUTPUT_ROOT%\stage1
set STAGE2_DIR=%OUTPUT_ROOT%\stage2
set DOTNET_PUBLISH=%REPOROOT%\scripts\dnxhost\dotnet-publish.cmd
set DOTNET_CLR_HOSTS_PATH=%REPOROOT%\ext\CLRHost\%RID%

where dnvm >nul 2>nul
if %errorlevel% == 0 goto have_dnvm

REM download dnvm
echo Installing dnvm (DNX is needed to bootstrap currently) ...
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "&{$Branch='dev';$wc=New-Object System.Net.WebClient;$wc.Proxy=[System.Net.WebRequest]::DefaultWebProxy;$wc.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;Invoke-Expression ($wc.DownloadString('https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.ps1'))}"

:have_dnvm
echo Installing and use-ing the latest CoreCLR x64 DNX ...
call dnvm install -u latest -r coreclr -arch x64 -alias dotnet_bootstrap
if errorlevel 1 goto fail

call dnvm use dotnet_bootstrap -r coreclr -arch x64
if errorlevel 1 goto fail

if exist %STAGE1_DIR% rd /s /q %STAGE1_DIR%

echo Running 'dnu restore' to restore packages for DNX-hosted projects
call dnu restore "%REPOROOT%\src\Microsoft.DotNet.Cli"
if errorlevel 1 goto fail

call dnu restore "%REPOROOT%\src\Microsoft.DotNet.Tools.Compiler"
if errorlevel 1 goto fail

call dnu restore "%REPOROOT%\src\Microsoft.DotNet.Tools.Publish"
if errorlevel 1 goto fail

echo Building basic dotnet tools using DNX-hosted version

echo Building stage1 dotnet.exe ...
call "%DOTNET_PUBLISH%" --framework dnxcore50 --runtime %RID% --output "%STAGE1_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Cli"
if errorlevel 1 goto fail

echo Building stage1 dotnet-compile.exe ...
call "%DOTNET_PUBLISH%" --framework dnxcore50 --runtime %RID% --output "%STAGE1_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Compiler"
if errorlevel 1 goto fail

echo Building stage1 dotnet-publish.exe ...
call "%DOTNET_PUBLISH%" --framework dnxcore50 --runtime %RID% --output "%STAGE1_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Publish"
if errorlevel 1 goto fail

echo Re-building dotnet tools with the bootstrapped version
REM This should move into a proper build script of some kind once we are bootstrapped
set PATH=%STAGE1_DIR%;%PATH%

if exist %STAGE2_DIR% rd /s /q %STAGE2_DIR%

REM No longer need our special CoreConsole
set DOTNET_CLR_HOSTS_PATH=

echo Building stage2 dotnet.exe ...
dotnet publish --framework dnxcore50 --runtime %RID% --output "%STAGE2_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Cli"
if errorlevel 1 goto fail

echo Building stage2 dotnet-compile.exe ...
dotnet publish --framework dnxcore50 --runtime %RID% --output "%STAGE2_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Compiler"
if errorlevel 1 goto fail

echo Building stage2 dotnet-publish.exe ...
dotnet publish --framework dnxcore50 --runtime %RID% --output "%STAGE2_DIR%" "%REPOROOT%\src\Microsoft.DotNet.Tools.Publish"
if errorlevel 1 goto fail

echo Bootstrapped dotnet to %STAGE2_DIR%
popd

goto end

:fail
echo Bootstrapping failed...
exit /B 1

:end
