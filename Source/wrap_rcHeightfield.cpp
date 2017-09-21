#include "wrap_rcHeightfield.h"

static int wrap_rcHeightfield_new(lua_State *L) {
	static rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCONTEXT));

	int width = luaL_checkint(L, 2);
	int height = luaL_checkint(L, 3);

	static Vector3f *vMin = *static_cast<Vector3f**>(luaL_checkudata(L, 4, LUA_META_VECTOR3F));
	static Vector3f *vMax = *static_cast<Vector3f**>(luaL_checkudata(L, 5, LUA_META_VECTOR3F));

	float min[3];
	float max[3];

	vMin->toArray(min);
	vMax->toArray(max);

	float cs = luaL_checknumber(L, 6);
	float ch = luaL_checknumber(L, 7);

	*static_cast<rcHeightfield**>(lua_newuserdata(L, sizeof(rcHeightfield*))) = rcAllocHeightfield();

	if (luaL_newmetatable(L, LUA_META_WRAP_RCHEIGHTFIELD)) {
		static const luaL_Reg methods[] = {
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}

	lua_setmetatable(L, -2);

	static rcHeightfield *heightfield = *static_cast<rcHeightfield**>(luaL_checkudata(L, 8, LUA_META_WRAP_RCHEIGHTFIELD));

	rcCreateHeightfield(context, *heightfield, width, height, min, max, cs, ch);

	return 1;
}

static int wrap_rcHeightfield_free(lua_State *L) {
	static rcHeightfield *heightfield = *static_cast<rcHeightfield**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCHEIGHTFIELD));
	rcFreeHeightField(heightfield);
	return 0;
}

extern "C" int luaopen_wrap_rcHeightfield(lua_State *L) {
	lua_pushcfunction(L, wrap_rcHeightfield_new);
	return 1;
}
