%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

int yylex(void);
int yyerror(char *s);

// Enum for variable types
typedef enum {
    TYPE_INT,
    TYPE_STRING
} VarType;

// Structure to store symbol information
typedef struct Symbol {
    char* name;
    VarType type;
    union {
        int intValue;
        char* strValue;
    } value;
} Symbol;

// Symbol table
#define MAX_SYMBOLS 100
Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

// Helper functions
int findSymbolIndex(char* name);
void addIntSymbol(char* name, int value);
void addStringSymbol(char* name, char* value);
int getIntValue(char* name);
char* getStringValue(char* name);
VarType getSymbolType(char* name);

// String operation functions
char* stringConcat(char* str1, char* str2);
int stringLength(char* str);
char* stringUpper(char* str);
char* stringLower(char* str);
char* removeQuotes(char* str);

// Math operation functions
int powerFunc(int base, int exp);
int sqrtFunc(int n);

%}

%union {
    char* str;
    int num;
}

%left PLUS MINUS
%left TIMES DIVIDE

%token MYTYPE STRTYPE SHOW CONCAT LENGTH UPPER LOWER POWER SQRT
%token <str> IDENTIFIER STRING_LITERAL
%token <num> NUMBER
%token PLUS MINUS TIMES DIVIDE

%type <num> int_expression
%type <str> string_expression

%%

program:
    statements
    ;

statements:
    statements statement
    | statement
    ;

statement:
    MYTYPE IDENTIFIER ';'  { 
        addIntSymbol($2, 0);
        printf("Declared integer variable: %s\n", $2); 
    }
    | STRTYPE IDENTIFIER ';'  { 
        addStringSymbol($2, "");
        printf("Declared string variable: %s\n", $2); 
    }
    | SHOW '(' IDENTIFIER ')' ';'  { 
        int idx = findSymbolIndex($3);
        if (idx != -1) {
            if (symbolTable[idx].type == TYPE_INT) {
                printf("Value of %s: %d\n", $3, symbolTable[idx].value.intValue);
            } else {
                printf("Value of %s: %s\n", $3, symbolTable[idx].value.strValue);
            }
        }
    }
    | SHOW '(' string_expression ')' ';'  {
        printf("String output: %s\n", $3);
    }
    | SHOW '(' int_expression ')' ';'  {
        printf("Integer output: %d\n", $3);
    }
    | IDENTIFIER '=' int_expression ';'  { 
        addIntSymbol($1, $3);
        printf("Assigned %d to %s\n", $3, $1); 
    }
    | IDENTIFIER '=' string_expression ';'  { 
        addStringSymbol($1, $3);
        printf("Assigned \"%s\" to %s\n", $3, $1); 
    }
    | int_expression ';'  { 
        printf("Expression result: %d\n", $1); 
    }
    ;

int_expression:
    int_expression PLUS int_expression  { $$ = $1 + $3; }
    | int_expression MINUS int_expression  { $$ = $1 - $3; }
    | int_expression TIMES int_expression  { $$ = $1 * $3; }
    | int_expression DIVIDE int_expression  { 
        if ($3 == 0) {
            yyerror("Division by zero");
            $$ = 0;
        } else {
            $$ = $1 / $3; 
        }
    }
    | NUMBER  { $$ = $1; }
    | IDENTIFIER  { 
        if (getSymbolType($1) == TYPE_INT) {
            $$ = getIntValue($1);
        } else {
            yyerror("Type mismatch: expected integer");
            $$ = 0;
        }
    }
    | LENGTH '(' string_expression ')'  {
        $$ = stringLength($3);
    }
    | POWER '(' int_expression ',' int_expression ')'  {
        $$ = powerFunc($3, $5);
    }
    | SQRT '(' int_expression ')'  {
        $$ = sqrtFunc($3);
    }
    | '(' int_expression ')'  { $$ = $2; }
    ;

string_expression:
    STRING_LITERAL  { 
        $$ = removeQuotes($1);
    }
    | IDENTIFIER  {
        if (getSymbolType($1) == TYPE_STRING) {
            $$ = getStringValue($1);
        } else {
            yyerror("Type mismatch: expected string");
            $$ = "";
        }
    }
    | CONCAT '(' string_expression ',' string_expression ')'  {
        $$ = stringConcat($3, $5);
    }
    | UPPER '(' string_expression ')'  {
        $$ = stringUpper($3);
    }
    | LOWER '(' string_expression ')'  {
        $$ = stringLower($3);
    }
    ;

%%

int yyerror(char *s) {
    printf("Error: %s\n", s);
    return 0;
}

int main() {
    printf("=== Simple Compiler: Math & String Operations ===\n");
    printf("Enter your code (Ctrl+D to end):\n\n");
    yyparse();
    printf("\n=== Symbol Table ===\n");
    printf("%-15s %-10s %s\n", "Name", "Type", "Value");
    printf("---------------------------------------------\n");
    for (int i = 0; i < symbolCount; i++) {
        printf("%-15s %-10s ", symbolTable[i].name, 
               symbolTable[i].type == TYPE_INT ? "int" : "string");
        if (symbolTable[i].type == TYPE_INT) {
            printf("%d\n", symbolTable[i].value.intValue);
        } else {
            printf("\"%s\"\n", symbolTable[i].value.strValue);
        }
    }
    return 0;
}

// Find symbol in table
int findSymbolIndex(char* name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

// Add integer symbol
void addIntSymbol(char* name, int value) {
    int index = findSymbolIndex(name);
    if (index == -1) {
        if (symbolCount < MAX_SYMBOLS) {
            symbolTable[symbolCount].name = strdup(name);
            symbolTable[symbolCount].type = TYPE_INT;
            symbolTable[symbolCount].value.intValue = value;
            symbolCount++;
        } else {
            printf("Symbol table full!\n");
        }
    } else {
        symbolTable[index].value.intValue = value;
    }
}

// Add string symbol
void addStringSymbol(char* name, char* value) {
    int index = findSymbolIndex(name);
    if (index == -1) {
        if (symbolCount < MAX_SYMBOLS) {
            symbolTable[symbolCount].name = strdup(name);
            symbolTable[symbolCount].type = TYPE_STRING;
            symbolTable[symbolCount].value.strValue = strdup(value);
            symbolCount++;
        } else {
            printf("Symbol table full!\n");
        }
    } else {
        free(symbolTable[index].value.strValue);
        symbolTable[index].value.strValue = strdup(value);
    }
}

// Get integer value
int getIntValue(char* name) {
    int index = findSymbolIndex(name);
    if (index != -1 && symbolTable[index].type == TYPE_INT) {
        return symbolTable[index].value.intValue;
    } else {
        printf("Error: Integer variable %s not found!\n", name);
        return 0;
    }
}

// Get string value
char* getStringValue(char* name) {
    int index = findSymbolIndex(name);
    if (index != -1 && symbolTable[index].type == TYPE_STRING) {
        return symbolTable[index].value.strValue;
    } else {
        printf("Error: String variable %s not found!\n", name);
        return "";
    }
}

// Get symbol type
VarType getSymbolType(char* name) {
    int index = findSymbolIndex(name);
    if (index != -1) {
        return symbolTable[index].type;
    }
    return TYPE_INT;
}

// String concatenation
char* stringConcat(char* str1, char* str2) {
    char* result = malloc(strlen(str1) + strlen(str2) + 1);
    strcpy(result, str1);
    strcat(result, str2);
    return result;
}

// String length
int stringLength(char* str) {
    return strlen(str);
}

// Convert to uppercase
char* stringUpper(char* str) {
    char* result = strdup(str);
    for (int i = 0; result[i]; i++) {
        result[i] = toupper(result[i]);
    }
    return result;
}

// Convert to lowercase
char* stringLower(char* str) {
    char* result = strdup(str);
    for (int i = 0; result[i]; i++) {
        result[i] = tolower(result[i]);
    }
    return result;
}

// Remove quotes from string literal
char* removeQuotes(char* str) {
    int len = strlen(str);
    if (len >= 2 && str[0] == '"' && str[len-1] == '"') {
        char* result = malloc(len - 1);
        strncpy(result, str + 1, len - 2);
        result[len - 2] = '\0';
        return result;
    }
    return strdup(str);
}

// Power function
int powerFunc(int base, int exp) {
    if (exp < 0) {
        printf("Warning: Negative exponent, returning 0\n");
        return 0;
    }
    int result = 1;
    for (int i = 0; i < exp; i++) {
        result *= base;
    }
    return result;
}

// Square root (integer)
int sqrtFunc(int n) {
    if (n < 0) {
        printf("Warning: Square root of negative number, returning 0\n");
        return 0;
    }
    return (int)sqrt(n);
}

