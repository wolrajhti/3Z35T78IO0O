SRC_RECAST =	../recastnavigation/Recast/Source/*.cpp \
				../recastnavigation/Detour/Source/*.cpp \
				../recastnavigation/DetourCrowd/Source/*.cpp

INC_RECAST =	-I../recastnavigation/Recast/Include \
				-I../recastnavigation/Detour/Include \
				-I../recastnavigation/DetourCrowd/Include

all:
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/rl.so ./Source/wrap_*.cpp ./Source/rl.cpp ./Source/vector3f.cpp ./Source/path.cpp -I./Include $(INC_RECAST) $(SRC_RECAST)
	cc -bundle -undefined dynamic_lookup -o ./SharedLibrary/recastlua.so ./Source/recastlua.cpp -I./Include $(INC_RECAST) $(SRC_RECAST)
