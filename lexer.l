%{
#include <stdio.h>
#include <string.h>

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

DIGIT      [0-9]
ID         [a-zA-Z_][a-zA-Z0-9_]*
OP         [+\-*/=<>!]+
WS         [ \t\n]+
COMMENT    ("//".*|/\*([^*]|\*+[^*/])*\*+/)

%%
{COMMENT}       {/* Ignore comments */}
{WS}            {/* Ignore whitespace */}
"#".*           { printf("Preprocessor Directive: %s\n", yytext); others++; }
\".*\"          { printf("String Literal: %s\n", yytext); others++; }

{DIGIT}+        { printf("Number: %s\n", yytext); numbers++; }
{ID}            {
                  if (is_keyword(yytext)) {
                      printf("Keyword: %s\n", yytext); keywords++;
                  } else {
                      printf("Identifier: %s\n", yytext); identifiers++;
                  }
               }
{OP}            { printf("Operator: %s\n", yytext); operators++; }
[{}()\[\];,]    { printf("Symbol: %s\n", yytext); others++; }
.               { printf("Unknown token: %s\n", yytext); others++; }
 
%%

int main(int argc, char **argv) {
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
