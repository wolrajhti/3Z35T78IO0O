#include "superHero.h"

SuperHero::SuperHero(int x, int y) {
	m_x = x;
	m_y = y;
}

static int superHero_new(lua_State *L) {
	int x = luaL_checkint(L, -2);
	int y = luaL_checkint(L, -1);

	*static_cast<SuperHero**>(lua_newuserdata(L, sizeof(SuperHero*))) = new SuperHero(x, y);

	if (luaL_newmetatable(L, LUA_META_SUPERHERO)) {
		static const luaL_Reg methods[] = {
			{"getX", superHero_getX},
			{"getY", superHero_getY},
			{"getPosition", superHero_getPosition},
			{"__gc", superHero_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	return 1;
}

int SuperHero::getX() {
	return m_x;
}

static int superHero_getX(lua_State *L) {
	static SuperHero *p = *static_cast<SuperHero**>(luaL_checkudata(L, 1, LUA_META_SUPERHERO));
	lua_pushnumber(L, p->getX());
	return 1;
}

int SuperHero::getY() {
	return m_y;
}

static int superHero_getY(lua_State *L) {
	static SuperHero *p = *static_cast<SuperHero**>(luaL_checkudata(L, 1, LUA_META_SUPERHERO));
	lua_pushnumber(L, p->getY());
	return 1;
}

static int superHero_getPosition(lua_State *L) {
	static SuperHero *p = *static_cast<SuperHero**>(luaL_checkudata(L, 1, LUA_META_SUPERHERO));
	lua_pushnumber(L, p->getX());
	lua_pushnumber(L, p->getY());
	return 2;
}

static int superHero_free(lua_State *L) {
	static SuperHero *p = *static_cast<SuperHero**>(luaL_checkudata(L, 1, LUA_META_SUPERHERO));
	delete p;
	return 0;
}

extern "C" int luaopen_superHero(lua_State *L) {
	lua_pushcfunction(L, superHero_new);
	return 1;
}
