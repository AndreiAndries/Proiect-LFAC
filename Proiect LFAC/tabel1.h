#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct variable 
{
    char* name;
    char* var_type;
    double value;
    char* string;
    int lookfor, lungime_array , initializat, constant;
    char* face_parte_din;
    struct variable* urm_var;
} variable;
typedef struct variable declar_var;

declar_var* table_1_variabile;


int de_acelasi_tip( char*, char* );

void print_var_fara_asignare( declar_var* p, FILE* file );

void print_aray_fara_asignare( declar_var* p, FILE* file );

void print_var_initializata( declar_var* p, FILE* file );

char* tipul_variabilei_returnat( char const* name, char const* face_parte_din, int lookfor );

int este_asignat( int );

int apare_ca_global( int );

int returneaza_valoare( char const* name, int lookfor );

char* variabila_gasita_in( int );

char* returneaza_sirul( char const* name, char* face_parte_din, int lookfor );

void init_variabile_tabel()
{
    table_1_variabile = (declar_var*)malloc( sizeof( declar_var ) );
    table_1_variabile = NULL;
}


void adauga_variabila_string( char const* name, char const* var_type, int initializat, int constant, char const* value,int lookfor, int lungime_array, char* face_parte_din )
{
    declar_var* k = (declar_var*)malloc( sizeof( declar_var ) );
    k->name = strdup( name );
    k->var_type = strdup( var_type );
    k->initializat = initializat;
    k->constant = constant;
    k->string = strdup( value );
    k->lookfor = lookfor;
    k->lungime_array = lungime_array;
    k->face_parte_din = strdup( face_parte_din );
    k->urm_var = table_1_variabile;
    table_1_variabile = k;
}


void adauga_variabila_numar( char const* name, char const* var_type, int initializat, int constant, double value, int lookfor,int lungime_array, char* face_parte_din )
{
    declar_var* k = (declar_var*)malloc( sizeof( declar_var ) );
    k->name = strdup( name );
    k->var_type = strdup( var_type );
    k->constant = constant;
    k->initializat = initializat;
    k->value = value;
    k->lookfor = lookfor;
    k->lungime_array = lungime_array;
    k->face_parte_din = strdup( face_parte_din );
    k->urm_var = table_1_variabile;
    table_1_variabile = k;
}

declar_var* getVariable( char const* name, char const* face_parte_din, int lookfor )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) 
    {
        if ( ! strcmp( p->name, name ) && !strcmp( p->face_parte_din, face_parte_din ) && p->lookfor <= lookfor ) 
        {
            return p;
        }
    }
    return NULL;
}



int actualizare_variabila_int( char const* name, char const* face_parte_din, int lookfor, int value )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) 
    {
        if ( !strcmp( p->name, name ) && !strcmp( p->face_parte_din, face_parte_din )  && p->lookfor <= lookfor ) 
        {
            if ( p->constant ) 
            {
                return 2;
            }
            p->initializat = 1;
            p->value = value;
            return 1;
        }
    }
    return 0;
}

int actualizare_variabila_float( char const* name, char const* face_parte_din, int lookfor, double value )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) {
        if ( !strcmp( p->name, name )  && !strcmp( p->face_parte_din, face_parte_din )  && p->lookfor <= lookfor ) 
        {
            if ( p->constant ) 
            {
                return 2;
            }
            p->initializat = 1;
            p->value = value;
            return 1;
        }
    }
    return 0;
}





int actualizare_variabila_var( char const* name, char const* alt_nume )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) 
    {
        if ( ! strcmp( p->name, name ) ) 
        {
            for ( declar_var* r = table_1_variabile; r; r = r->urm_var ) 
            {
                if ( strcmp( r->name, alt_nume ) == 0 )
                 {
                    if ( p->constant ) 
                    {
                        return 2;
                    }
                    if ( !strcmp( p->var_type, "bool" ) || !strcmp( p->var_type, "float" ) ||
                         !strcmp( p->var_type, "int" )) {
                        if ( r->initializat ) 
                        {
                            p->value = r->value;
                            p->initializat = 1;
                            return 1;
                        }
                        return 3;
                    }
                    if ( !strcmp( p->var_type, "char" ) || !strcmp( p->var_type, "string" )  ) 
                    {
                        strcpy( p->string, r->string );
                        return 1;
                    }
                }
            }
        }
    }
    return 0;
}


char* tipul_variabilei_returnat( char const* name, char const* face_parte_din, int lookfor )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) 
    {
        if ( strcmp( p->name, name ) == 0 && strcmp( p->face_parte_din, face_parte_din ) == 0 && p->lookfor <= lookfor ) 
        {
            return p->var_type;
        }
    }
}

void print_tabel( FILE* file )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) 
    {
        if ( p ) 
        {
            if ( !este_asignat( p->initializat ) ) 
            {
                p->lungime_array == 0 ? print_var_fara_asignare( p, file )
                                    : print_aray_fara_asignare( p, file );
            } else {
                print_var_initializata( p, file );
            }
        }
    }
}


void print_var_fara_asignare( declar_var* p, FILE* file )
{
    fprintf( file, "Nume- %s; Tip- %s; Initializat- %s; Membru in- %s;\n", p->name, p->var_type, "Nu",p->face_parte_din );
}


void print_aray_fara_asignare( declar_var* p, FILE* file )
{
    fprintf( file, "Nume- %s; Tip: %s array; Initializat- %s; Lungime- %d; Membru in- %s;\n", p->name,p->var_type, "no", p->lungime_array, p->face_parte_din );
}



int actualizare_variabila_string( char const* name, char const* face_parte_din, int lookfor, char* value )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) 
    {
        if ( strcmp( p->name, name ) == 0 && strcmp( p->face_parte_din, face_parte_din ) == 0 && p->lookfor <= lookfor ) 
        {
            if ( p->constant ) 
            {
                return 2;
            }
            p->initializat = 1;
            strcpy( p->string, value );
            return 1;
        }
    }
    return 0;
}



int verificare_existenta( char const* name, char const* face_parte_din, int lookfor )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var )
     {
        if ( !strcmp( p->name, name ) &&
             ( strcmp( face_parte_din, "1" ) == 0 ? 1 : strcmp( p->face_parte_din, face_parte_din ) == 0 ) && p->lookfor <= lookfor )
              {
            return 1;
        }
    }
    return 0;
}


void print_var_initializata( declar_var* p, FILE* file )
{
    if ( !strcmp( p->var_type, "int" ) && p->lungime_array != 0)
     {
        fprintf( file,
                 "Nume- %s; Tip- %s array; Initializat- %s; Constant- %s; Valoare- %d; Lungime- %d; Membru "
                 "in- %s;\n",
                 p->name, p->var_type, "Da", p->constant ? "Da" : "Nu", (int)p->value, p->lungime_array, p->face_parte_din );
    }
    else if ( !strcmp( p->var_type, "int" ) && p->lungime_array == 0) 
    {
		   fprintf( file,
                 "Nume- %s; Tip- %s ; Initializat- %s; Constant- %s; Valoare- %d; Lungime- %d; Membru "
                 "in- %s;\n",
                 p->name, p->var_type, "Da", p->constant ? "Da" : "Nu", (int)p->value, p->lungime_array,
                 p->face_parte_din );
     }
     else if ( !strcmp( p->var_type, "float" ) && p->lungime_array != 0) 
     {
        fprintf( file,"Nume- %s; Tip- %s array; Initializat- %s; Constant: %s; Valoare- %f; Lungime- %d; Membru ""in- %s;\n",p->name, p->var_type, "Da", p->constant ? "Da" : "Nu", p->value, p->lungime_array,p->face_parte_din );
    } 
    else if ( !strcmp( p->var_type, "float" ) && p->lungime_array == 0) {
        fprintf( file,"Nume- %s; Tip- %s; Initializat- %s; Constant: %s; Valoare- %f; Lungime- %d; Membru ""in- %s;\n",p->name, p->var_type, "Da", p->constant ? "Da" : "Nu", p->value, p->lungime_array,p->face_parte_din );
    }
    else if ( !strcmp( p->var_type, "bool" ) && p->lungime_array != 0 ) {
        fprintf( file,"Nume- %s; Tip- %s array; Initializat- %s; Constant- %s; Valoare- %s; Lungime- %d; Membru ""in- %s;\n",p->name, p->var_type, "Da", p->constant ? "Da" : "Nu", p->value > 0 ? "true" : "false",p->lungime_array, p->face_parte_din );
    }
    else if ( !strcmp( p->var_type, "bool" ) && p->lungime_array == 0 ) {
        fprintf( file,"Nume- %s; Tip- %s array; Initializat- %s; Constant- %s; Valoare- %s; Lungime- %d; Membru ""in- %s;\n",p->name, p->var_type, "Da", p->constant ? "Da" : "Nu", p->value > 0 ? "true" : "false",p->lungime_array, p->face_parte_din );
    }
     else if ( !strcmp( p->var_type, "string" )  || !strcmp( p->var_type, "char" ) && p->lungime_array != 0 ) {
        fprintf( file,"Nume- %s; Tip- %s array; Initializat- %s; Constant: %s; Valoare: %s; Lungime- %d; Membru ""in- %s;\n",p->name, p->var_type, "Da", p->constant ? "Da" : "Nu", p->string, p->lungime_array,p->face_parte_din );
    }
    else if ( !strcmp( p->var_type, "string" )  || !strcmp( p->var_type, "char" ) && p->lungime_array == 0 ) {
        fprintf( file,"Nume- %s; Tip- %s; Initializat- %s; Constant: %s; Valoare: %s; Lungime- %d; Membru ""in- %s;\n",p->name, p->var_type, "Da", p->constant ? "Da" : "Nu", p->string, p->lungime_array,p->face_parte_din );
    }
}

int apare_ca_global( int lookfor )
{
   if (lookfor == 0 )
      return 1;
   else
      return 0;
}


int este_asignat( int initializat )
{
    if (initializat == 1 )
        return 1;
    else
        return 0;
}


char* variabila_gasita_in( int value )
{
    if (value == 0 )
        return "global";
    if (value == 1 )
        return "main";
   if (value == 2 )
        return "class";
    if (value == 3 )
        return "struct";
   if (value == 4)
        return "function";
   return "";
    
}


int de_acelasi_tip( char* s1, char* s2 )
{
if (!strcmp(s1,s2) )
      return 1;
 return 0;
}

int returneaza_valoare( char const* name, int lookfor )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) {
        if ( !strcmp( p->name, name ) && p->lookfor <= lookfor ) {
            return p->value;
        }
    }
}


char* returneaza_sirul( char const* name, char* face_parte_din, int lookfor )
{
    for ( declar_var* p = table_1_variabile; p; p = p->urm_var ) {
        if ( !strcmp( p->name, name )  && p->lookfor <= lookfor && !strcmp( p->face_parte_din, face_parte_din )  ) {
            return p->string;
        }
    }
}
