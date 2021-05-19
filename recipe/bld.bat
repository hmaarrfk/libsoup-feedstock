@ECHO ON

:: set pkg-config path so that host deps can be found
:: (set as env var so it's used by both meson and during build with g-ir-scanner)
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

:: get mixed path (forward slash) form of prefix so host prefix replacement works
set "LIBRARY_PREFIX_M=%LIBRARY_PREFIX:\=/%"

:: set the path to the modules explicitly, as they won't get found otherwise
set "GIO_MODULE_DIR=%LIBRARY_LIB%\gio\modules"

%BUILD_PREFIX%\Scripts\meson.exe setup builddir --wrap-mode=nofallback --buildtype=release --prefix=%LIBRARY_PREFIX_M% --backend=ninja -Dbrotli=enabled -Dintrospection=enabled -Dtests=false -Dsysprof=disabled
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1

:: The gir files produced by the build are currently broken, don't know why...
copy %RECIPE_DIR%\gir\*typelib %LIBRARY_LIB%\girepository-1.0\
if errorlevel 1 exit 1
copy %RECIPE_DIR%\gir\*gir %LIBRARY_PREFIX%\share\gir-1.0\
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\bin\*.pdb
