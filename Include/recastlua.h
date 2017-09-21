#ifndef RECASTLUA_H
# define RECASTLUA_H

# include "Recast.h"
# include "RecastAlloc.h"
# include "RecastAssert.h"

# include "DetourAlloc.h"
# include "DetourAssert.h"
# include "DetourCommon.h"
# include "DetourMath.h"
# include "DetourNavMesh.h"
# include "DetourNavMeshBuilder.h"
# include "DetourNavMeshQuery.h"
# include "DetourNode.h"
# include "DetourStatus.h"

# include <stdio.h>
# include <string>
# include <lua.hpp>
# include <ctime>
# include <cstdlib>

# define WIDTH 800
# define HEIGHT 600

// typedef struct Player
// {
// 	int x, y;
// } Player;

#define LUA_META_PLAYER "Player"

class Player
{
public:
	Player(int x, int y) { m_x = x; m_y = y;}
	int getX() { return m_x;}
	int getY() { return m_y;}
private:
	int m_x, m_y;
};

static int player_new(lua_State *L);
static int player_getX(lua_State *L);
static int player_getY(lua_State *L);
static int player_getPosition(lua_State *L);
static int player_free(lua_State *L);

#endif
