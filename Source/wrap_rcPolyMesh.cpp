#include "wrap_rcPolyMesh.h"

/*static*/ int wrap_rcPolyMesh_new(lua_State *L) {
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCONTEXT));
	rcContourSet *contourSet = *static_cast<rcContourSet**>(luaL_checkudata(L, 2, LUA_META_WRAP_RCCONTOURSET));

	*static_cast<rcPolyMesh**>(lua_newuserdata(L, sizeof(rcPolyMesh*))) = rcAllocPolyMesh();

	if (luaL_newmetatable(L, LUA_META_WRAP_RCPOLYMESH)) {
		static const luaL_Reg methods[] = {
			{"getVerts", getVerts},
			{"getPolys", getPolys},
			{"getNvp", getNvp},
			{"__gc", wrap_rcPolyMesh_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	rcPolyMesh *polyMesh = *static_cast<rcPolyMesh**>(luaL_checkudata(L, 3, LUA_META_WRAP_RCPOLYMESH));

	if(!rcBuildPolyMesh(context, *contourSet, 4, *polyMesh))
	{
		luaL_error(L, "error - build polyMesh\n");
		return 0;
	}

	return 1;
}

static int getVerts(lua_State *L) {
	rcPolyMesh *polyMesh = *static_cast<rcPolyMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCPOLYMESH));

	for (int i = 0; i < polyMesh->nverts; ++i){
		lua_pushnumber(L, polyMesh->bmin[0] + polyMesh->verts[i * 3 + 0] * polyMesh->cs);
		lua_pushnumber(L, polyMesh->bmin[2] + polyMesh->verts[i * 3 + 2] * polyMesh->cs);
	}

	return polyMesh->nverts * 2;
}

static int getPolys(lua_State *L) {
	rcPolyMesh *polyMesh = *static_cast<rcPolyMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCPOLYMESH));

	for (int i = 0; i < polyMesh->npolys; ++i){
		for (int j = 0; j < polyMesh->nvp; ++j) {
			lua_pushnumber(L, polyMesh->polys[i * 2 * polyMesh->nvp + j] + 1);
		}
	}

	return polyMesh->npolys * polyMesh->nvp;
}

static int getNvp(lua_State *L) {
	rcPolyMesh *polyMesh = *static_cast<rcPolyMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCPOLYMESH));

	lua_pushnumber(L, polyMesh->nvp);

	return 1;
}

static int wrap_rcPolyMesh_free(lua_State *L) {
	printf("wrap_rcPolyMesh_free\n");
	rcPolyMesh *polyMesh = *static_cast<rcPolyMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCPOLYMESH));
	rcFreePolyMesh(polyMesh);
	return 0;
}

extern "C" int luaopen_wrap_rcPolyMesh(lua_State *L) {
	lua_pushcfunction(L, wrap_rcPolyMesh_new);
	return 1;
}
