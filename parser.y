%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

// Symbol Table
typedef struct {
    char name[100];
    char type[10];
} Symbol;

Symbol symbolTable[100];
int symbolCount = 0;

// Helper Functions
int isDeclared(char *name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0)
            return 1;
    }
    return 0;
}

char* getType(char *name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0)
            return symbolTable[i].type;
    }
    return NULL;
}

void addSymbol(char *name, char *type) {
    if (isDeclared(name)) {
        printf("❌ Error: Variable '%s' already declared\n", name);
    } else {
        strcpy(symbolTable[symbolCount].name, name);
        strcpy(symbolTable[symbolCount].type, type);
        symbolCount++;
        printf("✔ Declared: %s (%s)\n", name, type);
    }
}

void checkAssignment(char *name, char *expectedType) {
    if (!isDeclared(name)) {
        printf("❌ Error: Variable '%s' not declared\n", name);
    } else {
        char *actualType = getType(name);
        if (strcmp(actualType, expectedType) != 0) {
            printf("❌ Error: Type mismatch in assignment to '%s'\n", name);
        } else {
            printf("✔ Assignment OK: %s = value\n", name);
        }
    }
}

char currentType[10];  // Temporarily store type during declaration
char currentID[100];   // Temporarily store ID
%}

%union {
    char *str;
}

%token <str> INT FLOAT CHAR ID NUM
%token ASSIGN SEMI
%type <str> type

%%

program:
    program stmt
    | stmt
    ;

stmt:
    declaration SEMI
    | assignment SEMI
    ;

declaration:
    type ID   {
                strcpy(currentID, $2);
                addSymbol(currentID, $1);
             }
    ;

assignment:
    ID ASSIGN NUM {
                    checkAssignment($1, "int");  // default assumes NUM is int
                 }
    ;

type:
    INT   { $$ = "int"; }
    | FLOAT { $$ = "float"; }
    | CHAR  { $$ = "char"; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "❌ Syntax Error: %s\n", s);
}

