if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
luacheck . > lua_lint_result.txt 2>&1 && type lua_lint_result.txt
