#include "recastlua.h"

int *g_tris = NULL;
unsigned char *g_flags = NULL;
int g_ntris = 0;

static int setTris(lua_State *L) {
	int n = lua_gettop(L);
	if (n > g_ntris) {
		g_tris = (int *)realloc((void *) g_tris, n * sizeof(int));
		g_flags = (unsigned char *)realloc((void *) g_flags, n * sizeof(unsigned char));
	}
	int i;
	for (i = 1; i <= n; ++i) {
	  if (!lua_isnumber(L, i)) {
		lua_pushstring(L, "incorrect argument");
		lua_error(L);
	  }
	  g_tris[i - 1] = lua_tonumber(L, i);
	  g_flags[i - 1] = RC_WALKABLE_AREA;
	  ++g_ntris;
	}
	return 0;
}

static int getNTris(lua_State *L) {
	if (lua_gettop(L)) {
		lua_pushstring(L, "incorrect argument");
		lua_error(L);
	}
	lua_pushnumber(L, g_ntris);
	return 1;
}

static int getTris(lua_State *L) {
	if (lua_gettop(L)) {
		lua_pushstring(L, "incorrect argument");
		lua_error(L);
	}
	int i = -1;
	while (++i < g_ntris) {
		lua_pushnumber(L, g_tris[i]);
	}
	return i;
}

float *g_verts = NULL;
int g_nverts = 0;

static int setVerts(lua_State *L) {
	int n = lua_gettop(L);
	if (3 * n / 2 > g_nverts) {
		g_verts = (float *)realloc((void *) g_verts, 3 * n * sizeof(float) / 2);
	}
	int i;
	for (i = 0; i < n / 2; ++i) {
	  if (!lua_isnumber(L, i + 1)) {
		lua_pushstring(L, "incorrect argument");
		lua_error(L);
	  }
	  g_verts[i * 3 + 0] = lua_tonumber(L, i * 2 + 1);
	  g_verts[i * 3 + 1] = 0;
	  g_verts[i * 3 + 2] = lua_tonumber(L, i * 2 + 2);
	  g_nverts += 3;
	}
	return 0;
}

static int getNVerts(lua_State *L) {
	if (lua_gettop(L)) {
		lua_pushstring(L, "incorrect argument");
		lua_error(L);
	}
	lua_pushnumber(L, g_nverts);
	return 1;
}

static int getVerts(lua_State *L) {
	if (lua_gettop(L)) {
		lua_pushstring(L, "incorrect argument");
		lua_error(L);
	}
	int i = -1;
	while (++i < g_nverts) {
		lua_pushnumber(L, g_verts[i]);
	}
	return i;
}

rcContext *ctx;
rcPolyMesh *polyMesh;
dtNavMesh *navMesh;

const float min[3] = {0.0, 0.0, 0.0};
const float max[3] = {WIDTH, 2.0, HEIGHT};

/* variable needed in lua :
	- rcHeightfield;
	- rcPolyMesh;
*/

static int setPolyMesh(lua_State *L) {
	printf("\nsetPolyMesh :\n-------------\n");

	rcHeightfield *heightfield;
	rcCompactHeightfield *compactHeightfield;
	rcContourSet *contourSet;

	ctx = new rcContext();

	heightfield = rcAllocHeightfield();

	/* args[2-5] : by default, use default love.graphics.getWidth() and love.graphics.getHeight()
	 * args[6]   : size of the cell on xz-plane
	 * args[7]   : size of the cell on y-axis
	 */
	rcCreateHeightfield(ctx, *heightfield, WIDTH, HEIGHT, min, max, 1, 1);

	/* args[7] : the distance where the walkable flag is favored over the non-walkable flag. [Limit: >= 0] [Units: vx]
	 */
	rcRasterizeTriangles(ctx, g_verts, g_nverts / 3, g_tris, g_flags, g_ntris / 3, *heightfield, 0);
	compactHeightfield = rcAllocCompactHeightfield();

	/* args[1] : minimum floor to ceiling height for walkable areas (???)
	 * args[2] : minimum ledge height for walkable areas
	 */
	if (!rcBuildCompactHeightfield(ctx, 3, 0, *heightfield, *compactHeightfield)) {
		printf("error - build chf\n");
		return 0;
	}

	// Erode the walkable area by agent radius.
	if (!rcErodeWalkableArea(ctx, lua_tonumber(L, 1), *compactHeightfield))
	{
		printf("error - erode chf\n");
		return 0;
	}

	if(!rcBuildDistanceField(ctx, *compactHeightfield)) {
		printf("error - build df\n");
		return 0;
	}

	/* args[2] : borderSize (non walkable) in voxels (???)
	 * args[3] : minimum island size in voxels
	 * args[4] : mergeRegionArea (???)
	 */
	if(!rcBuildRegions(ctx, *compactHeightfield, 0, 0, 0)) {
		printf("error - build regions\n");
		return 0;
	}

	contourSet = rcAllocContourSet();

	/* args[2] : maxError	The maximum distance a simplfied contour's border edges should deviate the original raw contour. [Limit: >=0] [Units: wu]
	 * args[3] : maxEdgeLen	The maximum allowed length for contour edges along the border of the mesh. [Limit: >=0] [Units: vx]
	 */
	if(!rcBuildContours(ctx, *compactHeightfield, 1.0, 0, *contourSet, RC_CONTOUR_TESS_WALL_EDGES /*| RC_CONTOUR_TESS_AREA_EDGES*/)) {
		printf("error - build contours\n");
		return 0;
	}

	polyMesh = rcAllocPolyMesh();

	if(!rcBuildPolyMesh(ctx, *contourSet, 4, *polyMesh)) {
		printf("error - build polyMesh\n");
		return 0;
	}

	for (int i = 0; i < polyMesh->npolys; ++i){
		polyMesh->flags[i] = 12;
	}

	printf("npoly %d:\n", polyMesh->npolys);

	// for (int i = 0; i < polyMesh->npolys; ++i){
	// 	printf("poly %d:\n", i);
	// 	printf("\t%hu %hu %hu %hu\n",
	// 		polyMesh->polys[i * 2 * polyMesh->nvp + 0],
	// 		polyMesh->polys[i * 2 * polyMesh->nvp + 1],
	// 		polyMesh->polys[i * 2 * polyMesh->nvp + 2],
	// 		polyMesh->polys[i * 2 * polyMesh->nvp + 3]
	// 	);
	// }

	printf("nverts %d:\n", polyMesh->nverts);

	// for (int i = 0; i < polyMesh->nverts; ++i){
	// 	printf("vert %d:\n", i);
	// 	printf("\t%.3f %.3f %.3f\n",
	// 		polyMesh->bmin[0] + polyMesh->verts[i * 3 + 0] * polyMesh->cs,
	// 		polyMesh->bmin[1] + polyMesh->verts[i * 3 + 1] * polyMesh->ch,
	// 		polyMesh->bmin[2] + polyMesh->verts[i * 3 + 2] * polyMesh->cs
	// 	);
	// }

	rcFreeHeightField(heightfield);
	rcFreeCompactHeightfield(compactHeightfield);
	rcFreeContourSet(contourSet);

	return 0;
}

static int setNavMesh(lua_State *L) {
	printf("\nsetNavMesh :\n------------\n");

	// for (int i = 0; i < polyMesh->npolys; ++i)
	// {
	// 	polyMesh->flags[i] = 12;
	// }

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
	// params.walkableRadius = lua_tonumber(L, 1);
	params.walkableClimb = 0;
	params.cs = polyMesh->cs;
	params.ch = polyMesh->ch;
	params.buildBvTree = true;
	rcVcopy(params.bmin, polyMesh->bmin);
	rcVcopy(params.bmax, polyMesh->bmax);


	// printf("VERTS - VERTS - VERTS\n");
	//
	// for (int i = 0; i < polyMesh->nverts; ++i)
	// {
	// 	float worldX = polyMesh->bmin[0] + polyMesh->verts[i * 3 + 0] * polyMesh->cs;
	// 	float worldY = polyMesh->bmin[1] + polyMesh->verts[i * 3 + 1] * polyMesh->ch;
	// 	float worldZ = polyMesh->bmin[2] + polyMesh->verts[i * 3 + 2] * polyMesh->cs;
	// 	printf("\t%.3f %.3f %.3f\n", worldX, worldY, worldZ);
	// }


	printf(
		"vertCount = %d\n"
		"polyCount = %d\n"
		"nvp = %d\n"
		"radius = %f\n",
		params.vertCount,
		params.polyCount,
		params.nvp,
		params.walkableRadius
	);

	unsigned char* navData = 0;
	int navDataSize = 0;

	if (!dtCreateNavMeshData(&params, &navData, &navDataSize))
	{
		ctx->log(RC_LOG_ERROR, "Could not build Detour navmesh.");
		return 0;
	}

	// for (int i = 0; i < polyMesh->npolys; ++i) {
	// 	printf("flags[%d] = %hu\n", i, polyMesh->flags[i]);
	// }

	navMesh = new dtNavMesh();

	/* SOLO */
	navMesh->init(navData, navDataSize, DT_TILE_FREE_DATA);

	/* TILED */
	// dtNavMeshParams *navMeshParams;
	// navMesh->init(navMeshParams);
	// navMesh->addTile(navData, navDataSize, DT_TILE_FREE_DATA, 0, 0);

	printf("getMaxTile = %d\n", navMesh->getMaxTiles());

	// const dtNavMesh &mesh = *navMesh;

	// for (int i = 0; i < navMesh->getMaxTiles(); ++i)
	// {
	// 	const dtMeshTile* tile = mesh.getTile(i);
	// 	if (!tile->header) continue;
	// 	printf("tile->header->polyCount = %d\n", tile->header->polyCount);
	//
	// 	const dtPolyRef base = navMesh->getPolyRefBase(tile);
	// 	for (int i = 0; i < tile->header->polyCount; ++i)
	// 	{
	// 	    const dtPoly* p = &tile->polys[i];
	// 	    // const dtPolyRef ref = base | (dtPolyRef)i;
	// 		printf("\n");
	// 		for (int j = 0; j < p->vertCount; ++j) {
	// 			printf("\tp->verts[i] = %.f %.f %.f\n",
	// 				tile->verts[p->verts[j] * 3 + 0],
	// 				tile->verts[p->verts[j] * 3 + 1],
	// 				tile->verts[p->verts[j] * 3 + 2]
	// 			);
	// 		}
	// 	    // Use the reference to access the polygon data.
	// 	}
	// }

	return 0;
}

float rand_01(){
	return 0.95;
}

float rand_02(){
	return 0.05;
}

int sCount;

static int queryNavMesh(lua_State *L) {
	printf("\nqueryNavMesh :\n--------------\n");
	dtNavMeshQuery *navMeshQuery;
	navMeshQuery = new dtNavMeshQuery();

	navMeshQuery->init(navMesh, 65535);

	dtPolyRef *polyStart, *polyEnd;

	polyStart = new dtPolyRef();
	polyEnd = new dtPolyRef();

	float posStart[3], posEnd[3];

	float posStart2[3], posEnd2[3];

	posStart[0] = lua_tonumber(L, 1);
	posStart[1] = 0.0;
	posStart[2] = lua_tonumber(L, 2);

	posEnd[0]   = lua_tonumber(L, 3);
	posEnd[1]   = 0.0;
	posEnd[2]   = lua_tonumber(L, 4);

	if (dtStatusFailed(navMeshQuery->findNearestPoly(
		posStart,
		(float[3]){1.0, 1.0, 1.0},
		new dtQueryFilter(),
		polyStart,
		posStart2
	))) {
		printf("FIND NEAREST START FAILED\n");
	};

	if (dtStatusFailed(navMeshQuery->findNearestPoly(
		posEnd,
		(float[3]){1.0, 1.0, 1.0},
		new dtQueryFilter(),
		polyEnd,
		posEnd2
	))) {
		printf("FIND NEAREST END FAILED\n");
	};

	// navMeshQuery->findRandomPoint(
	// 	new dtQueryFilter(),
	// 	&rand_01,
	// 	polyStart,
	// 	posStart
	// );
	//
	// navMeshQuery->findRandomPoint(
	// 	new dtQueryFilter(),
	// 	&rand_02,
	// 	polyEnd,
	// 	posEnd
	// );

	printf("start %.3f %.3f %.3f \n", posStart[0], posStart[1], posStart[2]);
	printf("end   %.3f %.3f %.3f \n", posEnd[0], posEnd[1], posEnd[2]);

	if (navMesh->isValidPolyRef(*polyStart)) {
		printf("Valid start.\n");
	}

	if (navMesh->isValidPolyRef(*polyEnd)) {
		printf("Valid end.\n");
	}

	dtPolyRef path[32];
	int npoly;

	if (dtStatusFailed(navMeshQuery->findPath(
		*polyStart,
		*polyEnd,
		posStart,
		posEnd,
		new dtQueryFilter(),
		path,
		&npoly,
		32
	))) {
		printf("FAILED\n");
	};

	printf("npoly = %d\n", npoly);

	lua_pushnumber(L, posStart[0]);
	lua_pushnumber(L, posStart[2]);
	lua_pushnumber(L, posEnd[0]);
	lua_pushnumber(L, posEnd[2]);
	lua_pushnumber(L, npoly);

	const dtNavMesh &mesh = *navMesh;

	dtPolyRef base = mesh.getPolyRefBase(mesh.getTile(0));

	const dtMeshTile* _tile = 0;
	const dtPoly* _poly = 0;

	for (int i = 0; i < npoly; ++i) {
		lua_pushnumber(L, mesh.decodePolyIdPoly(path[i]));
		printf("passing through %u\n", mesh.decodePolyIdPoly(path[i]));
	}

	//straightPath
	float sPath[32];
	unsigned char sFlags[32];
	dtPolyRef sRefs[32];

	if (dtStatusFailed(navMeshQuery->findStraightPath(
		posStart,
		posEnd,
		path,
		npoly,
		sPath,
		sFlags,
		sRefs,
		&sCount,
		32
	))) {
		printf("FAILED\n");
	};

	for (int i = 0; i < sCount; ++i) {
		lua_pushnumber(L, sPath[i * 3 + 0]);
		lua_pushnumber(L, sPath[i * 3 + 2]);
		printf("straightPath %.1f, %.1f, %.1f\n", sPath[i * 3 + 0], sPath[i * 3 + 1], sPath[i * 3 + 2]);
	}

	return 5 + npoly + 2 * sCount;
}

static int getRcVerts(lua_State *L) {
	for (int i = 0; i < polyMesh->nverts; ++i){
		lua_pushnumber(L, polyMesh->bmin[0] + polyMesh->verts[i * 3 + 0] * polyMesh->cs);
		// lua_pushnumber(L, polyMesh->bmin[1] + polyMesh->verts[i * 3 + 1] * polyMesh->ch);
		lua_pushnumber(L, polyMesh->bmin[2] + polyMesh->verts[i * 3 + 2] * polyMesh->cs);
	}
	return polyMesh->nverts * 2;
}

static int getRcPolys(lua_State *L) {
	for (int i = 0; i < polyMesh->npolys; ++i){
		for (int j = 0; j < polyMesh->nvp; ++j) {
			lua_pushnumber(L, polyMesh->polys[i * 2 * polyMesh->nvp + j] + 1);
		}
	}
	return polyMesh->npolys * polyMesh->nvp;
}

static int getRcNVP(lua_State *L) {
	lua_pushnumber(L, polyMesh->nvp);
	return 1;
}

static int getRcSCount(lua_State *L) {
	lua_pushnumber(L, sCount);
	return 1;
}

extern "C" int luaopen_recastlua(lua_State *L) {
	luaL_Reg reg[] = {
		{"setTris", setTris},
		{"getTris", getTris},
		{"getNTris", getNTris},

		{"setVerts", setVerts},
		{"getVerts", getVerts},
		{"getNVerts", getNVerts},

		{"setPolyMesh", setPolyMesh},

		{"getRcVerts", getRcVerts},
		{"getRcPolys", getRcPolys},
		{"getRcNVP", getRcNVP},
		{"getRcSCount", getRcSCount},

		{"setNavMesh", setNavMesh},

		{"queryNavMesh", queryNavMesh},

		{NULL, NULL}
	};

	lua_newtable(L);
	luaL_register(L, NULL, reg);

	return 1;
}
