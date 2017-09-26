#ifndef WRAP_RCHEIGHTFIELD_H
# define WRAP_RCHEIGHTFIELD_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>

# include "Recast.h"
# include "wrap_rcContext.h"
# include "vector3f.h"

# define LUA_META_WRAP_RCHEIGHTFIELD "wrap_rcHeightfield"

/*static*/ int wrap_rcHeightfield_new(lua_State *L);
static int wrap_rcRasterizeTriangle(lua_State *L);
static int wrap_rcHeightfield_free(lua_State *L);

static int printSpans(lua_State *L);


#endif
