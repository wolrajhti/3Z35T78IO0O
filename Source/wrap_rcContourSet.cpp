#include "wrap_rcContourSet.h"

/*static*/ int wrap_rcContourSet_new(lua_State *L) {
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCONTEXT));
	rcCompactHeightfield *compactHeightfield = *static_cast<rcCompactHeightfield**>(luaL_checkudata(L, 2, LUA_META_WRAP_RCCOMPACTHEIGHTFIELD));

	int maxError = (float)luaL_checknumber(L, 3);
	int maxEdgeLen = luaL_checkint(L, 4);

	*static_cast<rcContourSet**>(lua_newuserdata(L, sizeof(rcContourSet*))) = rcAllocContourSet();

	if (luaL_newmetatable(L, LUA_META_WRAP_RCCONTOURSET)) {
		static const luaL_Reg methods[] = {
			{"__gc", wrap_rcContourSet_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}

	lua_setmetatable(L, -2);

	rcContourSet *contourSet = *static_cast<rcContourSet**>(luaL_checkudata(L, 5, LUA_META_WRAP_RCCONTOURSET));

	if(!rcBuildContours(context, *compactHeightfield, maxError, maxEdgeLen, *contourSet, RC_CONTOUR_TESS_WALL_EDGES /*| RC_CONTOUR_TESS_AREA_EDGES*/))
	{
		luaL_error(L, "error - build contours\n");
		return 0;
	}

	return 1;
}

static int wrap_rcContourSet_free(lua_State *L) {
	printf("wrap_rcContourSet_free\n");
	rcContourSet *contourSet = *static_cast<rcContourSet**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCONTOURSET));
	rcFreeContourSet(contourSet);
	return 0;
}

extern "C" int luaopen_wrap_rcContourSet(lua_State *L) {
	lua_pushcfunction(L, wrap_rcContourSet_new);
	return 1;
}
