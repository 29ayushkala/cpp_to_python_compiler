%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h" // Token definitions from Bison

int keywords = 0, identifiers = 0, numbers = 0, operators = 0, others = 0;
%}

%option noyywrap

DIGIT      [0-9]+
ID         [a-zA-Z_][a-zA-Z0-9_]*
WS         [ \t\n]+
COMMENT    ("//".*|/\*([^*]|\*+[^*/])*\*+/)

%%

{WS}            { /* skip whitespace */ }
{COMMENT}       { /* skip comment */ }

"#".*           { printf("Preprocessor Directive: %s\n", yytext); others++; return PREPROCESSOR; }
\".*\"          { yylval.str = strdup(yytext); printf("String Literal: %s\n", yytext); others++; return STRING; }

"cin"           { printf("Keyword: %s\n", yytext); keywords++; return CIN; }
"cout"          { printf("Keyword: %s\n", yytext); keywords++; return COUT; }

"if"            { printf("Keyword: %s\n", yytext); keywords++; return IF; }
"else"          { printf("Keyword: %s\n", yytext); keywords++; return ELSE; }
"for"           { printf("Keyword: %s\n", yytext); keywords++; return FOR; }
"while"         { printf("Keyword: %s\n", yytext); keywords++; return WHILE; }
"return"        { printf("Keyword: %s\n", yytext); keywords++; return RETURN; }
"void"          { printf("Keyword: %s\n", yytext); keywords++; return VOID; }
"using"         { printf("Keyword: %s\n", yytext); keywords++; return USING; }
"namespace"     { printf("Keyword: %s\n", yytext); keywords++; return NAMESPACE; }
"std"           { printf("Keyword: %s\n", yytext); keywords++; return STD; }
"include"       { printf("Keyword: %s\n", yytext); keywords++; return INCLUDE; }

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

"int"           { yylval.str = strdup(yytext); printf("Keyword: %s\n", yytext); keywords++; return INT; }
"float"         { yylval.str = strdup(yytext); printf("Keyword: %s\n", yytext); keywords++; return FLOAT; }
"char"          { yylval.str = strdup(yytext); printf("Keyword: %s\n", yytext); keywords++; return CHAR; }

{DIGIT}         { yylval.str = strdup(yytext); printf("Number: %s\n", yytext); numbers++; return NUM; }

{ID}            {
                  identifiers++;
                  yylval.str = strdup(yytext);
                  printf("Identifier: %s\n", yytext);
                  return ID;
               }

[{}()\[\];,]    { printf("Symbol: %s\n", yytext); others++; return yytext[0]; }

.               { printf("Unknown token: %s\n", yytext); others++; return UNKNOWN; }

%%

// Optional main() for testing lexer standalone
/*
int main() {
    yylex();
    return 0;
}
*/
