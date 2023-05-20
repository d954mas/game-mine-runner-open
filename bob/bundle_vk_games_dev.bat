if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../


java -jar bob/bob.jar --settings bob/settings/dev_game.project_settings --settings bob/settings/vk_games_game.project_settings --archive --with-symbols --variant debug --platform=js-web --bo bob/releases/vk_games clean resolve build bundle  