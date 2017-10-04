#ifndef WRAP_DTNAVMESHQUERY_H
# define WRAP_DTNAVMESHQUERY_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>
# include <string.h>
# include <stdlib.h>

# include "DetourNavMesh.h"
# include "DetourNavMeshQuery.h"
# include "wrap_dtNavMesh.h"
# include "path.h"
# include "vector3f.h"

# define LUA_META_WRAP_DTNAVMESHQUERY "wrap_dtNavMeshQuery"

/*static*/ int wrap_dtNavMeshQuery_new(lua_State *L);

static int findNearestPoly(lua_State *L);
static int findPath(lua_State *L);

static int wrap_dtNavMeshQuery_free(lua_State *L);

#endif
