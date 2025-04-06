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

FILE *pyout; // Python output file

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

        fprintf(pyout, "%s = None\n", name);  // Write to Python file
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
            fprintf(pyout, "%s = %s\n", name, value); // Write assignment to Python
            printf("✔ Assignment OK: %s = %s\n", name, value);
        }
    }
}
%}

%union {
    char *str;
}

%token <str> INT FLOAT CHAR ID NUM ASSIGN SEMI
%token <str> CIN COUT CIN_OP COUT_OP STRING
%type <str> type

%%

program:
    program stmt
    | stmt
    ;

stmt:
    declaration SEMI
    | assignment SEMI
    | cin_stmt SEMI
    | cout_stmt SEMI
    ;

declaration:
    type ID {
        strcpy(currentID, $2);
        addSymbol(currentID, $1);
    }
    ;

assignment:
    ID ASSIGN NUM {
        checkAssignment($1, "int", $3);
    }
    ;

cin_stmt:
    CIN CIN_OP ID {
        if (!isDeclared($3)) {
            printf("❌ Error: Variable '%s' not declared\n", $3);
        } else {
            char *type = getType($3);
            if (strcmp(type, "int") == 0) {
                fprintf(pyout, "%s = int(input())\n", $3);
            } else if (strcmp(type, "float") == 0) {
                fprintf(pyout, "%s = float(input())\n", $3);
            } else {
                fprintf(pyout, "%s = input()\n", $3);
            }
            printf("✔ Input accepted for: %s\n", $3);
        }
    }
    ;

cout_stmt:
    COUT COUT_OP ID {
        if (!isDeclared($3)) {
            printf("❌ Error: Variable '%s' not declared\n", $3);
        } else {
            fprintf(pyout, "print(%s)\n", $3);
            printf("✔ Output: %s\n", $3);
        }
    }
    | COUT COUT_OP STRING {
        fprintf(pyout, "print(%s)\n", $3);
        printf("✔ Output: %s\n", $3);
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
