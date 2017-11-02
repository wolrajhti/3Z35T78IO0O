#include "wrap_dtNavMesh.h"

int wrap_dtNavMesh_new(lua_State *L) {
	rcPolyMesh *polyMesh = *static_cast<rcPolyMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCPOLYMESH));

	int offset = lua_gettop(L) == 2 ? 1 : 0;

	printf("gettop = %d\n", lua_gettop(L));

	*static_cast<dtNavMesh**>(lua_newuserdata(L, sizeof(dtNavMesh*))) = new dtNavMesh();

	if (luaL_newmetatable(L, LUA_META_WRAP_DTNAVMESH)) {
		static const luaL_Reg methods[] = {
			{"getOffMeshConnections", wrap_dtNavMesh_getOffMeshConnections},
			{"__gc", wrap_dtNavMesh_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}
	lua_setmetatable(L, -2);

	dtNavMesh *navMesh = *static_cast<dtNavMesh**>(luaL_checkudata(L, 2 + offset, LUA_META_WRAP_DTNAVMESH));

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

	int size = 0;

	if (offset) {
		lua_pushnil(L);  /* first key */
		while (lua_next(L, 2) != 0) {
		  /* uses 'key' (at index -2) and 'value' (at index -1) */
		//   printf("%s - %.2f\n",
		// 		 lua_typename(L, lua_type(L, -2)),
		// 		 luaL_checknumber(L, -1));
		  /* removes 'value'; keeps 'key' for next iteration */
		  lua_pop(L, 1);
		  ++size;
		}
		printf("size = %d\n", size);
	}

	int offMeshConCount = size / 11;

	float offMeshConVerts[6 * offMeshConCount];
	float offMeshConRads[offMeshConCount];
	unsigned char offMeshConDirs[offMeshConCount];
	unsigned char offMeshConAreas[offMeshConCount];
	unsigned short offMeshConFlags[offMeshConCount];
	unsigned int offMeshConId[offMeshConCount];

	for (int i = 0; i < size; i += 11) {
		for (int j = 0; j < 11; ++j) {
			lua_rawgeti(L, 2, i + j + 1);
		}
		printf("POP1\n");
		offMeshConVerts[i * 6 + 0] = (float)luaL_checknumber(L, -11);
		printf("POP2\n");
		offMeshConVerts[i * 6 + 1] = (float)luaL_checknumber(L, -10);
		printf("POP3\n");
		offMeshConVerts[i * 6 + 2] = (float)luaL_checknumber(L, -9);
		printf("POP4\n");

		offMeshConVerts[i * 6 + 3] = (float)luaL_checknumber(L, -8);
		printf("POP5\n");
		offMeshConVerts[i * 6 + 4] = (float)luaL_checknumber(L, -7);
		printf("POP6\n");
		offMeshConVerts[i * 6 + 5] = (float)luaL_checknumber(L, -6);
		printf("POP7\n");

		offMeshConRads[i] = (float)luaL_checknumber(L, -5);
		printf("POP8\n");

		offMeshConDirs[i] = luaL_checkint(L, -4) == 2 ? DT_OFFMESH_CON_BIDIR : 0;
		printf("POP9\n");

		offMeshConAreas[i] = luaL_checkint(L, -3);
		printf("POP10\n");

		offMeshConFlags[i] = luaL_checkint(L, -2);
		printf("POP11\n");

		offMeshConId[i] = luaL_checkint(L, -1);
		printf("POP12\n");

		lua_pop(L, 11);
		printf("POP\n");
	}

	params.offMeshConVerts = offMeshConVerts;
	params.offMeshConRad = offMeshConRads;
	params.offMeshConDir = offMeshConDirs;
	params.offMeshConAreas = offMeshConAreas;
	params.offMeshConFlags = offMeshConFlags;
	params.offMeshConUserID = offMeshConId;
	params.offMeshConCount = offMeshConCount;

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

	printf("polyCount = %d\n", ((const dtNavMesh*)navMesh)->getTile(0)->header->polyCount);
	printf("offMeshConCount = %d\n", ((const dtNavMesh*)navMesh)->getTile(0)->header->offMeshConCount);
	printf("offMeshBase = %d\n", ((const dtNavMesh*)navMesh)->getTile(0)->header->offMeshBase);

	/* TILED */
	// dtNavMeshParams *navMeshParams;
	// navMesh->init(navMeshParams);
	// navMesh->addTile(navData, navDataSize, DT_TILE_FREE_DATA, 0, 0);

	return 1;
}

static int wrap_dtNavMesh_getOffMeshConnections(lua_State *L) {
	dtNavMesh *navMesh = *static_cast<dtNavMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTNAVMESH));

	int count = 0;

	for (int i = 0; i < navMesh->getMaxTiles(); ++i)
	{
		const dtMeshTile* tile = ((const dtNavMesh*)navMesh)->getTile(i);
		if (!tile->header) continue;
		count += tile->header->offMeshConCount;
	}

	lua_pushnumber(L, count);

	lua_pushnumber(L, count);

	path_new(L);

	dtPolyRef *offMeshConPolyRef = *static_cast<dtPolyRef**>(luaL_checkudata(L, 3, LUA_META_PATH));

	int k = 0;

	for (int i = 0; i < navMesh->getMaxTiles(); ++i)
	{
		const dtMeshTile* tile = ((const dtNavMesh*)navMesh)->getTile(i);
		const dtPolyRef base = navMesh->getPolyRefBase(tile);
		if (!tile->header) continue;
		for (int j = 0; j < tile->header->offMeshConCount; ++j)
		{
			offMeshConPolyRef[k] = base | (dtPolyRef)tile->offMeshCons[j].poly;
			++k;
		}
	}

	return 2;
}

static int wrap_dtNavMesh_free(lua_State *L) {
	// printf("wrap_dtNavMesh_free\n");
	dtNavMesh *navMesh = *static_cast<dtNavMesh**>(luaL_checkudata(L, 1, LUA_META_WRAP_DTNAVMESH));
	delete navMesh;
	return 0;
}

extern "C" int luaopen_wrap_dtNavMesh(lua_State *L) {
	lua_pushcfunction(L, wrap_dtNavMesh_new);
	return 1;
}
