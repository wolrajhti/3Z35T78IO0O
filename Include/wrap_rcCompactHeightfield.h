#ifndef WRAP_RCCOMPACTHEIGHTFIELD_H
# define WRAP_RCCOMPACTHEIGHTFIELD_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>

# include "Recast.h"
# include "wrap_rcContext.h"
# include "wrap_rcHeightfield.h"

# define LUA_META_WRAP_RCCOMPACTHEIGHTFIELD "wrap_rcCompactHeightfield"

/*static*/ int wrap_rcCompactHeightfield_new(lua_State *L);

static int wrap_rcErodeWalkableArea(lua_State *L);
static int wrap_rcBuildDistanceField(lua_State *L);
static int wrap_rcBuildRegions(lua_State *L);

static int wrap_rcCompactHeightfield_free(lua_State *L);

#endif
