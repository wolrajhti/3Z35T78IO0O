#ifndef VECTOR3F_H
# define VECTOR3F_H

# include <lua.hpp>
# include <cstddef>

# define LUA_META_VECTOR3F "Vector3f"

class Vector3f
{
public:
	Vector3f(float x, float y, float z);
	float getX();
	float getY();
	float getZ();
	void toArray(float array[3]);
private:
	float m_x, m_y, m_z;
};

static int vector3f_new(lua_State *L);
static int vector3f_getX(lua_State *L);
static int vector3f_getY(lua_State *L);
static int vector3f_getZ(lua_State *L);
static int vector3f_getPosition(lua_State *L);
static int vector3f_free(lua_State *L);

#endif
