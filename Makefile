parser : lex.yy.c limbaj.tab.c SymTable.cpp
	g++ lex.yy.c limbaj.tab.c SymTable.cpp ASTNode.cpp -o parser -Wall 

lex.yy.c : limbaj.l
	flex limbaj.l

limbaj.tab.c : limbaj.y
	bison -d limbaj.y
	