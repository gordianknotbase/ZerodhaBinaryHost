@echo off
setlocal

set APP_DIR=C:\ZeroAuto
set LOCAL_VERSION_FILE=%APP_DIR%\version.txt
set LATEST_VERSION_URL=https://raw.githubusercontent.com/gordianknotbase/ZerodhaBinaryHost/main/version.txt

:: Fetch latest version
echo [INFO] Fetching latest version from GitHub...
powershell -Command "(New-Object Net.WebClient).DownloadString('%LATEST_VERSION_URL%')" > "%TEMP%\remote_version.txt"
set /p LATEST_VERSION=<"%TEMP%\remote_version.txt"
echo [INFO] Latest version = %LATEST_VERSION%

:: Read local version
if exist "%LOCAL_VERSION_FILE%" (
    set /p LOCAL_VERSION=<"%LOCAL_VERSION_FILE%"
) else (
    set LOCAL_VERSION=none
)
echo [INFO] Local version = %LOCAL_VERSION%

:: Construct ZIP URL based on latest version
set ZIP_URL=https://github.com/gordianknotbase/ZerodhaBinaryHost/releases/download/v%LATEST_VERSION%/ZerodhaSetup-v%LATEST_VERSION%.zip
set ZIP_FILE=%TEMP%\ZerodhaSetup-v%LATEST_VERSION%.zip

:: Compare versions
if "%LOCAL_VERSION%" NEQ "%LATEST_VERSION%" (
    echo [INFO] New version detected! Downloading ZIP...

    powershell -Command "(New-Object Net.WebClient).DownloadFile('%ZIP_URL%', '%ZIP_FILE%')"

    echo [INFO] Cleaning old files...
    del /q "%APP_DIR%\target\*" >nul 2>&1
    rmdir /s /q "%APP_DIR%\target" >nul 2>&1

    echo [INFO] Extracting new setup...
    powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%APP_DIR%' -Force"

    echo %LATEST_VERSION% > "%LOCAL_VERSION_FILE%"
) else (
    echo [INFO] Already on the latest version.
)

:: Run the updated JAR
echo [INFO] Running equityAdjustment...
"%APP_DIR%\sapmachine-jre-21.0.7\bin\java" -jar "%APP_DIR%\target\zerodhaautomation-%LATEST_VERSION%-SNAPSHOT.jar" equityHoldings

endlocal
