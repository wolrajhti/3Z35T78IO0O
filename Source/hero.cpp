#include "hero.h"

Hero::Hero(int x, int y) {
	m_x = x;
	m_y = y;
}

static int hero_new(lua_State *L) {
	int x = luaL_checkint(L, -2);
	int y = luaL_checkint(L, -1);

	*static_cast<Hero**>(lua_newuserdata(L, sizeof(Hero*))) = new Hero(x, y);

	if (luaL_newmetatable(L, LUA_META_HERO)) {
		static const luaL_Reg methods[] = {
			{"getX", hero_getX},
			{"getY", hero_getY},
			{"getPosition", hero_getPosition},
			{"__gc", hero_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	return 1;
}

int Hero::getX() {
	return m_x;
}

static int hero_getX(lua_State *L) {
	static Hero *p = *static_cast<Hero**>(luaL_checkudata(L, 1, LUA_META_HERO));
	lua_pushnumber(L, p->getX());
	return 1;
}

int Hero::getY() {
	return m_y;
}

static int hero_getY(lua_State *L) {
	static Hero *p = *static_cast<Hero**>(luaL_checkudata(L, 1, LUA_META_HERO));
	lua_pushnumber(L, p->getY());
	return 1;
}

static int hero_getPosition(lua_State *L) {
	static Hero *p = *static_cast<Hero**>(luaL_checkudata(L, 1, LUA_META_HERO));
	lua_pushnumber(L, p->getX());
	lua_pushnumber(L, p->getY());
	return 2;
}

static int hero_free(lua_State *L) {
	static Hero *p = *static_cast<Hero**>(luaL_checkudata(L, 1, LUA_META_HERO));
	delete p;
	return 0;
}

extern "C" int luaopen_hero(lua_State *L) {
	lua_pushcfunction(L, hero_new);
	return 1;
}
