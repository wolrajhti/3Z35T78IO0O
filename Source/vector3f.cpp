#include "vector3f.h"

Vector3f::Vector3f(float x, float y, float z) {
	m_x = x;
	m_y = y;
	m_z = z;
}

/*static*/ int vector3f_new(lua_State *L) {
	float x = (float)luaL_checknumber(L, -3);
	float y = (float)luaL_checknumber(L, -2);
	float z = (float)luaL_checknumber(L, -1);

	*static_cast<Vector3f**>(lua_newuserdata(L, sizeof(Vector3f*))) = new Vector3f(x, y, z);

	if (luaL_newmetatable(L, LUA_META_VECTOR3F)) {
		static const luaL_Reg methods[] = {
			{"getX", vector3f_getX},
			{"getY", vector3f_getY},
			{"getZ", vector3f_getZ},
			{"getPosition", vector3f_getPosition},
			{"__gc", vector3f_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	return 1;
}

float Vector3f::getX() {
	return m_x;
}

static int vector3f_getX(lua_State *L) {
	Vector3f *v3f = *static_cast<Vector3f**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	lua_pushnumber(L, v3f->getX());
	return 1;
}

float Vector3f::getY() {
	return m_y;
}

static int vector3f_getY(lua_State *L) {
	Vector3f *v3f = *static_cast<Vector3f**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	lua_pushnumber(L, v3f->getY());
	return 1;
}

float Vector3f::getZ() {
	return m_z;
}

static int vector3f_getZ(lua_State *L) {
	Vector3f *v3f = *static_cast<Vector3f**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	lua_pushnumber(L, v3f->getZ());
	return 1;
}

static int vector3f_getPosition(lua_State *L) {
	Vector3f *v3f = *static_cast<Vector3f**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	lua_pushnumber(L, v3f->getX());
	lua_pushnumber(L, v3f->getY());
	lua_pushnumber(L, v3f->getZ());
	return 3;
}

void Vector3f::toArray(float array[3]) {
	array[0] = m_x;
	array[1] = m_y;
	array[2] = m_z;
}

static int vector3f_free(lua_State *L) {
	printf("vector3f_free\n");
	Vector3f *v3f = *static_cast<Vector3f**>(luaL_checkudata(L, 1, LUA_META_VECTOR3F));
	delete v3f;
	return 0;
}

extern "C" int luaopen_vector3f(lua_State *L) {
	lua_pushcfunction(L, vector3f_new);
	return 1;
}
