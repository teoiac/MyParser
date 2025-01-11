parser : lex.yy.c limbaj.tab.c SymTable.cpp
	g++ lex.yy.c limbaj.tab.c SymTable.cpp -o parser -Wall -std=c++17

lex.yy.c : limbaj.l
	flex limbaj.l

limbaj.tab.c : limbaj.y
	bison -d limbaj.y
	
