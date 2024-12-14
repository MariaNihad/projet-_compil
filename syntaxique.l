{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tab.h"

extern int yylineno;  // Line number for error reporting

#define MAX_SYMBOLS 100
#define MAX_ARRAY_SIZE 100

#define NUM 0
#define REAL 1
#define TEXT 2

typedef struct {
    char *name;
    int type;  // NUM, REAL, or TEXT
    union {
        int int_val;
        float real_val;
        char *text_val;
    };
    int is_const;  // 1 for constant, 0 for variable
    int array_size;  // Only relevant for arrays
} symbol;

symbol *symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

int add_symbol(char *name, int type, void *value, int is_const, int array_size) {
    if (symbol_count >= MAX_SYMBOLS) return -1;
    symbol_table[symbol_count] = malloc(sizeof(symbol));
    symbol_table[symbol_count]->name = strdup(name);
    symbol_table[symbol_count]->type = type;
    symbol_table[symbol_count]->is_const = is_const;
    symbol_table[symbol_count]->array_size = array_size;
    if (type == NUM) symbol_table[symbol_count]->int_val = *((int *)value);
    if (type == REAL) symbol_table[symbol_count]->real_val = *((float *)value);
    if (type == TEXT) symbol_table[symbol_count]->text_val = strdup((char *)value);
    symbol_count++;
    return symbol_count - 1;
}

int find_symbol(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i]->name, name) == 0) {
            return i;
        }
    }
    return -1;
}

int check_declared(char *name) {
    int idx = find_symbol(name);
    if (idx == -1) {
        printf("Erreur : Variable %s non déclarée à la ligne %d.\n", name, yylineno);
        exit(1);
    }
    return idx;
}

int check_double_declaration(char *name) {
    if (find_symbol(name) != -1) {
        printf("Erreur : Variable %s déjà déclarée à la ligne %d.\n", name, yylineno);
        exit(1);
    }
    return 0;  // Pas de double déclaration
}

void check_type_compatibility(symbol left, symbol right, char *operator) {
    if (left.type != right.type) {
        printf("Erreur de type : incompatibilité de type lors de l'opération %s à la ligne %d.\n", operator, yylineno);
        exit(1);
    }
}

void check_zero_division(symbol divisor) {
    if ((divisor.type == NUM && divisor.int_val == 0) || (divisor.type == REAL && divisor.real_val == 0.0)) {
        printf("Erreur : Division par zéro à la ligne %d.\n", yylineno);
        exit(1);
    }
}

void check_constant_modification(symbol *var) {
    if (var->is_const) {
        printf("Erreur : Modification d'une constante à la ligne %d.\n", yylineno);
        exit(1);
    }
}

void check_array_bounds(int index, int array_size) {
    if (index >= array_size || index < 0) {
        printf("Erreur : Dépassement de la taille du tableau à la ligne %d.\n", yylineno);
        exit(1);
    }
}

%}

%token DEBUT FIN EXECUTION FIXE NUM REAL TEXT SI ALORS SINON TANTQUE FAIRE
%token IDENTIFIER INT_LITERAL REAL_LITERAL TEXT_LITERAL
%token ADDITION SOUSTRACTION MULTIPLICATION DIVISION
%token LESS_THAN LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL EQUALS
%token LPAREN RPAREN COLON LBRACKET RBRACKET LBRACE RBRACE SEMICOLON AFFICHER LIRE

%start program

%left ADDITION SOUSTRACTION
%left MULTIPLICATION DIVISION
%left LESS_THAN LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL EQUALS
%left OU_LOGIQUE
%left ET_LOGIQUE
%right NON_LOGIQUE

%%

program:
    DEBUT instructions FIN
    ;

instructions:
    instructions instruction
    | instruction
    ;

instruction:
    SI expression ALORS instructions SINON instructions
    | TANTQUE expression FAIRE instructions
    | expression
    | declaration
    | affichage
    | lecture
    ;

declaration:
    FIXE type IDENTIFIER SEMICOLON {
        check_double_declaration($3);  // Vérifie si la variable est déjà déclarée
        add_symbol($3, $2, NULL, 0, 0);  // Ajoute une variable
    }
    | FIXE type IDENTIFIER EQUALS expression SEMICOLON {
        check_double_declaration($3);  // Vérifie si la variable est déjà déclarée
        add_symbol($3, $2, &$5, 0, 0);  // Ajoute une variable avec valeur initiale
    }
    | FIXE type IDENTIFIER LBRACKET INT_LITERAL RBRACKET SEMICOLON {
        check_double_declaration($3);  // Vérifie si la variable est déjà déclarée
        add_symbol($3, $2, NULL, 0, $5);  // Ajoute un tableau
    }
    | FIXE type IDENTIFIER LBRACKET INT_LITERAL RBRACKET EQUALS expression SEMICOLON {
        check_double_declaration($3);  // Vérifie si la variable est déjà déclarée
        add_symbol($3, $2, &$7, 0, $5);  // Ajoute un tableau avec une valeur initiale
    }
    ;

type:
    NUM { $$ = NUM; }
    | REAL { $$ = REAL; }
    | TEXT { $$ = TEXT; }
    ;

expression:
    term { $$ = $1; }
    | expression ADDITION term { 
        check_type_compatibility($1, $3, "addition");
        $$ = malloc(sizeof(symbol));
        if ($1.type == NUM && $3.type == NUM) {
            $$->type = NUM;
            $$->int_val = $1.int_val + $3.int_val;
        } else {
            $$->type = REAL;
            $$->real_val = $1.real_val + $3.real_val;
        }
    }
    | expression SOUSTRACTION term { 
        check_type_compatibility($1, $3, "soustraction");
        $$ = malloc(sizeof(symbol));
        if ($1.type == NUM && $3.type == NUM) {
            $$->type = NUM;
            $$->int_val = $1.int_val - $3.int_val;
        } else {
            $$->type = REAL;
            $$->real_val = $1.real_val - $3.real_val;
        }
    }
    ;

term:
    factor
    | term MULTIPLICATION factor { 
        check_type_compatibility($1, $3, "multiplication");
        $$ = malloc(sizeof(symbol));
        if ($1.type == NUM && $3.type == NUM) {
            $$->type = NUM;
            $$->int_val = $1.int_val * $3.int_val;
        } else {
            $$->type = REAL;
            $$->real_val = $1.real_val * $3.real_val;
        }
    }
    | term DIVISION factor { 
        check_zero_division($3);
        check_type_compatibility($1, $3, "division");
        $$ = malloc(sizeof(symbol));
        if ($1.type == NUM && $3.type == NUM) {
            $$->type = NUM;
            $$->int_val = $1.int_val / $3.int_val;
        } else {
            $$->type = REAL;
            $$->real_val = $1.real_val / $3.real_val;
        }
    }
    ;

factor:
    IDENTIFIER { 
        int idx = check_declared($1);  // Vérifie si la variable est déclarée
        $$ = symbol_table[idx];
    }
    | INT_LITERAL { 
        $$ = malloc(sizeof(symbol));
        $$->type = NUM;
        $$->int_val = $1;
    }
    | REAL_LITERAL { 
        $$ = malloc(sizeof(symbol));
        $$->type = REAL;
        $$->real_val = $1;
    }
    | TEXT_LITERAL { 
        $$ = malloc(sizeof(symbol));
        $$->type = TEXT;
        $$->text_val = strdup($1);
    }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

affichage:
    AFFICHER LPAREN expression RPAREN {
        if ($3.type == NUM) {
            printf("%d\n", $3.int_val);
        } else if ($3.type == REAL) {
            printf("%f\n", $3.real_val);
        } else if ($3.type == TEXT) {
            printf("%s\n", $3.text_val);
        }
    }
    ;

lecture:
    LIRE LPAREN IDENTIFIER RPAREN {
        int idx = check_declared($3);  // Vérifie si la variable est déclarée
        printf("Entrez une valeur pour %s: ", $3);
        if (symbol_table[idx]->type == NUM) {
            scanf("%d", &symbol_table[idx]->int_val);
        } else if (symbol_table[idx]->type == REAL) {
            scanf("%f", &symbol_table[idx]->real_val);
        } else if (symbol_table[idx]->type == TEXT) {
            char buffer[100];
            scanf("%s", buffer);
            symbol_table[idx]->text_val = strdup(buffer);
        }
    }
    ;

%%

int main() {
    yyparse();
    return 0;
}
