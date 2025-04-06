%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
int yylineno;

char* str_concat(const char* a, const char* b) {
    char *result = malloc(strlen(a) + strlen(b) + 2);
    strcpy(result, a);
    strcat(result, " ");
    strcat(result, b);
    return result;
}
%}

%union {
    char* str;
}

%token <str> ID NUM STRING
%token INT FLOAT CHAR IF ELSE FOR WHILE RETURN VOID USING NAMESPACE STD INCLUDE
%token CIN COUT
%token EQ NEQ ASSIGN PLUS MINUS MULT DIV LT GT
%token CIN_OP COUT_OP
%token PREPROCESSOR

%type <str> expression expression_list statement statements

%start program

%%

program:
    statements
;

statements:
    statements statement
    | statement
;

statement:
    declaration
    | assignment
    | input_stmt
    | output_stmt
    | if_stmt
    | while_stmt
    | for_stmt
    | RETURN expression ';'       { printf("return %s\n", $2); }
    | ';'                         { /* skip empty */ }
;

declaration:
    INT ID ';'                    { printf("%s = 0\n", $2); }
    | FLOAT ID ';'                { printf("%s = 0.0\n", $2); }
    | CHAR ID ';'                 { printf("%s = ''\n", $2); }
;

assignment:
    ID ASSIGN expression ';'      { printf("%s = %s\n", $1, $3); }
;

expression:
    ID                            { $$ = $1; }
    | NUM                         { $$ = $1; }
    | STRING                      { $$ = $1; }
    | expression PLUS expression  {
                                    char* temp = str_concat($1, "+");
                                    $$ = str_concat(temp, $3);
                                  }
    | expression MINUS expression {
                                    char* temp = str_concat($1, "-");
                                    $$ = str_concat(temp, $3);
                                  }
    | expression MULT expression  {
                                    char* temp = str_concat($1, "*");
                                    $$ = str_concat(temp, $3);
                                  }
    | expression DIV expression   {
                                    char* temp = str_concat($1, "/");
                                    $$ = str_concat(temp, $3);
                                  }
;

input_stmt:
    CIN CIN_OP ID ';'            { printf("%s = input()\n", $3); }
;

output_stmt:
    COUT COUT_OP expression_list ';' {
        printf("print(%s)\n", $3);
    }
;

expression_list:
    expression                    { $$ = $1; }
    | expression_list COUT_OP expression {
        char* temp = str_concat($1, ",");
        $$ = str_concat(temp, $3);
    }
;

if_stmt:
    IF '(' expression ')' '{' statements '}' {
        printf("if %s:\n", $3);
    }
;

while_stmt:
    WHILE '(' expression ')' '{' statements '}' {
        printf("while %s:\n", $3);
    }
;

for_stmt:
    FOR '(' assignment expression ';' assignment ')' '{' statements '}' {
        // Very simplified for loop handling
        printf("# for loop not fully supported yet\n");
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}
