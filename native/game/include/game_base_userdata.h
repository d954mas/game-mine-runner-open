#ifndef game_base_userdata_h
#define game_base_userdata_h

#include <dmsdk/sdk.h>



namespace d954masGame {

class BaseUserData {
private:

public:
    int table_ref; //always return same table
    const char* userdata_type;
    const char* metatable_name;
    void* obj;

    BaseUserData(const char* userdata_type);
    virtual ~BaseUserData();
	virtual void Push(lua_State *L);
	virtual void Destroy(lua_State *L);
};

BaseUserData* BaseUserData_get_userdata(lua_State *L, int index, char* userdata_type);



}
#endif