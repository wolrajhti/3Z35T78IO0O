#include "wrap_rcPolyMesh.h"

static int wrap_rcPolyMesh_new(lua_State *L) {
	*static_cast<rcPolyMesh**>(lua_newuserdata(L, sizeof(rcPolyMesh*))) = rcAllocPolyMesh();

	if (luaL_newmetatable(L, LUA_META_WRAP_RCPOLYMESH)) {
		static const luaL_Reg methods[] = {
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	return 1;
}

static int wrap_rcPolyMesh_free(lua_State *L) {
	static rcPolyMesh *polyMesh = *static_cast<rcPolyMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCPOLYMESH));
	rcFreePolyMesh(polyMesh);
	return 0;
}

extern "C" int luaopen_wrap_rcPolyMesh(lua_State *L) {
	lua_pushcfunction(L, wrap_rcPolyMesh_new);
	return 1;
}
