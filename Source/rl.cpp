#include "rl.h"

extern "C" int luaopen_rl(lua_State *L) {
	luaL_Reg constructors[] = {
		{"newRcContext", wrap_rcContext_new},
		{"newRcHeightfield", wrap_rcHeightfield_new},
		{"newRcCompactHeightfield", wrap_rcCompactHeightfield_new},
		{"newRcContourSet", wrap_rcContourSet_new},
		{"newRcPolyMesh", wrap_rcPolyMesh_new},

		{"newDtNavMesh", wrap_dtNavMesh_new},
		{"newDtQueryFilter", wrap_dtQueryFilter_new},
		{"newDtNavMeshQuery", wrap_dtNavMeshQuery_new},
		{"newDtPathCorridor", wrap_dtPathCorridor_new},

		{"newVector3f", vector3f_new},
		{"newPath", path_new},

		{nullptr, nullptr}
	};

	lua_newtable(L);
	luaL_register(L, NULL, constructors);

	return 1;
}
