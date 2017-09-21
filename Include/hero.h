#ifndef HERO_H
# define HERO_H

# include <lua.hpp>
# include <cstddef>

# define LUA_META_HERO "Hero"

class Hero
{
public:
	Hero(int x, int y);
	int getX();
	int getY();
private:
	int m_x, m_y;
};

static int hero_new(lua_State *L);
static int hero_getX(lua_State *L);
static int hero_getY(lua_State *L);
static int hero_getPosition(lua_State *L);
static int hero_free(lua_State *L);

#endif
