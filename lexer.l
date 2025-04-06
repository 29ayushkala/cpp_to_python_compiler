%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"  // for token definitions from yacc

// Token counters
int keywords = 0, identifiers = 0, numbers = 0, operators = 0, others = 0;

// Keywords list
char *keyword_list[] = {
  "int", "float", "if", "else", "for", "while", "return", "include", "using", "namespace", "std", "cout", "cin", "void", NULL
};

// Check if word is a keyword
int is_keyword(char *str) {
    for (int i = 0; keyword_list[i] != NULL; i++) {
        if (strcmp(str, keyword_list[i]) == 0)
            return 1;
    }
    return 0;
}
%}

%option noyywrap

DIGIT      [0-9]+
ID         [a-zA-Z_][a-zA-Z0-9_]*
OP         [+\-*/=<>!]+
WS         [ \t\n]+
COMMENT    ("//".*|/\*([^*]|\*+[^*/])*\*+/)

%%

// Ignore whitespace and comments
{WS}            { /* skip */ }
{COMMENT}       { /* skip */ }

"#".*           { printf("Preprocessor Directive: %s\n", yytext); others++; return PREPROCESSOR; }
\".*\"          { printf("String Literal: %s\n", yytext); others++; return STRING; }

// C++ specific keywords & streams
"cin"           { printf("Keyword: %s\n", yytext); keywords++; return CIN; }
"cout"          { printf("Keyword: %s\n", yytext); keywords++; return COUT; }
">>"            { printf("CIN Operator: %s\n", yytext); operators++; return CIN_OP; }
"<<"            { printf("COUT Operator: %s\n", yytext); operators++; return COUT_OP; }

// Numbers
{DIGIT}         { printf("Number: %s\n", yytext); numbers++; yylval.ival = atoi(yytext); return NUM; }

// Identifiers & Keywords
{ID}            {
                  if (is_keyword(yytext)) {
                      printf("Keyword: %s\n", yytext); keywords++;
                      return KEYWORD;
                  } else {
                      printf("Identifier: %s\n", yytext); identifiers++;
                      yylval.str = strdup(yytext);
                      return ID;
                  }
               }

// Operators
"=="|"="|"+"|"-"|"*"|"/"|"<"|">" {
                  printf("Operator: %s\n", yytext);
                  operators++;
                  return OPERATOR;
              }

// Symbols
[{}()\[\];,]    { printf("Symbol: %s\n", yytext); others++; return yytext[0]; }

// Unknown token
.               { printf("Unknown token: %s\n", yytext); others++; return UNKNOWN; }

%%

// main() not required if using with parser.y (but for testing, you can uncomment below)
/*
int main() {
    printf("----- Lexical Analysis Started -----\n\n");
    yylex();
    printf("\n----- Summary -----\n");
    printf("Keywords: %d\n", keywords);
    printf("Identifiers: %d\n", identifiers);
    printf("Numbers: %d\n", numbers);
    printf("Operators: %d\n", operators);
    printf("Others: %d\n", others);
    return 0;
}
*/
