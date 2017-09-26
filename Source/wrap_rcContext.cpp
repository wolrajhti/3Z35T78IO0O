#include "wrap_rcContext.h"

/*static*/ int wrap_rcContext_new(lua_State *L) {
	*static_cast<rcContext**>(lua_newuserdata(L, sizeof(rcContext*))) = new rcContext();

	if (luaL_newmetatable(L, LUA_META_WRAP_RCCONTEXT)) {
		static const luaL_Reg methods[] = {
			{"__gc", wrap_rcContext_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	return 1;
}

static int wrap_rcContext_free(lua_State *L) {
	printf("wrap_rcContext_free\n");
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCONTEXT));
	delete context;
	return 0;
}

extern "C" int luaopen_wrap_rcContext(lua_State *L) {
	lua_pushcfunction(L, wrap_rcContext_new);
	return 1;
}
