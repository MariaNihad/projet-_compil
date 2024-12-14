#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tab.h"

// Table des symboles
symbol *symbol_table[HASH_SIZE] = {0};
int symbol_count = 0;

// Fonction de hachage
int hash(const char *str) {
    int hash_value = 0;
    for (int i = 0; str[i] != '\0'; i++) {
        hash_value = (hash_value * 31 + str[i]) % HASH_SIZE;
    }
    return hash_value;
}

// Ajouter un symbole dans la table des symboles
void add_symbol(const char *name, int type, int is_const, void *value, int array_size) {
    int index = hash(name);
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
    if ((divisor.type == 0 && divisor.int_val == 0) || (divisor.type == 1 && divisor.real_val == 0.0)) {
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

    // Vérifier si le symbole existe déjà
    symbol *existing_symbol = find_symbol(name);
    if (existing_symbol != NULL) {
        printf("Erreur: Variable '%s' déjà déclarée.\n", name);
        return;
    }

    // Créer un nouveau symbole
    symbol *new_symbol = (symbol *)malloc(sizeof(symbol));
    new_symbol->name = strdup(name);
    new_symbol->type = type;
    new_symbol->is_const = is_const;
    new_symbol->array_size = array_size;
    new_symbol->next = NULL;

    if (type == NUM) {
        new_symbol->int_val = *((int *)value);
    } else if (type == REAL) {
        new_symbol->real_val = *((double *)value);
    } else {
        new_symbol->str_val = strdup((char *)value);
    }

    if (array_size > 0) {
        new_symbol->array_vals = (int *)malloc(sizeof(int) * array_size);
    } else {
        new_symbol->array_vals = NULL;
    }

    // Gestion des collisions par chaînage
    if (symbol_table[index] == NULL) {
        symbol_table[index] = new_symbol;
    } else {
        symbol *current = symbol_table[index];
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = new_symbol;
    }

    symbol_count++;
}

// Rechercher un symbole par nom dans la table des symboles
symbol *find_symbol(const char *name) {
    int index = hash(name);
    symbol *current = symbol_table[index];
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

// Afficher la table des symboles
void print_symbol_table() {
    for (int i = 0; i < HASH_SIZE; i++) {
        if (symbol_table[i] != NULL) {
            symbol *current = symbol_table[i];
            while (current != NULL) {
                printf("Nom: %s, Type: %d, ", current->name, current->type);
                if (current->type == NUM) {
                    printf("Valeur: %d\n", current->int_val);
                } else if (current->type == REAL) {
                    printf("Valeur: %f\n", current->real_val);
                } else {
                    printf("Valeur: %s\n", current->str_val);
                }
                current = current->next;
            }
        }
    }
}

// Libérer la mémoire utilisée par la table des symboles
void free_symbol_table() {
    for (int i = 0; i < HASH_SIZE; i++) {
        if (symbol_table[i] != NULL) {
            symbol *current = symbol_table[i];
            while (current != NULL) {
                symbol *next = current->next;
                free(current->name);
                if (current->type == TEXT) {
                    free(current->str_val);
                }
                if (current->array_vals != NULL) {
                    free(current->array_vals);
                }
                free(current);
                current = next;
            }
        }
    }
}
