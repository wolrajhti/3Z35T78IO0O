#include "wrap_rcCompactHeightfield.h"

/*static*/ int wrap_rcCompactHeightfield_new(lua_State *L) {
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCONTEXT));

	int walkableHeight = luaL_checkint(L, 2);
	int walkableClimb = luaL_checkint(L, 3);

	rcHeightfield *heightfield = *static_cast<rcHeightfield**>(luaL_checkudata(L, 4, LUA_META_WRAP_RCHEIGHTFIELD));

	*static_cast<rcCompactHeightfield**>(lua_newuserdata(L, sizeof(rcCompactHeightfield*))) = rcAllocCompactHeightfield();

	if (luaL_newmetatable(L, LUA_META_WRAP_RCCOMPACTHEIGHTFIELD)) {
		static const luaL_Reg methods[] = {
			{"rcErodeWalkableArea", wrap_rcErodeWalkableArea},
			{"rcBuildDistanceField", wrap_rcBuildDistanceField},
			{"rcBuildRegions", wrap_rcBuildRegions},
			{"__gc", wrap_rcCompactHeightfield_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}

	lua_setmetatable(L, -2);

	rcCompactHeightfield *compactHeightfield = *static_cast<rcCompactHeightfield**>(luaL_checkudata(L, 5, LUA_META_WRAP_RCCOMPACTHEIGHTFIELD));

	if (!rcBuildCompactHeightfield(context, walkableHeight, walkableClimb, *heightfield, *compactHeightfield)) {
		luaL_error(L, "rcBuildCompactHeightfield failed.\n");
		return 1;
	}

	return 1;
}

static int wrap_rcErodeWalkableArea(lua_State *L) {
	rcCompactHeightfield *compactHeightfield = *static_cast<rcCompactHeightfield**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCOMPACTHEIGHTFIELD));
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 2, LUA_META_WRAP_RCCONTEXT));
	if (!rcErodeWalkableArea(context, lua_tonumber(L, 3), *compactHeightfield))
	{
		luaL_error(L, "rcErodeWalkableArea failed.\n");
	}
	return 0;
}

static int wrap_rcBuildDistanceField(lua_State *L) {
	rcCompactHeightfield *compactHeightfield = *static_cast<rcCompactHeightfield**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCOMPACTHEIGHTFIELD));
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 2, LUA_META_WRAP_RCCONTEXT));
	if (!rcBuildDistanceField(context, *compactHeightfield))
	{
		luaL_error(L, "rcBuildDistanceField failed.\n");
	}
	return 0;
}

static int wrap_rcBuildRegions(lua_State *L) {
	rcCompactHeightfield *compactHeightfield = *static_cast<rcCompactHeightfield**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCOMPACTHEIGHTFIELD));
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 2, LUA_META_WRAP_RCCONTEXT));
	if (!rcBuildRegions(context, *compactHeightfield, 0, 0, 0))
	{
		luaL_error(L, "rcBuildRegions failed.\n");
	}
	return 0;
}

static int wrap_rcCompactHeightfield_free(lua_State *L) {
	printf("wrap_rcCompactHeightfield_free\n");
	rcCompactHeightfield *compactHeightfield = *static_cast<rcCompactHeightfield**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCOMPACTHEIGHTFIELD));
	rcFreeCompactHeightfield(compactHeightfield);
	return 0;
}

extern "C" int luaopen_wrap_rcCompactHeightfield(lua_State *L) {
	lua_pushcfunction(L, wrap_rcCompactHeightfield_new);
	return 1;
}
