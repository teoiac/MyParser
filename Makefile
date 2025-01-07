parser : lex.yy.c limbaj.tab.c symtable.cpp
	g++ lex.yy.c limbaj.tab.c symtable.cpp -o parser -Wall

lex.yy.c : limbaj.l
	flex limbaj.l

limbaj.tab.c : limbaj.y
	bison -d limbaj.y
	