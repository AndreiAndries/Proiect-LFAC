%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
int lookfor=0, locatie_curenta=0,yylineno=1;
%}
%option noyywrap
%%

"int" {yylval.tip_point = strdup(yytext); return INT;}
"float" {yylval.tip_point = strdup(yytext);return FLOAT;}
"char" {yylval.tip_point = strdup(yytext); return CHAR;}
"string" {yylval.tip_point = strdup(yytext); return STRING;}
"bool" {yylval.tip_point = strdup(yytext); return BOOL;}
"start" {yylval.tip_point= strdup(yytext); return START; }
"stop" {yylval.tip_point=strdup(yytext); return STOP; }
"enum" {yylval.tip_point = strdup(yytext); return ENUM;}
"structura" {yylval.tip_point = strdup(yytext); return STRUCTURA;}
"clasa" {yylval.tip_point = strdup(yytext); return CLASS;}

"eval" {return EVAL;}
"lung" {return LUNG;}
"functie" {return FUNCTIE;}
"return" {return RETURN;}
"constanta" {yylval.tip_int=1; return CONSTANTA;}
"variabila" {yylval.tip_int=0; return VARIABILA;}

"si" {return SI;}
"sau" {return SAU;}

"{" {locatie_curenta=locatie_curenta+1 ; return('{');}
"}" {locatie_curenta=locatie_curenta-1; return('}');}
"." {return PUNCT;}
"<-" {return ASIGN;}
"!" {return NOT;}
"-" {return ('-');}
"+" {return ('+');}
"*" {return ('*');}
"/" {return ('/');}
"%" {return ('%');}
"<" {return ('<');}
">" {return ('>');}
"<=" {return LEQ;}
">=" {return GEQ;}
"~=" {return NEQ;}
"=" {return  EQ;}




"for" {return FOR;}
"while" {return WHILE;}
"if" {return IF;}
"else" {return ELSE;}
    
"principal" {return MAIN;}
 
[_a-zA-Z][_a-zA-Z0-9]* { yylval.tip_string = strdup(yytext);return ID;}
\"[^"\n]*["\n] {yylval.tip_string = strdup(yytext);return STRINGUL;}

0|[+-]?[1-9][0-9]* {yylval.tip_int = strtol(yytext,NULL,10); return NR;}
[+-]?([1-9][0-9]*\.[0-9]+)|(0\.[0-9]+) { yylval.tip_double = strtod(yytext,NULL); return NR_FLOAT;}

[ \t] ;
\n {yylineno++;}
. {return yytext[0];}
%%
