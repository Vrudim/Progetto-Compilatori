%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

  int yylex();
  int yyparse();
  void yyerror(const char *string);
  int yywrap();
  
  char *valori [50][32];
  char *idpos[50][50];
  int pos = 0;
  
  void print_valori();
  void aggiungielemento(char *posizione, char *val);
  void aggiungivalore(int posizione, char *mod, char *id);
  int trovanodo(char *id);
  
  void unionelem(int primo, int secondo);
  void intersezionelem(int primo, int secondo);
  void differenzaelem(int primo, int secondo);
  
%}

%union{
 char *string;
 int nr;
}

%token UGUALE ADD UNIONE INTERSEZIONE DIFFERENZA SPARENTESI DPARENTESI PRINT EOL
%token <string> ID
%token <string> VALORE
%token <string> IDS
%token <string> VALOREI
%type <nr> expr term
%%

lines: /*vuoto*/
	|lines expr EOL
	{ 
	print_valori(); 
	}
   	;

expr: expr UNIONE term
    {
    unionelem($1, $3);
    $$ = pos-1;
    }
    
    | expr INTERSEZIONE term
    {
    intersezionelem($1, $3);
    $$ = pos-1;
    }
    
    | expr DIFFERENZA term
    { 
    differenzaelem($1, $3);
    $$ = pos-1;
    }
    
    | term
    { 
    $$ = $1; 
    }
    ;
    	
term: SPARENTESI expr DPARENTESI
    { 
    $$ = $2;
    }
    
    | ID UGUALE VALORE 
    {
    char * c1= $1;
    char * c2 = $3;
    aggiungivalore(pos, (char *) c2, (char *)c1)
    $$ = pos-1;
    }
    
    | ADD VALOREI IDS
    {
    char * c1= $2;
    char * c2 = $3;
    aggiungielemento((char *)c1,(char *) c2);
    $$ = pos-1;
    }
    
    ;

%%

void print_valori(){
	int cont = 32;
	int valore = 0;
	printf("{ ");
	while(cont>=0){
		if(strcmp(valori[pos-1][cont], "1") == 0){
			printf("%d, ", valore);
			cont--;
			valore++;
		}else{
			cont--;
			valore++;
		}
		
	}
	
	printf("}");
}


void aggiungivalore(int posizione, char *valore, char *id){
	for(int i = 0; i<sizeof(id); i++){
		idpos[posizione][i] = ""+id[i];
	}
	for(int i = 0; i<32; i++){
		valori[posizione][i] = ""+valore[i];
	}
	pos++;
}


void aggiungielemento(char *id, char *val){
	int temp = trovanodo(id);
	valori[temp][atoi(val)]="1";
}

int trovanodo(char *id){
	int risultato;
	for(int i = 0; i<pos; i++){
		char *idtemp[50];
		for(int j = 0; j<50; j++){
			char idtemp[i] = idpos[pos][j];
		}
		if(strcmp(id, idtemp)==0){
			risultato = i;
	}
	return risultato;
	}
}

void unionelem(int id, int idd){

	for(int i = 0; i<32; i++){
		if(strcmp(valori[id][i], "1") == 0 && strcmp(valori[idd][i], "1") == 0){
			valori[pos][i] = "1";
		} else {
			valori[pos][i] = "0";
		}
	}
	pos++;
}

void intersezionelem(int id, int idd){
	
	for(int i = 0; i<32; i++){
		if(strcmp(valori[id][i], "1") == 0 || strcmp(valori[idd][i], "1") == 0){
			valori[pos][i] = "1";
		} else {
			valori[pos][i] = "0";
		}
	}
	
	pos++;
}

void differenzaelem(int id, int idd){
	
	for(int i = 0; i<32; i++){
		if(strcmp(valori[id][i], "1") == 0 && strcmp(valori[idd][i], "1") == 0 || strcmp(valori[id][i], "0") == 0 && strcmp(valori[idd][i], "0") == 0){
			valori[pos][i] = "0";
		} else {
			valori[pos][i] = "1";
		}
	}
	
	pos++;
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

