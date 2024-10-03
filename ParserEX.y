%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

  int yylex();
  int yyparse();
  void yyerror(const char *string);
  int yywrap();
  typedef struct valori valori_t;
  typedef struct node node_t;
  
  struct valori{
  	char *Identificatore;
        char *Valore;
        struct valori* next;
  };
  
  struct node {
        char *Identificatore;
        size_t n;
        node_t *a;
        node_t *b;
    };
    
  int isprimo = 0;
  struct valori *head;
  struct valori *current;
   
  
  const char *uno = "1";
  const char *zero = "0";
  
  node_t *node(char *Identificatore);
  valori_t *valori(char *Identificatore, char *Valori);
  void aggiungifiglio(node_t *padre, node_t *figlio);
  void print_struct(node_t *nodo, size_t spazio);
  void print_valori(valori_t *inizio);
  void aggiungielemento(char *id, char *val);
  void aggiungivalore(char *id, char *mod);
  void *unionelem(char *id, char *idd);
  void *intersezionelem(char *id, char *idd);
  void *differenzaelem(char *id, char *idd);
  valori_t *trovanodo(char *id, valori_t *primo);
%}

%union{
 struct node *node;
 struct valori *valori;
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
    	unionelem((char *)$1->Identificatore, (char *)$3->Identificatore);
    	node_t *n = node((char *) "Unione");
	aggiungifiglio(n, $1);
        aggiungifiglio(n, $3);
        $$ = n;
    }
    | expr INTERSEZIONE term
    {
    	intersezionelem((char *)$1->Identificatore, (char *)$3->Identificatore);
    	node_t *n = node((char *) "Intersezione");
	aggiungifiglio(n, $1);
        aggiungifiglio(n, $3);
        $$ = n;
    }
    | expr DIFFERENZA term
    { 
    	differenzaelem((char *)$1->Identificatore, (char *)$3->Identificatore);
    	node_t *n = node((char *) "Differenza");
	aggiungifiglio(n, $1);
        aggiungifiglio(n, $3);
        $$ = n;
    }
    | term
    	{ $$ = $1; }
    ;
    	
term: SPARENTESI expr DPARENTESI 
	{ $$ = $2; }
    | term UGUALE VALORE 
	{
	valori_t *v = valori($1->Identificatore,(char *) $3);
	}
    | ADD VALOREI IDS
    {
   	aggiungielemento((char *)$3,(char *) $2);
   	node_t *n = node((char *) "Aggiungi");
   	n->a = node((char*)$2);
   	n->b = node((char*)$3);
        $$ = n;
    }
    | ID
    	{ node_t *n = node((char *)$1);
    	$$ = n;
    	}
    | PRINT
    {
     print_valori(head);
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

valori_t *valori(char *Identificatore, char *Valori) {
	valori_t *v = malloc(sizeof(valori_t));
	v->Identificatore = strdup(Identificatore);
	v->Valore = strdup(Valori+1);
	v->next = NULL;
	if(isprimo == 0){
		head = v;
		current=v;
		isprimo = 1;
	} else{
		current->next = v;
	}
	return current;
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

void print_valori(valori_t *inizio){
	if(inizio->next)
		print_valori(inizio->next);
	else
		printf("%s", inizio->Valore);
}

void aggiungielemento(char *id, char *val){
	valori_t * nodo = trovanodo(id, head);
	char *c = nodo->Valore;
	c[atoi(val)]=49;	
}

valori_t *trovanodo(char *id, valori_t *attuale){
	valori_t *risultato;
	if(strcmp(attuale->Identificatore, id) == 0){
		risultato = attuale;
	} else if (attuale->next != NULL)
       		risultato = trovanodo(id, attuale->next);
        
	
	return risultato;
}

void *unionelem(char *id, char *idd){
	char *primo = trovanodo(id, head)->Valore;
	char *secondo = trovanodo(idd, head)->Valore;
	
	for(int i = 0; i<32; i++){
		if(strcmp(&primo[i], uno) == 0 && strcmp(&secondo[i], zero) == 0){
			primo[i] = 49;
		} else {
			primo[i] = 48;
		}
	}
	
	return primo;
}

void *intersezionelem(char *id, char *idd){
	char *primo = trovanodo(id, head)->Valore;
	char *secondo = trovanodo(idd, head)->Valore;
	
	for(int i = 0; i<32; i++){
		if(strcmp(&primo[i], uno) == 0 || strcmp(&secondo[i], uno) == 0){
			primo[i] = 49;
		} else {
			primo[i] = 48;
		}
	}
	
	return primo;
}

void *differenzaelem(char *id, char *idd){
	char *primo = trovanodo(id, head)->Valore;
	char *secondo = trovanodo(idd, head)->Valore;
	
	for(int i = 0; i<32; i++){
		if(strcmp(&primo[i], uno) == 0 && strcmp(&secondo[i], uno) == 0 || strcmp(&primo[i], zero) == 0 && strcmp(&secondo[i], zero) == 0){
			primo[i] = 49;
		} else {
			primo[i] = 48;
		}
	}
		
	return primo;
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

