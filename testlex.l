%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEBUT 102
#define FIN 103
#define EXECUTION 104
#define FIXE 105
#define NUM 106
#define REAL 107
#define TEXT 108

#define SI 109
#define ALORS 110
#define SINON 111
#define TANTQUE 112
#define FAIRE 113

#define LESS_THAN_EQUAL 114
#define GREATER_THAN_EQUAL 115
#define LESS_THAN 116
#define GREATER_THAN 117
#define EQUALS 118

#define LPAREN 119
#define RPAREN 120
#define COLON 121
#define LBRACKET 122
#define RBRACKET 123
#define LBRACE 124
#define RBRACE 125
#define SEMICOLON 126

#define ADDITION 127
#define SOUSTRACTION 128
#define MULTIPLICATION 129
#define DIVISION 130

#define ET_LOGIQUE 131
#define OU_LOGIQUE 132
#define NON_LOGIQUE 133

#define INT_LITERAL 134
#define REAL_LITERAL 135
#define TEXT_LITERAL 136
#define IDENTIFIER 137

union {
    int num;
    float real;
    char *str;
} yylval;

int yylineno = 1;  // Initialisation du numéro de ligne
%}

%%

"DEBUT"        { printf("Mot-clé: DEBUT à la ligne %d\n", yylineno); return DEBUT; }
"FIN"          { printf("Mot-clé: FIN à la ligne %d\n", yylineno); return FIN; }
"EXECUTION"    { printf("Mot-clé: EXECUTION à la ligne %d\n", yylineno); return EXECUTION; }
"FIXE"         { printf("Mot-clé: FIXE à la ligne %d\n", yylineno); return FIXE; }
"NUM"          { printf("Mot-clé: NUM à la ligne %d\n", yylineno); return NUM; }
"REAL"         { printf("Mot-clé: REAL à la ligne %d\n", yylineno); return REAL; }
"TEXT"         { printf("Mot-clé: TEXT à la ligne %d\n", yylineno); return TEXT; }
"SI"           { return SI; }
"ALORS"        { return ALORS; }
"SINON"        { return SINON; }
"TANTQUE"      { return TANTQUE; }
"FAIRE"        { return FAIRE; }

"<="           { return LESS_THAN_EQUAL; }
">="           { return GREATER_THAN_EQUAL; }
"<"            { return LESS_THAN; }
">"            { return GREATER_THAN; }
"="            { return EQUALS; }
"("            { return LPAREN; }
")"            { return RPAREN; }
":"            { return COLON; }
"["            { return LBRACKET; }
"]"            { return RBRACKET; }
"{"            { return LBRACE; }
"}"            { return RBRACE; }
";"            { return SEMICOLON; }

"+"            { return ADDITION; }
"-"            { return SOUSTRACTION; }
"*"            { return MULTIPLICATION; }
"/"            { return DIVISION; }

"ET"           { return ET_LOGIQUE; }
"OU"           { return OU_LOGIQUE; }
"NON"          { return NON_LOGIQUE; }

"--"[^#]*"##"  { /* Ignorer les commentaires de ligne */ }
"{-"[^-]*"-}"  { /* Ignorer les commentaires multi-lignes */ }

[A-Z][A-Za-z0-9_]{0,9} {
    yylval.str = strdup(yytext);  // Stocker l'identifiant dans yylval
    printf("Identifiant: %s à la ligne %d\n", yytext, yylineno);
    return IDENTIFIER;
}

[0-9]+ {
    yylval.num = atoi(yytext);  // Stocker l'entier dans yylval
    printf("Constante entière: %d à la ligne %d\n", yylval.num, yylineno);
    return INT_LITERAL;
}

[0-9]+\.[0-9]+ {
    yylval.real = atof(yytext);  // Stocker le réel dans yylval
    printf("Constante réelle: %f à la ligne %d\n", yylval.real, yylineno);
    return REAL_LITERAL;
}

"\"[^\"]*\"" {
    // Enlever les guillemets autour de la chaîne et allouer une nouvelle chaîne
    yylval.str = strdup(yytext + 1);  
    yylval.str[strlen(yylval.str) - 1] = '\0';  // Supprimer le guillemet de fin
    printf("Chaîne de caractères: \"%s\" à la ligne %d\n", yylval.str, yylineno);
    return TEXT_LITERAL;
}


\n              { yylineno++; }

%%

int yywrap() {
    return 1;  // Fin de fichier
}

int main(int argc, char **argv) {
    // Redirection des fichiers d'entrée et de sortie
    if (argc > 1) {
        FILE *inputFile = fopen(argv[1], "r");
        if (inputFile == NULL) {
            fprintf(stderr, "Erreur d'ouverture du fichier d'entrée.\n");
            return 1;
        }
        yyin = inputFile;  // Assigner le fichier d'entrée
    }

    // Lancer le processus de lexing (analyse lexicale)
    while (yylex()) {  // Appeler yylex() jusqu'à la fin du fichier
    }

    return 0;
}


