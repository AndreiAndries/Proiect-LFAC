%{
#define MAX_FUNCTIONS 100
#include <stdio.h>
#include "tabelunion.h"
#include <string.h>
extern FILE* yyin;
extern char* yytext;
extern int OK, yylineno, locatie_curenta;
extern int lookfor;
int yylex();
void yyerror(const char* sir);
static char *definedfct[MAX_FUNCTIONS];
static int num_functions = 0;
%}
%union {
    struct declar_functie* table_2_functii;
    struct declar_var* table_1_variabile;
    struct eval* evals;
    int tip_int;
    char* tip_string;
    double tip_double;
    char* tip_point;
    struct { 
    double nr_cu_virgula; 
    int nr_intreg; 
    char* varname; 
    char* str;} tip_var;
}

%start  programul 

%token  RETURN EVAL FOR WHILE IF ELSE MAIN SI SAU LEQ GEQ NEQ EQ ASIGN NOT PUNCT
%token<tip_point> START STOP BOOL FLOAT INT CHAR STRING STRUCTURA CLASS ENUM FUNCTIE
%type<tip_point> tip_de_date parametru_signatura parametri_signatura apel_de_parametri parametru apel_de_functie
%token<tip_int>  VARIABILA NR LUNG CONSTANTA 
%token<tip_double> NR_FLOAT
%token<tip_string> ID STRINGUL 
%type<tip_int> calcul_expr evaluate var_sau_vec identificator_var strl 
%type<tip_var> var
%type<tip_string> str_val
%left '-' '+'
%left '*' '/' '%'

%%
programul : START declar_variabile main STOP {if (OK != 0) {printf("Programul este corect !\n");} } |
             START declar_variabile declar_clase declar_functii main STOP {if(OK != 0){ printf("Programul este corect ! \n");} }
    ;

declar_variabile
    : declar ';' 
    | declar_variabile declar ';'
    ;

declar
    : declar_variabila
    | declar_structura
    | declar_enum
    | evaluate
    ;

declar_clase
    : CLASS ID '{'{lookfor= lookfor + 1 ;locatie_curenta = locatie_curenta + 1;} class_interior '}'{lookfor = lookfor - 1 ; locatie_curenta= locatie_curenta - 1;}
    | evaluate
    |
    ;
class_interior
    : class_interior class_componenta
    | class_componenta
    ;
class_componenta
    : declar_variabila ';'
    | declar_functie
    ;

declar_variabila
    : identificator_var tip_de_date ID var_sau_vec             
        {    
        if(!verificare_existenta($3,variabila_gasita_in(locatie_curenta),lookfor)&&!$1)
                adauga_variabila_numar($3,$2,0,0,0,lookfor,$4,variabila_gasita_in(locatie_curenta));
            else if($1 ==1)printf("La linia %d : '%s' Constanta trebuie sa fie initializata!\n",yylineno,$3);
            else{
            	OK=0; 
                printf("La linia %d:  '%s' Numele variabilei este deja utilizat!.\n",yylineno,$3);                         
                 
            }
        }
    | identificator_var tip_de_date ID var_sau_vec ASIGN NR {
        if( de_acelasi_tip($2,"bool") || de_acelasi_tip($2,"int")) 
        {  
            if(!verificare_existenta($3,variabila_gasita_in(locatie_curenta),lookfor))
                adauga_variabila_numar($3,$2,1,$1,$6,lookfor,$4,variabila_gasita_in(locatie_curenta));
            else{
            	OK=0; 
                printf("La linia %d: Numele variabilei '%s' e deja utilizat!\n",yylineno,$3);
                            
            }        
        }
        else
            printf("La linia %d: Tipuri de date diferite! \n",yylineno); 
    }
    | identificator_var tip_de_date ID var_sau_vec ASIGN NR_FLOAT {
        if( de_acelasi_tip($2,"float"))
        {  
            if(!verificare_existenta($3,variabila_gasita_in(locatie_curenta),lookfor))
                adauga_variabila_numar($3,$2,1,$1,$6,lookfor,$4,variabila_gasita_in(locatie_curenta));
            else {
                printf("La linia %d: Numele variabilei '%s' e deja utilizat!\n",yylineno,$3);
                OK=0; 
            }
        }
        else {OK=0; 
            printf("La linia %d: Tipuri de date diferite! \n",yylineno);
         
        }
     }
    |  identificator_var tip_de_date ID var_sau_vec ASIGN STRINGUL {
        if( de_acelasi_tip($2,"string") || de_acelasi_tip($2,"char"))
        {  
            if(!verificare_existenta($3,variabila_gasita_in(locatie_curenta),lookfor))
            {
                adauga_variabila_string($3,$2,1,$1,$6,lookfor,$4,variabila_gasita_in(locatie_curenta));
                }
            else {OK=0; 
                printf("La linia %d: Numele variabilei '%s' e deja utilizat!\n",yylineno,$3);       
            }
        }    
        else {
        OK=0; 
            printf("La linia %d: Tipuri de date diferite! \n",yylineno); 
         
        }
    }  
    ;

identificator_var
    : VARIABILA {$$=$1;}
    | CONSTANTA {$$=$1;}
    | {$$=0;} 
    ;

tip_de_date
    : INT {$$=$1;}
    | FLOAT {$$=$1;}
    | CHAR {$$=$1;}
    | STRING {$$=$1;}
    | BOOL {$$=$1;}
    ;

var_sau_vec
    : '[' NR ']' {$$=$2;}
    | {$$=0;}
    ;

declar_structura
    : STRUCTURA ID '{'{locatie_curenta+=2;} lista_structura '}'{locatie_curenta-=2;}
    | STRUCTURA '{'{locatie_curenta+=2;} lista_structura '}'{locatie_curenta-=2;} ID
    ;

lista_structura
    : componenta_structura ';'
    | lista_structura componenta_structura ';'
    ;
componenta_structura
    : declar_variabila
    ;


var
    : NR {$$.nr_intreg=$1;}
    | NR_FLOAT {$$.nr_cu_virgula=$1;}
    | STRINGUL {$$.str=$1;}  
    | ID {$$.varname=$1;}
    ;
    
    
declar_enum
    : ENUM ID '{' lista_enum '}'
    | ENUM '{' lista_enum '}' ID
    ;


lista_enum
    : sir_constant
    | lista_enum ',' sir_constant
    ; 
    
    
sir_constant
    : constant
    | STRINGUL
    ;
    
    
constant
    : NR
    | NR_FLOAT
    ;


declar_functii
    : declar_functie
    | declar_functii declar_functie   
    ;


declar_functie
    : FUNCTIE tip_de_date ID '(' parametri_signatura ')' bloc_functie 
{char *fcn_name = $3;
int ok=1;
    int i;
    for(i = 0; i < num_functions; i++){
        if(!strcmp(fcn_name,definedfct[i]))
            ok=0;  }
if (ok==0)
   {
   printf("%s\n","O astfel de functie deja exista");
    exit(0);
    }
else
    {
    definedfct[num_functions] = malloc(strlen(fcn_name)+1);
        strcpy(definedfct[num_functions],fcn_name);
        num_functions++;
        }

    if(verifica_functie($3,$2,lookfor,functie_gasita_in(locatie_curenta),$5)) {
        adauga_functie($3,$2,lookfor,functie_gasita_in(locatie_curenta),$5);
    } else {
        OK=0; 
        printf("Pe linia %d: Deja exista o functie cu numele '%s' avand o astfel de signatura: '%s'.\n",yylineno,$3,$5);
    }
}
    ;


bloc_functie
    : before_acolade
    ;



parametri_signatura
    : parametru_signatura {$$=$1;}
    | parametri_signatura ',' parametru_signatura {strcat($$," ");strcat($$,$3);}
    ;



parametru_signatura
    : tip_de_date ID
    | tip_de_date ID '['NR']'
    ;



main
    : MAIN ':' inainte_de_bloc
    ;
    
    
before_acolade
    : '{'{locatie_curenta+=3;} bloc returneaza'}'{locatie_curenta-=3;}
    | '{'{locatie_curenta+=3;} returneaza '}'{locatie_curenta-=3;}
    | '{'{locatie_curenta+=3;} '}'{locatie_curenta-=3;}
    ;



inainte_de_bloc
    : '{' '}'
    | '{'{lookfor++;} bloc '}'{lookfor--;}
    ;
    
    
returneaza
    : RETURN ID';' | RETURN NR ';' | RETURN NR_FLOAT ';' | RETURN STRINGUL ';'
    ;


bloc: lista_execut
    ;


lista_execut
    : execut 
    | lista_execut execut
    ;


execut
    : execut_asignare ';'
    | execut_if
    | execut_for
    | execut_while
    | evaluate';'
    ;
    
    
execut_asignare
    : ID ASIGN NR 
{
    if(verificare_existenta($1,variabila_gasita_in(locatie_curenta-1),lookfor)) 
    {
        char* k0;
        k0 = tipul_variabilei_returnat($1,variabila_gasita_in(locatie_curenta-1),lookfor);
        if(de_acelasi_tip(k0,"int")||de_acelasi_tip(k0,"bool")){if(actualizare_variabila_int($1,variabila_gasita_in(locatie_curenta-1),lookfor,$3)==2) 
        {
        OK=0;printf("Variabila cu numele '%s' de la linia %d e constanta si nu poate fi modificata!\n",$1,yylineno);}
        }
        else {
        printf("Variabila '%s' de la linia %d nu este de tip int!\n",$1,yylineno);OK=0;
          }
    }
    else { 
    	printf("Pe linia %d, variabila '%s' nu e declarata!\n",yylineno,$1);OK=0;
    	 }
} 
    | ID ASIGN NR_FLOAT{
    if(verificare_existenta($1,variabila_gasita_in(locatie_curenta-1),lookfor))
     {
        char* k0;
        k0 = tipul_variabilei_returnat($1,variabila_gasita_in(locatie_curenta-1),lookfor);
        if(de_acelasi_tip(k0,"float")){if(2==actualizare_variabila_float($1,variabila_gasita_in(locatie_curenta-1),lookfor,$3))
         {
         OK=0;printf("Variabila %s de la linia %d este constanta si nu poate fi modificata!\n",$1,yylineno);
         }
         }
        else {printf("Variabila %s de pe linia %d nu este de tip float!\n",$1,yylineno); OK=0; 
        }
    }
    else { printf("Pe linia %d: variabila %s nu e declarata!\n",yylineno,$1);OK=0; }
} 
    | ID ASIGN ID 
{   if ( verificare_existenta( $1, variabila_gasita_in( locatie_curenta - 1 ), lookfor ) ) 
{
        if ( verificare_existenta( $3, variabila_gasita_in( locatie_curenta - 1 ), lookfor ) ) 
        {
           if(de_acelasi_tip(tipul_variabilei_returnat($1,variabila_gasita_in(locatie_curenta-1),lookfor),tipul_variabilei_returnat($3,variabila_gasita_in(locatie_curenta-1),lookfor))){
                int result = actualizare_variabila_var($1,$3);
                if(result==2) {OK=0; printf("Variabila %s de pe linia %d este constanta si nu poate fi modificata!\n",$1,yylineno);}
                if(result==3) {OK=0; printf("Variabila %s de pe linia %d nu a fost initializata!\n",$3,yylineno);}      
            }
            else {OK=0; 
                printf( "Pe linia %d: variabilele %s si %s au tipuri de date diferite.\n", yylineno, $1, $3 );
           }
        } 
        else {OK=0; 
            printf( "Pe linia %d, variabila %s nu a fost declarata!\n", yylineno, $3 );
        }
    }
    else {
    	OK=0; 
        printf( "Pe linia %d, variabila %s nu a fost declarata!\n", yylineno, $1 );
    }
}   
    | ID ASIGN str_val{
    if(verificare_existenta($1,variabila_gasita_in(locatie_curenta-1),lookfor)) 
    {
        char* k0;
        k0 = tipul_variabilei_returnat($1,variabila_gasita_in(locatie_curenta-1),lookfor);
        if(de_acelasi_tip(k0,"string")||de_acelasi_tip(k0,"char"))
            {
                actualizare_variabila_string($1,variabila_gasita_in(locatie_curenta-1),lookfor,$3);
                        
            }

        else {
        printf("Variabila %s de pe linia %d nu este de tip string sau char.\n",$1,yylineno);OK=0;  
        }
    }
    else {
     printf("Pe linia %d: Variabila %s nu a fost declarata!\n",yylineno,$1);OK=0;
     }
} 
    | ID ASIGN strl
{
    if ( verificare_existenta( $1, variabila_gasita_in( locatie_curenta - 1 ), lookfor )) 
    {
        if(de_acelasi_tip(tipul_variabilei_returnat($1,variabila_gasita_in(locatie_curenta-1),lookfor),"int"))
        {
            if(actualizare_variabila_int($1,variabila_gasita_in(locatie_curenta-1),lookfor,$3)==2) 
            {
            OK=0;printf("Variabila'%s' de pe linia %d este constanta si nu poate fi modificata!\n",$1,yylineno);}
        }
         else 
         {
            OK=0; 
                printf( "Pe linia %d: variabilele %s nu sunt de tip int!\n", yylineno, $1 );
        }
    } 
    else {OK=0; 
        printf( "Pe linia %d: variabila %s nu a fost declarata!\n", yylineno, $1 );
    }
}
    ;
    
    
str_val
    : STRINGUL { char* p = $1; p++; p[strlen(p)-1]=0; strdup(p);}
    | str_val '+' STRINGUL { char* p = $3; p++; p[strlen(p)-1]=0; strcat($$,p); }
    | str_val '*' NR 

    ;
    
    
execut_if
    : IF '('expresie_bool')' inainte_de_bloc cond_else 
    ;



cond_else
    : ELSE inainte_de_bloc
    |
    ;



execut_for
    : FOR '(' ID ASIGN var':'operatii var ':' var')' inainte_de_bloc
    ;



execut_while
    : WHILE '('expresie_bool ')' inainte_de_bloc
    ;



expresie_bool
    : bloc_expresie
    ;



bloc_expresie
    : expresie
    | expresie operator_comparare expresie
    ;
    
    
expresie
    : operand
    | expresie semn1 operand
    ;
    
    
operand
    : termen
    | operand  semn2 termen
    ;
    
    
termen
    : ID
    | constant
    | ID PUNCT ID
    | apel_de_functie
    ;
operator_comparare
    : EQ
    | NEQ
    | '<'
    | '>'
    | LEQ
    | GEQ
    ;
    
    
operatii
    : semn1
    | semn2    
    ;
    
    
semn1
    : op_plus_minus
    | SAU
    ;
op_plus_minus
    : '+'
    | '-'
    ;
    
    
semn2
    : op_prioritar
    | SI  
    ;
op_prioritar
    : '*'
    | '/'
    | '%'
    ;	
    
    
apel_de_functie
    : ID '(' apel_de_parametri ')' 
{  
    if(verif_existenta_functie($1,lookfor,functie_gasita_in(locatie_curenta-1)))
    {
        if(!verifica_functie_utilizare($1, lookfor, functie_gasita_in(locatie_curenta-1), $3)) {
            OK=0; printf("Pe linia %d: Functia '%s' nu are o astfel de signatura!\n",yylineno,$1);
        } 
        else 
        {
            $$=strdup(tipul_functiei($1,lookfor,functie_gasita_in(locatie_curenta-1)));
        }  
    } 
    else 
    {
    OK=0;
    printf("Pe linia %d: Functia '%s' nu a fost declarata!\n",yylineno,$1); 
   }
}
    
    | ID '(' ')' 
{ 
    if(verif_existenta_functie($1,lookfor,functie_gasita_in(locatie_curenta-1))) 
    {
        if(!verifica_functie_utilizare($1, lookfor, functie_gasita_in(locatie_curenta-1), "fara_parametri")) 
        {
            OK=0; printf("Pe linia %d: Functia '%s' nu are o astfel de signatura!\n",yylineno,$1);
        } 
        else 
        {
            $$=strdup(tipul_functiei($1,lookfor,functie_gasita_in(locatie_curenta-1)));
        }
    }
    else {OK=0;
    printf("Pe linia %d: Functia '%s' nu a fost declarata!\n",yylineno,$1); 
   }
}
    ;
apel_de_parametri
    : parametru {$$=$1;}
    | apel_de_parametri ',' parametru {strcat($$," ");strcat($$,$3);}
    ;
    
    
parametru
    : ID {$$=strdup(tipul_variabilei_returnat($1,variabila_gasita_in(locatie_curenta-1),lookfor));}
    | NR {$$=strdup("int");}
    | NR_FLOAT {$$=strdup("float");}
    | apel_de_functie { $$=$1;}  
    ;


evaluate
    : EVAL tip_de_date ':' calcul_expr  {if (strcmp($2,"int")!=0) {printf("Parametrul trebuie sa fie int !"); exit (0);}if(OK) {inserez_evaluari($4,yylineno);}}
    ;
    
    
calcul_expr
    : calcul_expr '+' calcul_expr { $$ = $1 + $3; }
    | calcul_expr '-' calcul_expr { $$ = $1 - $3; }
    | calcul_expr '*' calcul_expr { $$ = $1 * $3; }
    | calcul_expr '/' calcul_expr { $$ = $1 / $3; }
    | calcul_expr '%' calcul_expr { $$ = $1 % $3; }
    | '('calcul_expr')' { $$ = $2; }
    | '-' calcul_expr { $$ = -$2; } 
    | NR { $$ = $1; }
    | ID  
{
    int result = verificare_existenta($1,"1",lookfor);
    if(result) 
    {
        if(de_acelasi_tip(tipul_variabilei_returnat($1,variabila_gasita_in(locatie_curenta-1),lookfor),"int")) 
        {
            $$=returneaza_valoare($1,lookfor);
        } else 
        {
        OK=0; 
            printf("Pe linia %d: Variabila '%s' nu este de tip int!\n",yylineno,$1);
        }    
    }
     else 
    {
    OK=0; 
        printf("Line %d: Variabila '%s' nu a fost declarata!",yylineno,$1);
    }
}
    ;
    
    
strl
    : LUNG '(' str_val ')' 
{
    $$=strlen($3)-2;

}
    | LUNG '(' ID ')' 
{
    if ( verificare_existenta( $3, variabila_gasita_in( locatie_curenta - 1 ), lookfor )) 
    {
        if(de_acelasi_tip(tipul_variabilei_returnat($3,variabila_gasita_in(locatie_curenta-1),lookfor),"string")||de_acelasi_tip(tipul_variabilei_returnat($3,variabila_gasita_in(locatie_curenta-1),lookfor),"char"))
        {
            char* k0=returneaza_sirul($3,variabila_gasita_in(locatie_curenta-1),lookfor);
            $$=strlen(k0)-2;
        
        } 
        else
         {
            OK=0; 
                printf( "Pe linia %d: Variabilele %s nu sunt de tip char sau string!\n", yylineno, $3 );
        }
    } 
    else {OK=0; 
        printf( "Pe linia %d: variabila %s nu a fost declarata!\n", yylineno, $3 );
    }
}
    ;
%%
void yyerror(const char* s)
{
    printf("Eroare: %s la %s linia:%d\n",s,yytext,yylineno);
}

int main(int argc, char** argv)
{
yyin=fopen(argv[1],"r");
punct_de_start();
yyparse();
afis_in_main();
} 
