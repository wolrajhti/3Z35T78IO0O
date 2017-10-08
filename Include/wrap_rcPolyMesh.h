#ifndef WRAP_RCPOLYMESH_H
# define WRAP_RCPOLYMESH_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>

# include "Recast.h"
# include "wrap_rcContext.h"
# include "wrap_rcContourSet.h"

# define LUA_META_WRAP_RCPOLYMESH "wrap_rcPolyMesh"

/*static*/ int wrap_rcPolyMesh_new(lua_State *L);
static int getVerts(lua_State *L);
static int getPolys(lua_State *L);
static int getAreas(lua_State *L);
static int getNvp(lua_State *L);
static int wrap_rcPolyMesh_free(lua_State *L);

#endif
