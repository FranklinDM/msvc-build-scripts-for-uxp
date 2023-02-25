# UXP Build Utilities

Since MozillaBuild 3.x no longer has any `msvc*`-specific batch files, I've written a few batch files that target Visual Studio 2017 and higher (primarily tested with VS 2022). Aside from launching the appropriate VS environment, this also populates some essential variables, such as the location of the Windows SDK.

## Installation

Simply copy the files inside the `/src` directory into where you've installed MozillaBuild 3.x, and launch the batch file for your environment:
- `start-shell-msvc2022-x64.bat` (64-bit build)
- `start-shell-msvc2022-x86.bat` (32-bit build)

## Configuration

The following can now be used for specifying the location of the Visual C++ redist in your `.mozconfig`.
- `$VCINSTALLDIR`
- `$VCTOOLSREDISTDIR` (MSVC++ Redistributable directory)
- `$SDKDIR` (Windows SDK directory)
- `$SDKVER` (Windows SDK latest installed version)

Example:
```
WIN32_REDIST_DIR="$VCTOOLSREDISTDIR/$_BUILD_ARCH/Microsoft.VC143.CRT"
WIN_UCRT_REDIST_DIR="$SDKDIR/Redist/$SDKVER/ucrt/DLLs/$_BUILD_ARCH"
```
