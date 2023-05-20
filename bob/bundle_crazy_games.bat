if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../


java -jar bob/bob.jar --settings bob/settings/release_game.project_settings --settings bob/settings/crazy_games_game.project_settings --archive --with-symbols --variant release --platform=js-web --bo bob/releases/crazy_games clean resolve build bundle 
