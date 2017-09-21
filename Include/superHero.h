#ifndef SUPERHERO_H
# define SUPERHERO_H

# include <lua.hpp>
# include <cstddef>

# define LUA_META_SUPERHERO "SuperHero"

class SuperHero
{
public:
	SuperHero(int x, int y);
	int getX();
	int getY();
private:
	int m_x, m_y;
};

static int superHero_new(lua_State *L);
static int superHero_getX(lua_State *L);
static int superHero_getY(lua_State *L);
static int superHero_getPosition(lua_State *L);
static int superHero_free(lua_State *L);

#endif
