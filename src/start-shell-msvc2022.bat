@ECHO OFF

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM Prevent VSCMD from sending telemetry.
SET VSCMD_SKIP_SENDTELEMETRY=1
REM Recent updates to the MSVS 2022 build tools add the location
REM of the VC++ Toolset to PATH and will not be detected if we
REM reset to a "clean" path.
SET MOZ_NO_RESET_PATH=1

IF DEFINED MOZ_MSVCVERSION (
  IF NOT DEFINED VCDIR (
    REM Find the latest Visual Studio's installation directory.
    CALL :_GET_VSDIR
    SET VCDIR=!VSDIR!\VC\Auxiliary\Build

    IF NOT EXIST "!VCDIR!" (
      SET ERROR=Microsoft Visual C++ %MOZ_MSVCYEAR% was not found. Exiting.
      GOTO _QUIT
    )
  )

  REM Prepend MSVC paths.
  IF "%MOZ_MSVCBITS%" == "32" (
    REM Prefer cross-compiling 32-bit builds using the 64-bit toolchain if able to do so.
    IF "%WIN64%" == "1" IF EXIST "!VCDIR!\vcvarsamd64_x86.bat" (
      CALL "!VCDIR!\vcvarsamd64_x86.bat"
      SET TOOLCHAIN=64-bit cross-compile
    )

    REM LIB will be defined if vcvarsamd64_x86.bat has already run.
    REM Fall back to vcvars32.bat if it hasn't.
    IF NOT DEFINED LIB (
      IF EXIST "!VCDIR!\vcvars32.bat" (
        CALL "!VCDIR!\vcvars32.bat"
        SET TOOLCHAIN=32-bit
      )
    )
  ) ELSE IF "%MOZ_MSVCBITS%" == "64" (
    IF EXIST "!VCDIR!\vcvars64.bat" (
      CALL "!VCDIR!\vcvars64.bat"
      SET TOOLCHAIN=64-bit
    )
  )

  REM LIB will be defined if a vcvars script has run. Bail if it isn't.
  IF NOT DEFINED LIB (
    SET ERROR=Unable to call a suitable vcvars script. Exiting.
    GOTO _QUIT
  )

  IF NOT DEFINED SDKDIR (
      SET SDKDIR=!UniversalCRTSdkDir!
      SET SDKVER=!UCRTVersion!
  )

  REM Bail if no Windows SDK is found.
  IF NOT EXIST "!SDKDIR!" (
    SET ERROR=No Windows SDK found. Exiting.
    GOTO _QUIT
  )
  
  REM Add the DIA SDK paths needed for dump_syms.
  SET INCLUDE=!VSDIR!\DIA SDK\include;!INCLUDE!
  IF "%MOZ_MSVCBITS%" == "32" (
    SET LIB=!VSDIR!\DIA SDK\lib;!LIB!
  ) ELSE (
    SET LIB=!VSDIR!\DIA SDK\lib\amd64;!LIB!
  )
)

REM Switch CWD to the current location so that the call to start.shell-bat
REM doesn't fail if invoked from a different location.
pushd "%~dp0"

CALL start-shell.bat

:_GET_VSDIR
SET MOZILLABUILD=%~dp0
FOR /F "tokens=* delims=," %%A IN (
  '%MOZILLABUILD%bin\vswhere.exe -latest -property installationPath'
) DO (
  REM Get the first entry from the list of installation paths
  SET VSDIR=%%A
  exit /b
)

:_QUIT
ECHO.
ECHO %ERROR%
ECHO.
PAUSE
EXIT /B
