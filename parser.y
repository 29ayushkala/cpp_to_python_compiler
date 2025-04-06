%{
#include <stdio.h>
#include <stdlib.h>

// Forward declaration
int yylex();
void yyerror(const char *s);
%}

%token INT FLOAT CHAR ID NUM ASSIGN SEMI

%%

// Grammar rules
program:
    program stmt
    | stmt
    ;

stmt:
    declaration SEMI       { printf("✔ Declaration valid\n"); }
    | assignment SEMI      { printf("✔ Assignment valid\n"); }
    ;

declaration:
    type ID                { printf("Detected declaration: %s\n", yytext); }
    ;

assignment:
    ID ASSIGN NUM          { printf("Detected assignment\n"); }
    ;

type:
    INT
    | FLOAT
    | CHAR
    ;

%%

// Error handler
void yyerror(const char *s) {
    fprintf(stderr, "❌ Syntax Error: %s\n", s);
}
