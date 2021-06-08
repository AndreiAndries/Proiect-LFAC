#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>


typedef struct parametrii 
{
    char* type;
    struct parametrii* urm;
} parametrii;


typedef struct declar_functie {
	int lookfor;
    char* name; 
    char * face_parte_din;
    char * var_type;
    parametrii* params;
    struct declar_functie* urm_funct;
} declar_functie;


declar_functie* table_2_functii;

char* tipul_functiei( const char* name, int lookfor, char* face_parte_din );

int verif_existenta_functie( const char* name, int lookfor, char* face_parte_din )
{  declar_functie *p = table_2_functii;
    while (p) 
    {
        if ( strcmp( p->name, name ) == 0 && p->lookfor <= lookfor && strcmp( p->face_parte_din, face_parte_din ) == 0 ) 
        {
            return 1;
        p=p->urm_funct;
        }
    }
    return 0;
}

void init_param( declar_functie* func )
{
    func->params = NULL;
}


char* tipul_functiei( const char* name, int lookfor, char* face_parte_din )
{
    for ( declar_functie* p = table_2_functii; p; p = p->urm_funct ) 
    {
        if ( strcmp( p->name, name ) == 0 && p->lookfor <= lookfor && strcmp( p->face_parte_din, face_parte_din ) == 0 ) 
        {
            return p->var_type;
        }
    }
}


void adauga_functie( const char* name, const char* type, int lookfor, char* face_parte_din, char* parameters )
{
    declar_functie* k = (declar_functie*)malloc( sizeof( declar_functie ) );
    k->name = strdup( name );
    k->var_type = strdup( type ) ;
    k->lookfor = lookfor;
    k->face_parte_din = strdup( face_parte_din );
    init_param( k );
    char* new_param;
    new_param = strtok( parameters, " " );
    while ( new_param )
     {
        parametrii* param = (parametrii*)malloc( sizeof( parametrii ) );
        param->type = strdup( new_param );
        param->urm = k->params;
        k->params = param;
        new_param = strtok( NULL, " " );
    }
    k->urm_funct = table_2_functii;
    table_2_functii = k;
}


int verifica_functie( const char* name, const char* type, int lookfor, char* face_parte_din, char* parameters )
{   
	declar_functie *p=table_2_functii;
    while (p)
    {
        if ( !strcmp( p->name, name ) && !strcmp( p->var_type, type ) && p->lookfor <= lookfor &&
             !strcmp( p->face_parte_din, face_parte_din ) ) 
             {
            char* new_param;
            int local= 1;
            new_param = strtok( parameters, " " );
            for ( parametrii* q = p->params; q && local; q = q->urm )
             {
                local = (strcmp( q->type, new_param ) == 0);
                new_param = strtok( NULL, " " );
            }
            if ( local==0 ) {
                return 0;
            }
        }
   p=p->urm_funct; 
   }
    return 1;
}


int verifica_functie_utilizare( const char* name, int lookfor, char* face_parte_din, char* parameters )
{
    int done = 0;
    for ( declar_functie* p = table_2_functii; p && !done; p = p->urm_funct ) 
    {
        if ( !strcmp( p->name, name ) && p->lookfor <= lookfor && !strcmp( p->face_parte_din, face_parte_din ) ) 
        {
            done = 1;
            if ( strcmp( parameters, "fara_parametri" ) == 0 ) 
            {
                if ( p->params ) 
                {
                    return 0;
                }
                return 1;
            } 
            else 
            {
                char* new_param;
                new_param = strtok( parameters, " " );
                for ( parametrii* q = p->params; q; q = q->urm ) 
                {
                    if ( strcmp( q->type, new_param ) ) 
                    {
                        return 0;
                    }
                    new_param = strtok( NULL, " " );
                }
                if ( new_param ) 
                {
                    return 0;
                }
            }
        }
    }
    return 1;
}


void init_functii_tabel()
{
    table_2_functii = (declar_functie*)malloc( sizeof( declar_functie ) );
    table_2_functii = NULL;
}



void afiseaza_parametri( parametrii* param, FILE* fisier_descriptor )
{
    fprintf( fisier_descriptor, "; Tip parametru/parametri-" );
    char v[100][100];int i=0;
    for ( parametrii* p = param; p; p = p->urm ) 
    {
    	strcpy(v[i++],p->type);
        
    }
    for(int j=i-1;j>=0;j--)
    {
    fprintf( fisier_descriptor, " %s", v[j] );
    }
    fprintf( fisier_descriptor, " \n");
}


void afiseaza_functii( FILE* fisier_descriptor )
{
    for ( declar_functie* p = table_2_functii; p; p = p->urm_funct ) 
    {
        fprintf( fisier_descriptor, "Numele functiei- %s; Tip- %s; Membru in- %s", p->name, p->var_type, p->face_parte_din );
        afiseaza_parametri( p->params, fisier_descriptor );
    }
}


char* functie_gasita_in( int OK )
{
    
    if (OK==2)
       return "clasa";
    else
      if (OK==0)
         return "global";
         else
            return "";
}
