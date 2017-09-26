#ifndef WRAP_DTNAVMESH_H
# define WRAP_DTNAVMESH_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>
# include <string.h>
# include <stdlib.h>

# include "DetourNavMesh.h"
# include "DetourNavMeshBuilder.h"
# include "DetourNavMeshQuery.h"
# include "wrap_rcPolyMesh.h"

# define LUA_META_WRAP_DTNAVMESH "wrap_dtNavmesh"

/*static*/ int wrap_dtNavMesh_new(lua_State *L);

static int findPath(lua_State *L);

static int wrap_dtNavMesh_free(lua_State *L);

#endif
