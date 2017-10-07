#include "vector3f.h"

int vector3f_new(lua_State *L) {
	float x = (float)luaL_checknumber(L, -3);
	float y = (float)luaL_checknumber(L, -2);
	float z = (float)luaL_checknumber(L, -1);

	lua_pop(L, 3);

	*static_cast<float**>(lua_newuserdata(L, sizeof(float*))) = (float *)malloc(3 * sizeof(float));

	if (luaL_newmetatable(L, LUA_META_VECTOR3F)) {
		static const luaL_Reg methods[] = {
			{"getX", vector3f_getX},
			{"getY", vector3f_getY},
			{"getZ", vector3f_getZ},
			{"setX", vector3f_setX},
			{"setY", vector3f_setY},
			{"setZ", vector3f_setZ},
			{"getPosition", vector3f_getPosition},
			{"__gc", vector3f_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));

	v3f[0] = x;
	v3f[1] = y;
	v3f[2] = z;

	return 1;
}

static int vector3f_getX(lua_State *L) {
	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	lua_pushnumber(L, v3f[0]/*->getX()*/);
	return 1;
}

static int vector3f_getY(lua_State *L) {
	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	lua_pushnumber(L, v3f[1]/*->getY()*/);
	return 1;
}

static int vector3f_getZ(lua_State *L) {
	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	lua_pushnumber(L, v3f[2]/*->getZ()*/);
	return 1;
}

static int vector3f_setX(lua_State *L) {
	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	float x = (float)luaL_checknumber(L, -1);
	v3f[0] = x;
	return 0;
}

static int vector3f_setY(lua_State *L) {
	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	float y = (float)luaL_checknumber(L, -1);
	v3f[1] = y;
	return 0;
}

static int vector3f_setZ(lua_State *L) {
	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	float z = (float)luaL_checknumber(L, -1);
	v3f[2] = z;
	return 0;
}

static int vector3f_getPosition(lua_State *L) {
	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	lua_pushnumber(L, v3f[0]/*->getX()*/);
	lua_pushnumber(L, v3f[1]/*->getY()*/);
	lua_pushnumber(L, v3f[2]/*->getZ()*/);
	return 3;
}

static int vector3f_free(lua_State *L) {
	// printf("vector3f_free\n");
	float *v3f = *static_cast<float**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	printf("vector3f_free %.1f %.1f %.1f\n", v3f[0], v3f[1], v3f[2]);
	free(v3f);
	return 0;
}

extern "C" int luaopen_vector3f(lua_State *L) {
	lua_pushcfunction(L, vector3f_new);
	return 1;
}
