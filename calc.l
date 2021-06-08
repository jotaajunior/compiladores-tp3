%{ 
/* analisador léxico para uma calculadora */
/* com suporte a definição de variáveis */
#include <iostream>
#include <string>
#include "parser.h"

using namespace std;
%}

%option yylineno
%option noyywrap

%x TEXT

digito	       [0-9]
letra_	       [a-zA-Z_]
pontdig        {digito}*"."?{digito}+
digpont        {digito}+"."
numero         {pontdig}|{digpont}
id		         {letra_}({letra_}|{digito})*

%%

"print"                { return PRINT; }
"if"                   { return IF; }
"sqrt"                 { return SQRT; }
"pow"                  { return POW; }

\"                     { BEGIN TEXT; }
<TEXT>(\\.|[^\"])*     { strcpy(yylval.text, yytext);  }
<TEXT>\"               { BEGIN INITIAL; return STRING; }

[\t ]+		             { ; /* ignora espaço em branco */ }
{numero}               { yylval.num = atof(yytext); return NUM; }
{id}		               { strcpy(yylval.id, yytext); return ID; }
.|\n		               { return yytext[0]; }

%%