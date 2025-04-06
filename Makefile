all: compiler

compiler: lex.yy.c y.tab.c
	gcc y.tab.c lex.yy.c -o compiler -lfl

lex.yy.c: lexer.l
	flex lexer.l

y.tab.c: parser.y
	bison -d parser.y

clean:
	rm -f lex.yy.c y.tab.* compiler
