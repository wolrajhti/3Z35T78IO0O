#include "wrap_dtQueryFilter.h"

int wrap_dtQueryFilter_new(lua_State *L) {
	*static_cast<dtQueryFilter**>(lua_newuserdata(L, sizeof(dtQueryFilter*))) = new dtQueryFilter();

	if (luaL_newmetatable(L, LUA_META_WRAP_DTQUERYFILTER)) {
		static const luaL_Reg methods[] = {
			{"setAreaCost", wrap_dtQueryFilter_setAreaCost},
			{"__gc", wrap_dtQueryFilter_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	return 1;
}

static int wrap_dtQueryFilter_setAreaCost(lua_State *L) {
	dtQueryFilter *queryFilter = *static_cast<dtQueryFilter**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTQUERYFILTER));
	int id = luaL_checkint(L, 2);
	float cost = (float)luaL_checknumber(L, 3);

	queryFilter->setAreaCost(id, cost);
	return 0;
}

static int wrap_dtQueryFilter_free(lua_State *L) {
	printf("wrap_dtQueryFilter_free\n");
	dtQueryFilter *queryFilter = *static_cast<dtQueryFilter**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTQUERYFILTER));
	delete queryFilter;
	return 0;
}

extern "C" int luaopen_wrap_dtQueryFilter(lua_State *L) {
	lua_pushcfunction(L, wrap_dtQueryFilter_new);
	return 1;
}
