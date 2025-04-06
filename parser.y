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

char currentType[10];
char currentID[100];

FILE *pyout;

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
        fprintf(pyout, "%s = None\n", name);
        printf("✔ Declared: %s (%s)\n", name, type);
    }
}

void checkAssignment(char *name, char *expectedType, char *value) {
    if (!isDeclared(name)) {
        printf("❌ Error: Variable '%s' not declared\n", name);
    } else {
        char *actualType = getType(name);
        if (strcmp(actualType, expectedType) != 0) {
            printf("❌ Error: Type mismatch in assignment to '%s'\n", name);
        } else {
            fprintf(pyout, "%s = %s\n", name, value);
            printf("✔ Assignment OK: %s = %s\n", name, value);
        }
    }
}
%}

%union {
    char *str;
}

%token <str> INT FLOAT CHAR ID NUM STRING
%token IF ELSE WHILE FOR CIN COUT COUT_OP CIN_OP
%token ASSIGN PLUS MINUS MULT DIV SEMI LT GT EQ NEQ
%type <str> type expr

%%

program:
    program stmt
    | stmt
    ;

stmt:
    declaration SEMI
    | assignment SEMI
    | output SEMI
    | input SEMI
    | if_stmt
    | while_stmt
    | for_stmt
    ;

declaration:
    type ID {
        strcpy(currentID, $2);
        addSymbol(currentID, $1);
    }
    ;

assignment:
    ID ASSIGN expr {
        checkAssignment($1, getType($1), $3);
    }
    ;

expr:
    ID       { $$ = $1; }
    | NUM    { $$ = $1; }
    | expr PLUS expr {
        char *res = malloc(100);
        sprintf(res, "%s + %s", $1, $3); $$ = res;
    }
    | expr MINUS expr {
        char *res = malloc(100);
        sprintf(res, "%s - %s", $1, $3); $$ = res;
    }
    | expr MULT expr {
        char *res = malloc(100);
        sprintf(res, "%s * %s", $1, $3); $$ = res;
    }
    | expr DIV expr {
        char *res = malloc(100);
        sprintf(res, "%s / %s", $1, $3); $$ = res;
    }
    ;

output:
    COUT output_chain {
        fprintf(pyout, "print(%s)\n", $2);
    }
    ;

output_chain:
    STRING           { $$ = $1; }
    | ID             { $$ = $1; }
    | output_chain COUT_OP STRING {
        char *res = malloc(200);
        sprintf(res, "%s + %s", $1, $3); $$ = res;
    }
    | output_chain COUT_OP ID {
        char *res = malloc(200);
        sprintf(res, "%s + str(%s)", $1, $3); $$ = res;
    }
    ;

input:
    CIN input_chain
    ;

input_chain:
    CIN_OP ID {
        if (!isDeclared($2)) {
            printf("❌ Error: '%s' not declared\n", $2);
        } else {
            fprintf(pyout, "%s = input()\n", $2);
        }
    }
    | input_chain CIN_OP ID {
        if (!isDeclared($3)) {
            printf("❌ Error: '%s' not declared\n", $3);
        } else {
            fprintf(pyout, "%s = input()\n", $3);
        }
    }
    ;

if_stmt:
    IF '(' ID relop NUM ')' '{' program '}'
    {
        fprintf(pyout, "if %s %s %s:\n", $3, $4, $5);
    }
    ;

while_stmt:
    WHILE '(' ID relop NUM ')' '{' program '}'
    {
        fprintf(pyout, "while %s %s %s:\n", $3, $4, $5);
    }
    ;

for_stmt:
    FOR '(' assignment SEMI ID relop NUM SEMI assignment ')' '{' program '}'
    {
        fprintf(pyout, "for i in range(%s, %s):\n", $3, $7);
    }
    ;

relop:
    LT   { $$ = "<"; }
    | GT   { $$ = ">"; }
    | EQ   { $$ = "=="; }
    | NEQ  { $$ = "!="; }
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

int main() {
    pyout = fopen("output.py", "w");
    if (!pyout) {
        perror("Failed to open output file");
        return 1;
    }

    yyparse();
    fclose(pyout);
    printf("\n🟢 Running Generated Python Code:\n");
    system("python3 output.py");
    return 0;
}
