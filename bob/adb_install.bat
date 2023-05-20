::adb shell pm uninstall com.d954mas.game.minerunner3d.dev
adb install -r ".\releases\dev\playmarket\Mine Runner Dev\Mine Runner Dev.apk"
adb shell monkey -p com.d954mas.game.minerunner3d.dev -c android.intent.category.LAUNCHER 1
pause
