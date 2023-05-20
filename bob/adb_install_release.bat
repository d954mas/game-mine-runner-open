::adb shell pm uninstall com.d954mas.game.minerunner3d
adb install -r ".\releases\release\playmarket\Mine Runner\Mine Runner.apk"
adb shell monkey -p com.d954mas.game.minerunner3d -c android.intent.category.LAUNCHER 1
pause
