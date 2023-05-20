if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../


java -jar bob/bob.jar --settings bob/settings/release_game.project_settings --settings bob/settings/game_distribution_game.project_settings --archive --with-symbols --variant release --platform=js-web --bo bob/releases/game_distribution clean resolve build bundle 
