%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "syntax.tab.h"
#include "tab.h"

extern int yylineno;
%}

%option noyywrap

%%

"DEBUT"         { return DEBUT; }
"FIN"           { return FIN; }
"EXECUTION"     { return EXECUTION; }
"FIXE"          { return FIXE; }
"SI"            { return SI; }
"ALORS"         { return ALORS; }
"SINON"         { return SINON; }
"TANTQUE"       { return TANTQUE; }
"FAIRE"         { return FAIRE; }
"AFFICHER"      { return AFFICHER; }
"LIRE"          { return LIRE; }

[ \t]+   { }

\n      { yylineno++; }
"--"[^#]*"##"  { /* Ignorer les commentaires de ligne */ }
"{-"[^-]*"-}"  { /* Ignorer les commentaires multi-lignes */ }

[A-Za-z_][A-Za-z0-9_]* {
    yylval.sval = strdup(yytext);
    return IDENTIFIER;
}

[0-9]+ {
    yylval.ival = atoi(yytext);
    return INT_LITERAL;
}

[0-9]+\.[0-9]+ {
    yylval.dval = atof(yytext);
    return REAL_LITERAL;
}

"\"[^\"]*\"" {
  yylval.str = strdup(yytext + 1);  
    yylval.str[strlen(yylval.str) - 1] = '\0';  // Supprimer le guillemet de fin
    printf("Chaîne de caractères: \"%s\" à la ligne %d\n", yylval.str, yylineno);
    return TEXT_LITERAL;
}
\+             { return ADDITION; }
\-             { return SOUSTRACTION; }
\*             { return MULTIPLICATION; }
\/             { return DIVISION; }

"<"             { return LESS_THAN; }
"<="            { return LESS_THAN_EQUAL; }
">"             { return GREATER_THAN; }
">="            { return GREATER_THAN_EQUAL; }
"=="            { return EQUALS; }

\(             { return LPAREN; }
\)             { return RPAREN; }
\:             { return COLON; }
\{             { return LBRACE; }
\}             { return RBRACE; }
\[`            { return LBRACKET; }
\]             { return RBRACKET; }

";"             { return SEMICOLON; }

. {
    printf("Caractère inconnu: %s à la ligne %d\n", yytext, yylineno);
    exit(1);
}

%%

int yywrap(void) {
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *inputFile = fopen(argv[1], "r");
        if (inputFile == NULL) {
            fprintf(stderr, "Erreur d'ouverture du fichier d'entrée.\n");
            return 1;
        }
        yyin = inputFile;
    } else {
        yyin = stdin;
    }

    while (yylex()) {}

    printf("Table des symboles:\n");
    print_symbol_table();

    return 0;
}

