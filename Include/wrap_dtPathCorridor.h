#ifndef WRAP_DTPATHCORRIDOR_H
# define WRAP_DTPATHCORRIDOR_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>
# include <string.h>
# include <stdlib.h>

# include "DetourNavMesh.h"
// # include "DetourNavMeshBuilder.h"
# include "DetourNavMeshQuery.h"
# include "DetourPathCorridor.h"
# include "wrap_dtNavMesh.h"
# include "wrap_dtQueryFilter.h"
# include "wrap_dtNavMeshQuery.h"
# include "path.h"

# define LUA_META_WRAP_DTPATHCORRIDOR "wrap_dtPathCorridor"

/*static*/ int wrap_dtPathCorridor_new(lua_State *L);

static int reset(lua_State *L);
static int setCorridor(lua_State *L);
static int wrap_dtPathCorridor_findCorners(lua_State *L);
static int wrap_dtPathCorridor_movePosition(lua_State *L);
static int wrap_dtPathCorridor_moveTargetPosition(lua_State *L);
static int wrap_dtPathCorridor_moveOverOffmeshConnection(lua_State *L);
static int wrap_dtPathCorridor_optimizePathTopology(lua_State *L);

static int wrap_dtPathCorridor_free(lua_State *L);

#endif
