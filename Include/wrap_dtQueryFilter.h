#ifndef WRAP_DTQUERYFILTER_H
# define WRAP_DTQUERYFILTER_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>
# include <string.h>
# include <stdlib.h>

# include "wrap_dtNavMeshQuery.h"

# define LUA_META_WRAP_DTQUERYFILTER "wrap_dtQueryFilter"

/*static*/ int wrap_dtQueryFilter_new(lua_State *L);

static int wrap_dtQueryFilter_setAreaCost(lua_State *L);
static int wrap_dtQueryFilter_free(lua_State *L);

#endif
