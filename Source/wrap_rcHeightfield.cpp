#include "wrap_rcHeightfield.h"

/*static*/ int wrap_rcHeightfield_new(lua_State *L) {
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCCONTEXT));

	int width = luaL_checkint(L, 2);
	int height = luaL_checkint(L, 3);

	float *min = *static_cast<float**>(luaL_checkudata(L, 4, LUA_META_VECTOR3F));
	float *max = *static_cast<float**>(luaL_checkudata(L, 5, LUA_META_VECTOR3F));

	float cs = luaL_checknumber(L, 6);
	float ch = luaL_checknumber(L, 7);

	*static_cast<rcHeightfield**>(lua_newuserdata(L, sizeof(rcHeightfield*))) = rcAllocHeightfield();

	if (luaL_newmetatable(L, LUA_META_WRAP_RCHEIGHTFIELD)) {
		static const luaL_Reg methods[] = {
			{"rcRasterizeTriangle", wrap_rcRasterizeTriangle},
			{"printSpans", printSpans},
			{"__gc", wrap_rcHeightfield_free},
			{nullptr, nullptr}
		};
		luaL_register(L, nullptr, methods);
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
	}

	lua_setmetatable(L, -2);

	rcHeightfield *heightfield = *static_cast<rcHeightfield**>(luaL_checkudata(L, 8, LUA_META_WRAP_RCHEIGHTFIELD));

	rcCreateHeightfield(context, *heightfield, width, height, min, max, cs, ch);

	return 1;
}

static int wrap_rcRasterizeTriangle(lua_State *L) {
	rcHeightfield *heightfield = *static_cast<rcHeightfield**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCHEIGHTFIELD));
	rcContext *context = *static_cast<rcContext**>(luaL_checkudata(L, 2, LUA_META_WRAP_RCCONTEXT));

	float *v0 = *static_cast<float**>(luaL_checkudata(L, 3, LUA_META_VECTOR3F));
	float *v1 = *static_cast<float**>(luaL_checkudata(L, 4, LUA_META_VECTOR3F));
	float *v2 = *static_cast<float**>(luaL_checkudata(L, 5, LUA_META_VECTOR3F));

	rcRasterizeTriangle(context, v0, v1, v2, RC_WALKABLE_AREA, *heightfield, 0);

	return 0;
}



static int printSpans(lua_State *L) {
	rcHeightfield *heightfield = *static_cast<rcHeightfield**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCHEIGHTFIELD));

	const float *orig = heightfield->bmin;
	const float cs = heightfield->cs;
	const float ch = heightfield->ch;
	const int w = heightfield->width;
	const int h = heightfield->height;

	for (int y = 0; y < h; ++y)
	{
	    for (int x = 0; x < w; ++x)
	    {
	        // Deriving the minimum corner of the grid location.
	        float fx = orig[0] + x * cs;
	        float fz = orig[2] + y * cs;
	        // The base span in the column. (May be null.)
	        const rcSpan *s = heightfield->spans[x + y * w];
	        while (s)
	        {
	            // Detriving the minium and maximum world position of the span.
	            float fymin = orig[1] + s->smin * ch;
	            float fymax = orig[1] + s->smax * ch;
	            // Do other things with the span before moving up the column.
				printf("span at %d %d :\t%.3f\t%.3f\n", x, y, fymin, fymax);
	            s = s->next;
	        }
	    }
	}
	return 0;
}

static int wrap_rcHeightfield_free(lua_State *L) {
	// printf("wrap_rcHeightfield_free\n");
	rcHeightfield *heightfield = *static_cast<rcHeightfield**>(luaL_checkudata(L, 1, LUA_META_WRAP_RCHEIGHTFIELD));
	rcFreeHeightField(heightfield);
	return 0;
}

extern "C" int luaopen_wrap_rcHeightfield(lua_State *L) {
	lua_pushcfunction(L, wrap_rcHeightfield_new);
	return 1;
}
