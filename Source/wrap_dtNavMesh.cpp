#include "wrap_dtNavMesh.h"

/*static*/ int wrap_dtNavMesh_new(lua_State *L) {
	rcPolyMesh *polyMesh = *static_cast<rcPolyMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCPOLYMESH));

	*static_cast<dtNavMesh**>(lua_newuserdata(L, sizeof(dtNavMesh*))) = new dtNavMesh();

	if (luaL_newmetatable(L, LUA_META_WRAP_DTNAVMESH)) {
		static const luaL_Reg methods[] = {
			{"findPath", findPath},
			{"__gc", wrap_dtNavMesh_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	dtNavMesh *navMesh = *static_cast<dtNavMesh**>(luaL_checkudata(L, 2, LUA_META_WRAP_DTNAVMESH));

	dtNavMeshCreateParams params;

	memset(&params, 0, sizeof(params));

	params.verts = polyMesh->verts;
	params.vertCount = polyMesh->nverts;
	params.polys = polyMesh->polys;
	params.polyAreas = polyMesh->areas;
	params.polyFlags = polyMesh->flags;
	params.polyCount = polyMesh->npolys;
	params.nvp = polyMesh->nvp;
	params.walkableHeight = 1;
	params.walkableClimb = 0;
	params.cs = polyMesh->cs;
	params.ch = polyMesh->ch;
	params.buildBvTree = true;

	rcVcopy(params.bmin, polyMesh->bmin);
	rcVcopy(params.bmax, polyMesh->bmax);

	unsigned char* navData = 0;
	int navDataSize = 0;

	if (!dtCreateNavMeshData(&params, &navData, &navDataSize))
	{
		luaL_error(L, "Could not build Detour navmesh.");
		return 0;
	}

	/* SOLO */
	navMesh->init(navData, navDataSize, DT_TILE_FREE_DATA);

	/* TILED */
	// dtNavMeshParams *navMeshParams;
	// navMesh->init(navMeshParams);
	// navMesh->addTile(navData, navDataSize, DT_TILE_FREE_DATA, 0, 0);

	return 1;
}

static int findPath(lua_State *L) {
	dtNavMesh *navMesh = *static_cast<dtNavMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTNAVMESH));

	Vector3f *vStart = *static_cast<Vector3f**>(luaL_checkudata(L, 2, LUA_META_VECTOR3F));
	Vector3f *vEnd = *static_cast<Vector3f**>(luaL_checkudata(L, 3, LUA_META_VECTOR3F));

	float start[3], end[3];
	float oStart[3], oEnd[3];

	vStart->toArray(start);
	vEnd->toArray(end);

	printf("start %.3f %.3f %.3f \n", start[0], start[1], start[2]);
	printf("end   %.3f %.3f %.3f \n", end[0], end[1], end[2]);

	dtNavMeshQuery *navMeshQuery = new dtNavMeshQuery();

	navMeshQuery->init(navMesh, 65535);

	dtPolyRef *pStart = new dtPolyRef();
	dtPolyRef *pEnd = new dtPolyRef();

	if (dtStatusFailed(navMeshQuery->findNearestPoly(
		start,
		(float[3]){1.0, 1.0, 1.0},
		new dtQueryFilter(),
		pStart,
		oStart
	))) {
		luaL_error(L, "FIND NEAREST START FAILED\n");
	};

	if (dtStatusFailed(navMeshQuery->findNearestPoly(
		end,
		(float[3]){1.0, 1.0, 1.0},
		new dtQueryFilter(),
		pEnd,
		oEnd
	))) {
		luaL_error(L, "FIND NEAREST END FAILED\n");
	};

	printf("oStart %.3f %.3f %.3f \n", oStart[0], oStart[1], oStart[2]);
	printf("oEnd   %.3f %.3f %.3f \n", oEnd[0], oEnd[1], oEnd[2]);

	if (navMesh->isValidPolyRef(*pStart)) {
		printf("Valid start.\n");
	}

	if (navMesh->isValidPolyRef(*pEnd)) {
		printf("Valid end.\n");
	}

	dtPolyRef path[32];
	int npoly;

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
		printf("FAILED\n");
	};

	printf("npoly = %d\n", npoly);

	lua_pushnumber(L, start[0]);
	lua_pushnumber(L, start[2]);
	lua_pushnumber(L, end[0]);
	lua_pushnumber(L, end[2]);
	lua_pushnumber(L, npoly);

	const dtNavMesh &mesh = *navMesh;

	for (int i = 0; i < npoly; ++i) {
		lua_pushnumber(L, mesh.decodePolyIdPoly(path[i]));
		printf("passing through %u\n", mesh.decodePolyIdPoly(path[i]));
	}

	delete navMeshQuery;
	delete pStart;
	delete pEnd;

	return 5 + npoly;
}

static int wrap_dtNavMesh_free(lua_State *L) {
	printf("wrap_dtNavMesh_free\n");
	dtNavMesh *context = *static_cast<dtNavMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTNAVMESH));
	delete context;
	return 0;
}

extern "C" int luaopen_wrap_dtNavMesh(lua_State *L) {
	lua_pushcfunction(L, wrap_dtNavMesh_new);
	return 1;
}
