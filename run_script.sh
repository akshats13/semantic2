yacc -d testing.y
lex testing.l
g++ lex.yy.c y.tab.c -o TEST
./TEST
