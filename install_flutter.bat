@echo off
echo Installing Flutter SDK...

REM Create Flutter directory
if not exist "C:\flutter" mkdir "C:\flutter"

REM Download Flutter using PowerShell
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip' -OutFile 'C:\flutter\flutter.zip'}"

REM Extract Flutter
cd C:\flutter
powershell -Command "Expand-Archive -Path 'flutter.zip' -DestinationPath 'C:\' -Force"

REM Set environment variables
setx PATH "%PATH%;C:\flutter\bin" /M

REM Verify installation
C:\flutter\bin\flutter.bat --version

echo Flutter installation completed!
echo Please restart your terminal to use Flutter.
