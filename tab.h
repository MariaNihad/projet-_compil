#ifndef TAB_H
#define TAB_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Définir la taille de la table de hachage
#define HASH_SIZE 100

// Types de symboles
#define NUM 0
#define REAL 1
#define TEXT 2

// Structure représentant un symbole
typedef struct symbol {
    char *name;            // Nom de la variable
    int type;              // Type de la variable (NUM, REAL, TEXT)
    union {
        int int_val;       // Valeur entière
        double real_val;   // Valeur réelle
        char *str_val;     // Valeur de chaîne
    };
    int is_const;          // Indique si la variable est une constante (1) ou non (0)
    int array_size;        // Taille du tableau (si c'est un tableau)
    int *array_vals;       // Valeurs du tableau
    struct symbol *next;   // Pointeur vers le prochain symbole en cas de collision
} symbol;

// Déclaration de la table des symboles
extern symbol *symbol_table[HASH_SIZE];

// Fonction de hachage pour l'indexation des symboles
int hash(const char *name);

// Ajouter un symbole à la table des symboles
void add_symbol(const char *name, int type, void *value, int is_const, int array_size);

// Rechercher un symbole par son nom dans la table des symboles
symbol *find_symbol(const char *name);

// Afficher la table des symboles
void print_symbol_table();

// Libérer la mémoire utilisée par la table des symboles
void free_symbol_table();

// Vérifications sémantiques
void check_double_declaration(const char *name);
void check_variable_declared(const char *name);
void check_type_compatibility(symbol *left, symbol *right);
void check_zero_division(symbol *divisor);
void check_constant_modification(symbol *var);
void check_array_bounds(symbol *var, int index);

#endif // TAB_H

#endif
