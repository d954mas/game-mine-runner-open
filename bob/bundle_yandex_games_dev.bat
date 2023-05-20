if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../


java -jar bob/bob.jar --settings bob/settings/dev_game.project_settings --settings bob/settings/yandex_games_game.project_settings --archive --with-symbols --variant debug --platform=js-web --bo bob/releases/yandex_games_dev clean resolve build bundle

::java -jar bob/bob.jar --settings bob/settings/release_game.project_settings --settings bob/settings/yandex_games_ru_game.project_settings --archive --with-symbols --variant debug --platform=js-web --bo bob/releases/yandex_games_ru clean resolve build bundle 