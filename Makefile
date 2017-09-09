SRC_RECAST = ../recastnavigation/Recast/Source/*.cpp ../recastnavigation/Detour/Source/*.cpp

INC_RECAST = -I../recastnavigation/Recast/Include -I../recastnavigation/Detour/Include
INC_LUA = -I/usr/local/Cellar/lua/5.2.4_4/include -L/usr/local/Cellar/lua/5.2.4_4/lib -llua

all:
	g++ -o test ./main.cpp $(INC_RECAST) $(SRC_RECAST) $(INC_LUA)
lua:
	cc -bundle -undefined dynamic_lookup -o module.so module.cpp  $(INC_RECAST) $(SRC_RECAST)
