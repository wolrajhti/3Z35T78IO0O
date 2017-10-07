#include "wrap_dtNavMeshQuery.h"

/*static*/ int wrap_dtNavMeshQuery_new(lua_State *L) {
	dtNavMesh *navMesh = *static_cast<dtNavMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTNAVMESH));

	*static_cast<dtNavMeshQuery**>(lua_newuserdata(L, sizeof(dtNavMeshQuery*))) = new dtNavMeshQuery();

	if (luaL_newmetatable(L, LUA_META_WRAP_DTNAVMESHQUERY)) {
		static const luaL_Reg methods[] = {
			{"findNearestPoly", findNearestPoly},
			{"findPath", findPath},
			{"__gc", wrap_dtNavMeshQuery_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	dtNavMeshQuery *navMeshQuery = *static_cast<dtNavMeshQuery**>(luaL_checkudata(L, 2, LUA_META_WRAP_DTNAVMESHQUERY));

	navMeshQuery->init(navMesh, 65535);

	return 1;
}

static int findNearestPoly(lua_State *L) {
	printf("\nfindNearestPoly\n---------------\n");
	dtNavMeshQuery *navMeshQuery = *static_cast<dtNavMeshQuery**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTNAVMESHQUERY));

	float *pos = *static_cast<float**>(luaL_checkudata(L, 2, LUA_META_VECTOR3F));

	/* passing navMesh here for debug purpose only */
	dtNavMesh *navMesh = *static_cast<dtNavMesh**>(luaL_checkudata(L, 3, LUA_META_WRAP_DTNAVMESH));

	printf("input = %.2f, %.2f, %.2f\n", pos[0], pos[1], pos[2]);

	float output[3];

	lua_pushnumber(L, 1);

	path_new(L);

	dtPolyRef *poly = *static_cast<dtPolyRef**>(luaL_checkudata(L, 4, LUA_META_PATH));

	if (dtStatusFailed(navMeshQuery->findNearestPoly(
		pos,
		(float[3]){1.0, 1.0, 1.0},
		new dtQueryFilter(),
		poly,
		output
	))) {
		luaL_error(L, "FIND NEAREST START FAILED\n");
	};

	printf("output = %.2f, %.2f, %.2f\n", output[0], output[1], output[2]);

	pos[0] = output[0];
	pos[1] = output[1];
	pos[2] = output[2];

	if (!navMesh->isValidPolyRef(*poly)) {
		luaL_error(L, "Invalid dtPolyRef.");
	}

	return 1;
}

static int findPath(lua_State *L) {
	printf("\nfindPath\n--------\n");
	dtNavMeshQuery *navMeshQuery = *static_cast<dtNavMeshQuery**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTNAVMESHQUERY));

	float *start = *static_cast<float**>(luaL_checkudata(L, 2, LUA_META_VECTOR3F));
	float *end = *static_cast<float**>(luaL_checkudata(L, 3, LUA_META_VECTOR3F));

	printf("start %.2f %.2f %.2f \n", start[0], start[1], start[2]);
	printf("end   %.2f %.2f %.2f \n", end[0], end[1], end[2]);

	dtPolyRef *pStart = *static_cast<dtPolyRef**>(luaL_checkudata(L, 4, LUA_META_PATH));
	dtPolyRef *pEnd = *static_cast<dtPolyRef**>(luaL_checkudata(L, 5, LUA_META_PATH));

	int npoly;
	dtPolyRef path[32];

	if (dtStatusFailed(navMeshQuery->findPath(
		*pStart,
		*pEnd,
		start,
		end,
		new dtQueryFilter(),
		path,
		&npoly,
		32
	))) {
		luaL_error(L, "FINDPATH FAILED");
	};

	lua_pushnumber(L, npoly);

	lua_pushnumber(L, npoly);

	path_new(L);

	dtPolyRef *uPath = *static_cast<dtPolyRef**>(luaL_checkudata(L, 7, LUA_META_PATH));

	for (int i = 0; i < npoly; ++i) {
		uPath[i] = path[i];
	}

	return 2;
}

static int wrap_dtNavMeshQuery_free(lua_State *L) {
	printf("wrap_dtNavMeshQuery_free\n");
	dtNavMeshQuery *navMeshQuery = *static_cast<dtNavMeshQuery**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTNAVMESHQUERY));
	delete navMeshQuery;
	return 0;
}

extern "C" int luaopen_wrap_dtNavMeshQuery(lua_State *L) {
	lua_pushcfunction(L, wrap_dtNavMeshQuery_new);
	return 1;
}
