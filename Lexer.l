%{
	#include <stdio.h>
	#include <string.h>
	#include "y.tab.h"
	
%}
%%
exit 			{ exit(0); }
print			{ return PRINT; }
aggiungi		{ return ADD; }
[A-Z]{2,} 		{ printf("Identificatore non ok. \n"); }
[A-Z]{1} 		{ char *c = yytext; yylval.string = c; return ID; }
s[0|1]{1,31}		{ printf("Non e un valore di 32 bit\n"); }
s[0|1]{33,}		{ printf("Valore di piu grande di 32 bit\n"); }
s[0|1]{32}		{ yylval.string = strndup(yytext, yyleng); return VALORE; }
=			{ return UGUALE; }
i([0-9]|3[0-2]|[1|2][0-9])	{ ; yylval.string = yytext; return VALOREI; }
s[A-Z]{2}		{ char *c = yytext; yylval.string = c[1] + "A"; return IDS; }
u			{ return UNIONE; }
n			{ return INTERSEZIONE; }
-			{ return DIFFERENZA; }
\(			{ return SPARENTESI; }
\)			{ return DPARENTESI; }
\n			{ return EOL; }	
[ \t]+
.	
