@echo off
@setlocal

echo ENTERING SATRB DIRECTORY...
cd "SATRB Files"

echo STEP 1
echo Deleting any temporary map files...
DEL "Maps\*.dbs" /S /Q 
DEL "Maps\*.backup1" /S /Q 

echo STEP 2
echo Compiling SL_SATRB.pk3...
"C:\Program Files\7-Zip\7z" u -aoa -uq0 -r ../SL_SATRB.pk3 ./

echo COMPLETE!
echo SL_SATRB.pk3 has been Compiled!
