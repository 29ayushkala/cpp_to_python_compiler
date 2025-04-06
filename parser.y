%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

int keywords = 0, identifiers = 0, numbers = 0, operators = 0, others = 0;

char *keyword_list[] = {
  "int", "float", "char", "if", "else", "for", "while", "return", "include", "using", "namespace", "std", "cout", "cin", "void", NULL
};

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
WS         [ \t\n]+
COMMENT    ("//".*|/\*([^*]|\*+[^*/])*\*+/)

%%

{WS}            { /* skip */ }
{COMMENT}       { /* skip */ }

"#".*           { printf("Preprocessor Directive: %s\n", yytext); others++; return PREPROCESSOR; }
\".*\"          { yylval.str = strdup(yytext); printf("String Literal: %s\n", yytext); others++; return STRING; }

"cin"           { printf("Keyword: %s\n", yytext); keywords++; return CIN; }
"cout"          { printf("Keyword: %s\n", yytext); keywords++; return COUT; }
">>"            { printf("Operator: %s\n", yytext); operators++; return CIN_OP; }
"<<"            { printf("Operator: %s\n", yytext); operators++; return COUT_OP; }

"=="            { printf("Operator: %s\n", yytext); operators++; return EQ; }
"!="            { printf("Operator: %s\n", yytext); operators++; return NEQ; }
"="             { printf("Operator: %s\n", yytext); operators++; return ASSIGN; }
"+"             { printf("Operator: %s\n", yytext); operators++; return PLUS; }
"-"             { printf("Operator: %s\n", yytext); operators++; return MINUS; }
"*"             { printf("Operator: %s\n", yytext); operators++; return MULT; }
"/"             { printf("Operator: %s\n", yytext); operators++; return DIV; }
"<"             { printf("Operator: %s\n", yytext); operators++; return LT; }
">"             { printf("Operator: %s\n", yytext); operators++; return GT; }

"int"           { yylval.str = strdup(yytext); return INT; }
"float"         { yylval.str = strdup(yytext); return FLOAT; }
"char"          { yylval.str = strdup(yytext); return CHAR; }

{DIGIT}         { yylval.str = strdup(yytext); numbers++; return NUM; }

{ID}            {
                  if (is_keyword(yytext)) {
                      keywords++;
                      yylval.str = strdup(yytext);
                      return KEYWORD;
                  } else {
                      identifiers++;
                      yylval.str = strdup(yytext);
                      return ID;
                  }
               }

[{}()\[\];,]    { printf("Symbol: %s\n", yytext); others++; return yytext[0]; }

.               { printf("Unknown token: %s\n", yytext); others++; return UNKNOWN; }

%%
