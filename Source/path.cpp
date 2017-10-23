#include "path.h"

int path_new(lua_State *L) {
	int n = luaL_checkint(L, -1);

	lua_pop(L, 1);

	*static_cast<dtPolyRef**>(lua_newuserdata(L, sizeof(dtPolyRef*))) = (dtPolyRef *)malloc(n * sizeof(dtPolyRef));

	if (luaL_newmetatable(L, LUA_META_PATH)) {
		static const luaL_Reg methods[] = {
			{"__gc", path_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	return 1; /* new userdatum is already on the stack */
}

static int path_free(lua_State *L) {
	// printf("path_free\n");
	dtPolyRef *path = *static_cast<dtPolyRef**>(luaL_checkudata(L, 1, LUA_META_PATH));
	free(path);
	return 0;
}

extern "C" int luaopen_path(lua_State *L) {
	lua_pushcfunction(L, path_new);
	return 1;
}
