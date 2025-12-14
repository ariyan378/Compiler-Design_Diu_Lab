%{
#include "compiler.tab.h"
#include <string.h>
%}

%%
mytype              { return MYTYPE; }
strtype             { return STRTYPE; }
show                { return SHOW; }
concat              { return CONCAT; }
length              { return LENGTH; }
upper               { return UPPER; }
lower               { return LOWER; }
power               { return POWER; }
sqrt                { return SQRT; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+              { yylval.num = atoi(yytext); return NUMBER; }
\"([^\"\\]|\\.)*\"  { 
    yylval.str = strdup(yytext); 
    return STRING_LITERAL; 
}

"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return TIMES; }
"/"                 { return DIVIDE; }
"="                 { return '='; }
";"                 { return ';'; }
","                 { return ','; }
"("                 { return '('; }
")"                 { return ')'; }
[ \t\n]+            { /* Ignore whitespace */ }
.                   { return yytext[0]; }
%%

int yywrap(void) {
    return 1;
}

