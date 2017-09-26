SRC_RECAST =	../recastnavigation/Recast/Source/*.cpp \
				../recastnavigation/Detour/Source/*.cpp

INC_RECAST =	-I../recastnavigation/Recast/Include \
				-I../recastnavigation/Detour/Include

all:
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/recastlua.so ./Source/recastlua.cpp -I./Include $(INC_RECAST) $(SRC_RECAST)
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/hero.so ./Source/hero.cpp -I./Include
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/superHero.so ./Source/superHero.cpp -I./Include
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/vector3f.so ./Source/vector3f.cpp -I./Include
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/wrap_rcContext.so \
											./Source/wrap_rcContext.cpp -I./Include $(INC_RECAST) $(SRC_RECAST)
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/wrap_rcPolyMesh.so \
											./Source/wrap_rcPolyMesh.cpp -I./Include $(INC_RECAST) $(SRC_RECAST)
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/wrap_rcHeightfield.so \
											./Source/wrap_rcHeightfield.cpp -I./Include $(INC_RECAST) $(SRC_RECAST) \
												./Source/wrap_rcContext.cpp \
												./Source/vector3f.cpp
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/wrap_rcCompactHeightfield.so \
											./Source/wrap_rcCompactHeightfield.cpp -I./Include $(INC_RECAST) $(SRC_RECAST) \
												./Source/wrap_rcContext.cpp \
												./Source/wrap_rcHeightfield.cpp

lua:
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/test.so ./Source/wrap_*.cpp ./Source/test.cpp ./Source/vector3f.cpp -I./Include $(INC_RECAST) $(SRC_RECAST)
