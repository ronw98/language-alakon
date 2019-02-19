#ifndef ALAKON_H
#define  ALAKON_H

#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <glib.h>
#include "alakon_syntax.tab.h"

int yylex(void);
void yyerror(char *);

extern unsigned int lineno;
extern bool error_lexicon;

//Stream to generated file in c
FILE* outFile;

//Methods used to generate the C code;
extern void code_start(void);
extern void code_generation(GNode * ast);
extern void code_end(void);

//Macros for the Abstract Syntax Tree (AST)
#define EMPTY_CODE 0
#define SEQUENCE 1
#define VARIABLE 2
#define AFFECTATION 3
#define DECLARATION 6
#define DECLARAFFECT 7
#define PRINTI 9
#define PRINTB 10
#define INTEGERT 11
#define BOOLEANT 23
#define NUM 25
#define RACCOON 24
#define ADDITION 12
#define SUBSTRACTION 13
#define MULTIPLICATION 14
#define DIVISION 15
#define AND 16
#define OR 17
#define NOPE 18
#define TRU 19
#define FALS 20
#define MAYBE 21
#define PAR_EXPR 22
#define PRINTVARI 26


//Functions to handle variables in alakon_syntax.y
GNode* variableAffectHandling(GHashTable * hTable, char* expectedType,GNode* varName,GNode* data);
GNode* variableDeclarHandling(GHashTable* hTable,GNode* type,GNode* varName);

char* fromIntToGa(int num);
int fromGaToDec(char * num);
int power(int a, int b);

#endif
