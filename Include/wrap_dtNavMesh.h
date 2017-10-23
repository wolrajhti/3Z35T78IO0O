#ifndef WRAP_DTNAVMESH_H
# define WRAP_DTNAVMESH_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>
# include <string.h>
# include <stdlib.h>

# include "DetourNavMesh.h"
# include "DetourNavMeshBuilder.h"
# include "wrap_rcPolyMesh.h"
# include "path.h"

# define LUA_META_WRAP_DTNAVMESH "wrap_dtNavMesh"

/*static*/ int wrap_dtNavMesh_new(lua_State *L);

static int wrap_dtNavMesh_getOffMeshConnections(lua_State *L);

static int wrap_dtNavMesh_free(lua_State *L);

#endif
