#ifndef WRAP_RCCONTEXT_H
# define WRAP_RCCONTEXT_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>

# include "Recast.h"

# define LUA_META_WRAP_RCCONTEXT "wrap_rcContext"

/*static*/ int wrap_rcContext_new(lua_State *L);
static int wrap_rcContext_free(lua_State *L);

#endif
