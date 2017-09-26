#include "test.h"

extern "C" int luaopen_test(lua_State *L) {
	luaL_Reg constructors[] = {
		{"rcContext", wrap_rcContext_new},
		{"rcHeightfield", wrap_rcHeightfield_new},
		{"rcCompactHeightfield", wrap_rcCompactHeightfield_new},
		{"rcContourSet", wrap_rcContourSet_new},
		{"rcPolyMesh", wrap_rcPolyMesh_new},
		{"dtNavMesh", wrap_dtNavMesh_new},
		{"vector3f", vector3f_new},
		{nullptr, nullptr}
	};

	lua_newtable(L);
	luaL_register(L, NULL, constructors);

	return 1;
}
