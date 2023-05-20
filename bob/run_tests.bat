if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../

java -jar bob/bob.jar --archive --settings bob/settings/release_game.project_settings --settings bob/settings/test_game.project_settings --with-symbols --variant headless --platform=x86_64-win32 clean resolve build bundle --bo bob/releases/tests/win
 

bob\releases\tests\win\YouD\YouD.exe