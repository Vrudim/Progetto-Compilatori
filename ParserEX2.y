%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

  int yylex();
  int yyparse();
  void yyerror(const char *string);
  int yywrap();
  
  typedef struct node node_t;
  
  struct node {
        char *Identificatore;
        size_t n;
        node_t *a;
        node_t *b;
    };
  
  node_t *node(char *Identificatore);
  void aggiungifiglio(node_t *padre, node_t *figlio);
  void print_struct(node_t *nodo, size_t spazio);
%}

%union{
 struct node *node;
 char *string;
}

%token UGUALE ADD UNIONE INTERSEZIONE DIFFERENZA SPARENTESI DPARENTESI PRINT EOL
%token <string> ID
%token <string> VALORE
%token <string> IDS
%token <string> VALOREI
%type <node> expr term

%%

lines: /*vuoto*/
	|lines expr EOL
	{
	print_struct($2, 0);
	}
	;

expr: expr UNIONE term
    {
    	node_t *n = node((char *) "Unione");
	aggiungifiglio(n, $1);
        aggiungifiglio(n, $3);
        $$ = n;
    }
    | expr INTERSEZIONE term
    {
    	node_t *n = node((char *) "Intersezione");
	aggiungifiglio(n, $1);
        aggiungifiglio(n, $3);
        $$ = n;
    }
    | expr DIFFERENZA term
    { 
    	node_t *n = node((char *) "Differenza");
	aggiungifiglio(n, $1);
        aggiungifiglio(n, $3);
        $$ = n;
    }
    | ADD term term
    {
   	node_t *n = node((char *) "Aggiungi");
   	aggiungifiglio(n, $2);
        aggiungifiglio(n, $3);
        $$ = n;
    }
    | term
    	{ $$ = $1; }
    ;
    	
term: SPARENTESI expr DPARENTESI
    { 
    $$ = $2; 
    }
    | VALOREI
    { node_t *n = node((char *)$1);
    $$ = n;
    }
    | IDS
    { node_t *n = node((char *)$1);
    $$ = n;
    }
    | ID
    { node_t *n = node((char *)$1);
    $$ = n;
    }
    ;

%%

node_t *node(char *Identificatore) {
	node_t *n = malloc(sizeof(node_t));
	n->Identificatore = strdup(Identificatore);
	n->n = 0;
	n->a = NULL;
	n->b = NULL;
	return n;
}

void aggiungifiglio(node_t *padre, node_t *figlio){
	if (padre->n == 0) {
        	padre->a = figlio;
        	padre->n = padre->n + 1;
    	} else if (padre->n == 1) {
        	padre->b = figlio;
        	padre->n = padre->n + 1;
    	} else {
       		yyerror("Can't add a child: node already full of children.\n");
   	}
}

void print_struct(node_t *nodo, size_t spazio){
	char *spazi = malloc(sizeof(char) * spazio);
	for (size_t i = 0; i < spazio; ++i) {
        	spazi[i] = ' ';
   	}
   	printf("%s%s\n", spazi, nodo->Identificatore);
   	
   	if (nodo->a)
       		print_struct(nodo->a, spazio+2);
    	if (nodo->b)
        	print_struct(nodo->b, spazio+2);
}

int yywrap() {
    return -1;
}

void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
     yyparse();
}

