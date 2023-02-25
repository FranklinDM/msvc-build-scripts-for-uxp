@ECHO OFF

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

SET MOZ_MSVCBITS=64
SET MOZ_MSVCVERSION=14
SET MOZ_MSVCYEAR=2022

REM Switch CWD to the current location so that the call to start.shell-bat
REM doesn't fail if invoked from a different location.
pushd "%~dp0"

CALL start-shell-msvc2022.bat
