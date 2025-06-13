@echo off
setlocal

set APP_DIR=C:\ZeroAuto
set LATEST_VERSION_URL=https://raw.githubusercontent.com/gordianknotbase/ZerodhaBinaryHost/main/version.txt

:: Fetch latest version
echo [INFO] Fetching latest version from GitHub...
powershell -Command "(New-Object Net.WebClient).DownloadString('%LATEST_VERSION_URL%')" > "%TEMP%\remote_version.txt"
for /f "delims=" %%a in ('type "%TEMP%\remote_version.txt"') do set "LATEST_VERSION=%%a"

echo [INFO] Latest version = %LATEST_VERSION%

:: Detect local version from JAR file
set "LOCAL_VERSION=none"
if exist "%APP_DIR%\target" (
    for %%f in ("%APP_DIR%\target\zerodhaautomation-*-SNAPSHOT.jar") do (
        for %%g in ("%%~nxf") do (
            set "FILENAME=%%~nxf"
            setlocal enabledelayedexpansion
            set "FILENAME=!FILENAME:zerodhaautomation-=!"
            set "FILENAME=!FILENAME:-SNAPSHOT=!"
            endlocal & set "LOCAL_VERSION=%FILENAME%"
        )
    )
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
) else (
    echo [INFO] Already on the latest version.
)

:: Run the updated JAR
echo [INFO] Running equityHoldings...
"%APP_DIR%\sapmachine-jre-21.0.7\bin\java" -jar "%APP_DIR%\target\zerodhaautomation-%LATEST_VERSION%-SNAPSHOT.jar" equityHoldings

endlocal
