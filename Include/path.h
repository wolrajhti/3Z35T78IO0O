#ifndef PATH_H
# define PATH_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>
# include <string.h>
# include <stdlib.h>

# include "DetourNavMesh.h"
// # include "DetourNavMeshBuilder.h"
// # include "DetourNavMeshQuery.h"
// # include "DetourPathCorridor.h"
// # include "wrap_dtNavMesh.h"

# define LUA_META_PATH "Path"

// typedef dtPolyRef *Path;

/*static*/ int path_new(lua_State *L);

// static int findPath(lua_State *L);

static int path_free(lua_State *L);

#endif
