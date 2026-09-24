@echo off
REM 自签开发证书: 网关 HTTPS + comet TLS 共用。
REM SAN 覆盖 localhost / 127.0.0.1 (adb reverse 后手机视角也是 127.0.0.1)。
REM 产出 deploy\tls\{server.crt, server.key} 并打印客户端 pin 用 sha256 指纹。
setlocal
cd /d %~dp0..
if not exist deploy\tls mkdir deploy\tls

where openssl >nul 2>nul
if errorlevel 1 (
  echo openssl not found, trying Git Bash bundled one...
  set OPENSSL="C:\Program Files\Git\usr\bin\openssl.exe"
) else (
  set OPENSSL=openssl
)

%OPENSSL% req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes ^
  -keyout deploy\tls\server.key -out deploy\tls\server.crt ^
  -subj "/CN=localhost" ^
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
if errorlevel 1 (
  echo cert generation failed
  pause
  exit /b 1
)

echo.
echo ===== client pin (sha256, 去掉冒号后配 --dart-define=YIM_TLS_PIN=) =====
%OPENSSL% x509 -in deploy\tls\server.crt -noout -fingerprint -sha256
pause
