%{
/* analisador sintático para uma calculadora */
/* com suporte a definição de variáveis */
#include <iostream>
#include <string>
#include <cstring>
#include <sstream>
#include <cmath>
#include <unordered_map>
#include <stdio.h>

using namespace std;

/* protótipos das funções especiais */
int yylex(void);
int yyparse(void);
void yyerror(const char *);

/* tabela de símbolos */
unordered_map<string, double> variables;
%}

%union {
	double num;
	char id[16];
	char text[100];
}

%token <id> ID
%token <num> NUM
%token <text> STRING
%token <num> PRINT
%token IF
%token SQRT
%token POW

%type <num> expr
%type <text> args
%type <text> sid

%left '+' '-'
%left  '<' "<=" '>' ">="
%left '*' '/'
%nonassoc UMINUS

%%

math: math calc
	| calc
	;

calc: ID '=' expr 			    { variables[$1] = $3; }
	 | expr					          { cout << "= " << $1 << "\n"; }
   | PRINT '(' args ')'     { cout << $3 << "\n"; }
	 | ifPrint
	 | ifAttr
	 | '\n'
   ;

ifPrint: IF '(' expr ')' PRINT '(' args ')'
	{
		if ($3) {
			cout << $7 << '\n';
		}
	};

ifAttr: IF '(' expr ')' ID '=' expr
	{
		if ($3) {
			variables[$5] = $7;
		}
	};

args: sid ',' args {
		 stringstream ss;
		 ss << $1 << $3;
		 strcpy($$, ss.str().c_str());
	 }
	 | sid { strcpy($$, $1); };

sid: STRING { strcpy($$, $1); }
	 | expr {
		 stringstream ss;
		 ss << $1;
		 strcpy($$, ss.str().c_str());
	 };

expr: expr '+' expr		  { $$ = ($1 + $3); }
	| expr '-' expr   		{ $$ = ($1 - $3); }
	| expr '*' expr			  { $$ = ($1 * $3); }
	| expr '/' expr
	{ 
		if ($3 == 0)
			yyerror("divisão por zero");
		else
			$$ = $1 / $3; 
	}
	| '(' expr ')'			         { $$ = $2; }
	| '-' expr %prec UMINUS      { $$ = - $2; }
	| expr '<' expr              { $$ = ($1 < $3); }
	| expr '>' expr              { $$ = ($1 > $3); }
	| expr '<''=' expr           { $$ = ($1 >= $4); }
	| expr '>''=' expr           { $$ = ($1 >= $4); }
	| expr '!''=' expr           { $$ = ($1 != $4); }
	| expr '=''=' expr           { $$ = ($1 == $4); }
	| POW '(' expr ',' expr ')'  { $$ = pow($3, $5); }
	| SQRT '(' expr ')'          { $$ = sqrt($3); }
	| ID					               { $$ = variables[$1]; }
	| NUM
	;


%%

int main()
{
	yyparse();
}

void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */
	extern int yylineno;
	extern char * yytext;

	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
  cout << "Erro (" << s << "): símbolo \"" << yytext << "\" (linha " << yylineno << ")\n";
}
