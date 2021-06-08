#include "tabel1.h"
#include "tabel2.h"
typedef struct {
    declar_var* variabile;
    declar_functie* functii;
} program;
program* parsedProgram;
typedef struct eval {
    int valoare, nr_linie;
    struct eval* urm;
} eval;



eval* evaluari;

int OK = 1;

void inserez_evaluari( int valoare, int nr_linie )
{
    eval* k = (eval*)malloc( sizeof( eval ) );
    k->valoare = valoare;
    k->nr_linie = nr_linie;
    k->urm = evaluari;
    evaluari = k;
}



void punct_de_start()
{
    parsedProgram = (program*)malloc( sizeof( program ) );
    init_variabile_tabel();
    init_functii_tabel();
    evaluari = (eval*)malloc( sizeof( eval ) );
    evaluari = NULL;
    parsedProgram->variabile = table_1_variabile;
    parsedProgram->functii = table_2_functii;
}


void afis_evaluarile(FILE* fisier_descriptor)
{   eval *p= evaluari;
    while (p)
    {
        fprintf(fisier_descriptor, "Functia eval de pe linia %d a returnat %d.\n", p->nr_linie, p->valoare );
        p=p->urm;
    }
}


void afis_in_main()
{
    FILE* descriptor;
    descriptor = fopen( "symbol_table.txt", "w" );
    if ( descriptor == NULL ) {
        printf("Fisierul nu a putut fi deschis.\n" );
        exit(0);
    }
    print_tabel( descriptor );
    afiseaza_functii( descriptor );
    if(OK != 0) {
        afis_evaluarile( descriptor);
    }
}


