#ifndef VECTOR3F_H
# define VECTOR3F_H

# include <lua.hpp>
# include <cstddef>
# include <cstdio>
# include <stdlib.h>

# define LUA_META_VECTOR3F "Vector3f"

/*static*/ int vector3f_new(lua_State *L);
static int vector3f_getX(lua_State *L);
static int vector3f_getY(lua_State *L);
static int vector3f_getZ(lua_State *L);
static int vector3f_setX(lua_State *L);
static int vector3f_setY(lua_State *L);
static int vector3f_setZ(lua_State *L);
static int vector3f_getPosition(lua_State *L);
static int vector3f_free(lua_State *L);

#endif
