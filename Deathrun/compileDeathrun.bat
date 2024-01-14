@echo off
@setlocal

echo ENTERING DEATHRUN DIRECTORY...
cd "Deathrun Files"

echo STEP 1
echo Deleting any temporary map files...
DEL "Maps\*.dbs" /S /Q 
DEL "Maps\*.backup1" /S /Q 

echo STEP 2
echo Compiling ZML_Deathrun.pk3...
"C:\Program Files\7-Zip\7z" u -aoa -uq0 -r ../ZML_Deathrun.pk3 ./

echo COMPLETE!
echo ZML_Deathrun.pk3 has been Compiled!
