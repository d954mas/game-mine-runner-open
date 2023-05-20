if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../

java -jar bob/bob.jar --settings bob/settings/dev_game.project_settings --archive --with-symbols --variant debug --platform=armv7-android --bo bob/releases/dev/playmarket --settings bob/settings/play_market_game.project_settings resolve clean build bundle --strip-executable --keystore bob/keystore/release.jks --keystore-pass bob/keystore/release_password.txt --keystore-alias game

