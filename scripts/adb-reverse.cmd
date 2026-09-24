@echo off
REM 手机端网络反代: 把手机的 127.0.0.1:8080/8900 透传到开发机。
REM USB 重插/adb 重启会清掉 reverse 表 —— 连不上时重跑本脚本即可。
set ADB="E:\Android SDK\platform-tools\adb.exe"
%ADB% reverse tcp:8080 tcp:8080
%ADB% reverse tcp:8900 tcp:8900
%ADB% reverse --list
pause
