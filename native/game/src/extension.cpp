// myextension.cpp
// Extension lib defines
#define EXTENSION_NAME Game
#define LIB_NAME "Game"
#define MODULE_NAME "game"
// include the Defold SDK
#include <dmsdk/sdk.h>
#include <game_utils.h>
#include "tunnel.h"
#include <stdlib.h>

using namespace d954masGame;
static int TunnelCreateLua(lua_State *L) {
	d954masGameUtils::check_arg_count(L, 0);
    Tunnel* tunnel = new Tunnel();
    tunnel->Push(L);
	return 1;
}

static int RandomSetSeed(lua_State *L){
    unsigned seed = luaL_checknumber(L, 1);
    srand(seed);
    return 0;
}


// Functions exposed to Lua
static const luaL_reg Module_methods[] ={
	 {"create_tunnel", TunnelCreateLua},
	 {"random_set_seed", RandomSetSeed},
	{0, 0}
};

static void LuaInit(lua_State* L){
	int top = lua_gettop(L);
	luaL_register(L, MODULE_NAME, Module_methods);
	lua_pop(L, 1);
	TunnelInitMetaTable(L);
	assert(top == lua_gettop(L));
}

static dmExtension::Result AppInitializeMyExtension(dmExtension::AppParams* params){return dmExtension::RESULT_OK;}
static dmExtension::Result InitializeMyExtension(dmExtension::Params* params){
	// Init Lua
	LuaInit(params->m_L);

	printf("Registered %s Extension\n", MODULE_NAME);
	return dmExtension::RESULT_OK;
}

static dmExtension::Result AppFinalizeMyExtension(dmExtension::AppParams* params){return dmExtension::RESULT_OK;}

static dmExtension::Result FinalizeMyExtension(dmExtension::Params* params){	return dmExtension::RESULT_OK;}

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, AppInitializeMyExtension, AppFinalizeMyExtension, InitializeMyExtension, 0, 0, FinalizeMyExtension)