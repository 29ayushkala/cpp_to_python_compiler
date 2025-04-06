%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"  // for token definitions from yacc

// Token counters
int keywords = 0, identifiers = 0, numbers = 0, operators = 0, others = 0;
%}

%option noyywrap

DIGIT      [0-9]+
ID         [a-zA-Z_][a-zA-Z0-9_]*
WS         [ \t\n]+
COMMENT    ("//".*|/\*([^*]|\*+[^*/])*\*+/)

%%

// Ignore whitespace and comments
{WS}            { /* skip */ }
{COMMENT}       { /* skip */ }

// Preprocessor and strings
"#".*           { printf("Preprocessor Directive: %s\n", yytext); others++; return PREPROCESSOR; }
\".*\"          { printf("String Literal: %s\n", yytext); others++; return STRING; }

// C++ specific keywords & streams
"int"           { printf("Keyword: %s\n", yytext); keywords++; return INT; }
"float"         { printf("Keyword: %s\n", yytext); keywords++; return FLOAT; }
"char"          { printf("Keyword: %s\n", yytext); keywords++; return CHAR; }
"if"            { printf("Keyword: %s\n", yytext); keywords++; return IF; }
"else"          { printf("Keyword: %s\n", yytext); keywords++; return ELSE; }
"while"         { printf("Keyword: %s\n", yytext); keywords++; return WHILE; }
"for"           { printf("Keyword: %s\n", yytext); keywords++; return FOR; }
"return"        { printf("Keyword: %s\n", yytext); keywords++; return RETURN; }
"include"       { printf("Keyword: %s\n", yytext); keywords++; return INCLUDE; }
"using"         { printf("Keyword: %s\n", yytext); keywords++; return USING; }
"namespace"     { printf("Keyword: %s\n", yytext); keywords++; return NAMESPACE; }
"std"           { printf("Keyword: %s\n", yytext); keywords++; return STD; }
"cin"           { printf("Keyword: %s\n", yytext); keywords++; return CIN; }
"cout"          { printf("Keyword: %s\n", yytext); keywords++; return COUT; }
"void"          { printf("Keyword: %s\n", yytext); keywords++; return VOID; }

// C++ I/O operators
"<<"            { printf("COUT Operator: %s\n", yytext); operators++; return COUT_OP; }
">>"            { printf("CIN Operator: %s\n", yytext); operators++; return CIN_OP; }

// Numbers
{DIGIT}         { printf("Number: %s\n", yytext); numbers++; yylval.str = strdup(yytext); return NUM; }

// Identifiers
{ID}            { printf("Identifier: %s\n", yytext); identifiers++; yylval.str = strdup(yytext); return ID; }

// Operators (match longer first)
"=="            { printf("Operator: %s\n", yytext); operators++; return EQ; }
"!="            { printf("Operator: %s\n", yytext); operators++; return NEQ; }
"<="            { printf("Operator: %s\n", yytext); operators++; return LE; }
">="            { printf("Operator: %s\n", yytext); operators++; return GE; }
"<"             { printf("Operator: %s\n", yytext); operators++; return LT; }
">"             { printf("Operator: %s\n", yytext); operators++; return GT; }
"="             { printf("Operator: %s\n", yytext); operators++; return ASSIGN; }
"+"             { printf("Operator: %s\n", yytext); operators++; return PLUS; }
"-"             { printf("Operator: %s\n", yytext); operators++; return MINUS; }
"*"             { printf("Operator: %s\n", yytext); operators++; return MULT; }
"/"             { printf("Operator: %s\n", yytext); operators++; return DIV; }

// Symbols
[{}()\[\];,]    { printf("Symbol: %s\n", yytext); others++; return yytext[0]; }

// Unknown
.               { printf("Unknown token: %s\n", yytext); others++; return UNKNOWN; }

%%

// Optional test main
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
