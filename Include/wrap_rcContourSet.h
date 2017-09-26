#ifndef WRAP_RCCONTOURSET_H
# define WRAP_RCCONTOURSET_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>

# include "Recast.h"
# include "wrap_rcContext.h"
# include "wrap_rcCompactHeightfield.h"

# define LUA_META_WRAP_RCCONTOURSET "wrap_rcContourSet"

/*static*/ int wrap_rcContourSet_new(lua_State *L);

static int wrap_rcContourSet_free(lua_State *L);

#endif
