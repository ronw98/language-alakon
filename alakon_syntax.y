/*So this is a bison file and I have no idea how it works
I'll try my best to comment it so that it is understandable*/

%{
    #include "alakon.h"
    #include <glib.h>

    #define ANSI_COLOR_RED     "\x1b[34;1m"
    #define ANSI_COLOR_GREEN   "\x1b[31;1m"
    #define ANSI_COLOR_YELLOW  "\x1b[33;1m"
    #define ANSI_COLOR_BLUE    "\x1b[34;1m"
    #define ANSI_COLOR_MAGENTA "\x1b[35;1m"
    #define ANSI_COLOR_CYAN    "\x1b[36;1m"
    #define ANSI_COLOR_RESET   "\x1b[0m"


    bool error_syntax = false;
    extern unsigned int lineno;
    extern bool error_lexicon;
    bool error_semantic = false;
    /*Hash table that references all the declared and initialized variables*/
    GHashTable* variable_table;

    /*Structure that will allow us to determine if a variable is correctly used (an int isn't a string you see)*/
    typedef struct Variable Variable;

    struct Variable{
        char* type;
        void* data;
    };
    void variableAffectHandling(GHashTable * hTable, char* expectedType,char* varName,void* data);
    void variableDeclarHandling(GHashTable* hTable,char* type,char* varName);

    //Pretty self explained but this is used to declaring variables
    void variableDeclarHandling(GHashTable* hTable,char* type,char* varName)
    {
        printf("The variable %s of type %s has been declared\n",varName,type);
        /*Creation of the variable*/
        Variable * var = (Variable*) malloc(sizeof(Variable));
        if(var!=NULL){
            /*Affectation of its type*/
            var->type = strdup(type);
            var->data = NULL;
            /*Insertion into the hash table*/
            if(!g_hash_table_insert(variable_table,strdup(varName),var)){
                fprintf(stderr,ANSI_COLOR_RED "PROBLEM DURING VARIABLE CREATION\n" ANSI_COLOR_RESET);
                exit(-1);
            }
        }else{
            fprintf(stderr,ANSI_COLOR_RED "PROBLEM MALLOC VARIABLE\n" ANSI_COLOR_RESET);
            exit(-1);
        }
    }

    //Pretty self explained but this is used to affecting variables
    void variableAffectHandling(GHashTable * hTable, char* expectedType,char* varName,void* data)
    {
        /*Get the variable from the hash table*/
        Variable* var = g_hash_table_lookup(hTable,varName);
        /*If it doesn't exist, this is a problem*/
        if(var != NULL){
            /*if it is the wrong type, it also is*/
            if(strcmp(var->type,expectedType)==0){
                var->data = data;
            }else{
                printf(ANSI_COLOR_RED "ERROR ON TYPE LINE %d. EXPECTED %s GOT %s\n" ANSI_COLOR_RESET,lineno,expectedType,var->type);
                error_semantic=true;
            }
        }else{
            printf(ANSI_COLOR_RED "ERROR! VARIABLE NOT DECLARED LINE %d\n" ANSI_COLOR_RESET,lineno);
            error_semantic=true;
        }
    }

%}

/*The union is used to type our tokens and expressions. I have no idea what any of this means*/
%union {
    long number;
    char* text;
}

/*There go the operands. From the least prioritary to the most*/
%left   TOK_PLUS    TOK_MINUS   /*+ and -*/
%left   TOK_MUL     TOK_DIV     /* * and / */
%left   TOK_OR      TOK_AND     /* and and or*/
%left   TOK_NOPE                /* nope */
%right  TOK_LEFTP   TOK_RIGHTP  /* ( and ) */

/*List of all the expressions used by the language.
And we added a 'variable' expression because we need the variable name to be stored*/
%type<text>     code
%type<text>     instruction
%type<text>     declaration
%type<text>     type
%type<text>     display
%type<text>     affectation
%type<text>     variable
%type<text>     expression
%type<text>     arithmetic_expression
%type<text>     boolean_expression
%type<text>     addition
%type<text>     substraction
%type<text>     multiplication
%type<text>     division

/*The token we use*/
%token<number>    TOK_NUM         /*Numbers*/
%token          TOK_DISP        /* print */
%token          TOK_AFFECT      /* = */
%token          TOK_ENDINSTR    /* ; */
%token          TOK_TRUE        /* true */
%token          TOK_FALSE       /* false */
%token          TOK_MAYBE       /* maybe */
%token          TOK_INT         /* int */
%token          TOK_BOOL        /* bool */
%token          TOK_RACC        /* raccoon */
%token<text>    TOK_VAR         /* variable */

%%

/*Let's define all the expressions we use in our language. This is basically a traduction of the .bnf file*/
code:                   %empty{}
                        |
                        code instruction{}
                        |
                        code error{
                            fprintf(stderr, "You did wrong! But I don't know what you did wrong. But it is not good! It is bad!\nAnd it is line %d\n",lineno);
                            error_syntax = true;
                        };
instruction:            affectation{
                            printf("Hey I recognized an affectation line %d! Proud of me daddy?\n",lineno);
                        }
                        |
                        declaration{
                            printf("Wow! I wasn't expecting this instruction line %d to be a declaration but I guess I was wrong\n",lineno);
                        }
                        |
                        display{
                            printf("This is a nice instruction to display things on line %d\n",lineno);
                        };
variable:               TOK_VAR{
                            /*$1 is the variable name returned by the flex analysis*/
                            printf(ANSI_COLOR_YELLOW "\t\tVariable %s\n"ANSI_COLOR_RESET,$1);
                            /* Then we give the bison variable $$ the value of $1 (using a copy)*/
                            $$ = strdup($1);
                        };
type:                   TOK_INT{
                            printf(ANSI_COLOR_YELLOW "\t\tInteger\n"ANSI_COLOR_RESET);
                            $$=strdup("int");
                        }
                        |
                        TOK_BOOL{
                            printf(ANSI_COLOR_YELLOW "\t\tBool\n"ANSI_COLOR_RESET);
                            $$=strdup("bool");
                        }
                        |
                        TOK_RACC{
                            printf("\t\tOh look! A raccoon!\n");
                            $$=strdup("raccoon");
                        };
declaration:            type variable TOK_ENDINSTR{
                            variableDeclarHandling(variable_table,$1,$2);
                        }
                        |
                        type variable TOK_AFFECT expression TOK_ENDINSTR{
                            printf("A variable has been declared and initialized\n");
                            /*Creation of the variable*/
                            Variable * var = (Variable*) malloc(sizeof(Variable));
                            if(var!=NULL){
                                /*Affectation of its type*/
                                var->type = strdup($1);
                                (var->data) = strdup($4);
                                /*Insertion into the hash table*/
                                if(!g_hash_table_insert(variable_table,strdup($2),var)){
                                    fprintf(stderr,ANSI_COLOR_RED "PROBLEM DURING VARIABLE CREATION\n" ANSI_COLOR_RESET);
                                    exit(-1);
                                }
                            }else{
                                fprintf(stderr,ANSI_COLOR_RED "PROBLEM MALLOC VARIABLE\n" ANSI_COLOR_RESET);
                                exit(-1);
                            }
                        };
affectation:            variable TOK_AFFECT arithmetic_expression TOK_ENDINSTR{
                            variableAffectHandling(variable_table, "int",$1,$3);
                        }
                        |
                        variable TOK_AFFECT boolean_expression TOK_ENDINSTR{
                            variableAffectHandling(variable_table, "int",$1,$3);
                        };
display:                TOK_DISP TOK_LEFTP expression TOK_RIGHTP TOK_ENDINSTR{
                            printf("Let's display this: %s\n",$3);
                        };
expression:             arithmetic_expression{
                            printf("This expression is just maths\n");
                        }
                        |
                        boolean_expression{
                            printf("This expression is logic\n");
                        };
arithmetic_expression:  TOK_NUM{
                            printf(ANSI_COLOR_YELLOW "\t\tNumber %ld\n" ANSI_COLOR_RESET,$1);
                            int length=snprintf(NULL,0,"%ld",$1);
                            char* str=malloc(length+1);
                            snprintf(str,length+1,"%ld",$1);
                            $$=strdup(str);
                            free(str);
                        }
                        |
                        variable{
                            /* We get the variable */
                            Variable* var=g_hash_table_lookup(variable_table,$1);
                            /* We verify its existence */
                            if(var!=NULL){
                                /* And its type */
                                if(strcmp(var->type,"int")==0){
                                    $$=strdup($1);
                                }else{
                                    fprintf(stderr,ANSI_COLOR_RED "ERROR ON LINE %d. EXPECTED int GOT %s\n" ANSI_COLOR_RESET,lineno,var->type);
                                    error_semantic=true;
                                }
                            /* If it doesn't exist, it is not good */
                            }else{
                                    fprintf(stderr,ANSI_COLOR_RED "ERROR ON LINE %d, VARIABLE %s NEVER DECLARED!\n" ANSI_COLOR_RESET,lineno,$1);
                                    error_semantic=true;
                            }
                        }
                        |
                        addition{}
                        |
                        substraction{}
                        |
                        multiplication{}
                        |
                        division{}
                        |
                        TOK_LEFTP arithmetic_expression TOK_RIGHTP{
                            $$=strcat(strdup("("),strcat(strdup($2),strdup("(")));
                        };
boolean_expression:     TOK_TRUE{
                            $$=strdup("true");
                        }
                        |
                        TOK_FALSE{
                            $$=strdup("false");
                        }
                        |
                        TOK_MAYBE{
                            $$=strdup("maybe");
                        }
                        |
                        variable{
                            /* We get the variable */
                            Variable* var=g_hash_table_lookup(variable_table,$1);
                            /* We verify its existence */
                            if(var!=NULL){
                                /* And its type */
                                if(strcmp(var->type,"bool")==0){
                                    $$=strdup($1);
                                }else{
                                    fprintf(stderr,ANSI_COLOR_RED "ERROR ON LINE %d. EXPECTED bool GOT %s\n" ANSI_COLOR_RESET,lineno,var->type);
                                    error_semantic=true;
                                }
                            /* If it doesn't exist, it is not good */
                            }else{
                                    fprintf(stderr,ANSI_COLOR_RED "ERROR ON LINE %d, VARIABLE %s NEVER DECLARED!\n" ANSI_COLOR_RESET,lineno,$1);
                                    error_semantic=true;
                            }
                        }
                        |
                        TOK_NOPE boolean_expression{
                            printf("This is a nope\n");
                            $$=strcat(strdup("nope "),strndup($2,sizeof(char)*strlen($2)));
                        }
                        |
                        boolean_expression TOK_OR boolean_expression{
                            $$=strcat(strdup($1),strcat(strdup(" or "),strdup($3)));
                        }
                        |
                        boolean_expression TOK_AND boolean_expression{
                            $$=strcat(strdup($1),strcat(strdup(" and "), strdup($3)));
                        }
                        |
                        TOK_LEFTP boolean_expression TOK_RIGHTP{
                            $$=strcat(strdup("("),strcat(strdup($2),strdup(")")));
                        };
addition:               arithmetic_expression TOK_PLUS arithmetic_expression{$$=strcat(strdup($1),strcat(strdup("+"),strdup($3)));}
substraction:           arithmetic_expression TOK_MINUS arithmetic_expression{$$=strcat(strdup($1),strcat(strdup("-"),strdup($3)));}
multiplication:         arithmetic_expression TOK_MUL arithmetic_expression{$$=strcat(strdup($1),strcat(strdup("*"),strdup($3)));}
division:               arithmetic_expression TOK_DIV arithmetic_expression{$$=strcat(strdup($1),strcat(strdup("/"),strdup($3)));}

%%

/*In the main function, we call yyparse() generated by bison, that will call yylex from our lexicon analyser*/
int main(void){
    variable_table = g_hash_table_new_full(g_str_hash,g_str_equal,free,free);
    printf(ANSI_COLOR_CYAN"Begining syntax analysis\n"ANSI_COLOR_RESET);
    yyparse();
    printf(ANSI_COLOR_CYAN"End of the analysis\n"ANSI_COLOR_RESET);
    printf(ANSI_COLOR_CYAN"Results:\n"ANSI_COLOR_RESET);
    if(error_lexicon){
        printf(ANSI_COLOR_RED "You idiot wrote unknown words! Why would you do that?\n" ANSI_COLOR_RESET);
    }else{
        printf(ANSI_COLOR_GREEN "Congrats! Your pityful mind managed to write down some actual words\n" ANSI_COLOR_RESET);
    }
    if(error_syntax){
        printf(ANSI_COLOR_RED "Why make proper senteces when you can not\n" ANSI_COLOR_RESET);
    }else{
        printf(ANSI_COLOR_GREEN "Nice lines here bro\n" ANSI_COLOR_RESET);
    }
    return EXIT_SUCCESS;
}

void yyerror(char *s){
    fprintf(stderr,ANSI_COLOR_RED "Unknown syntax on line %d.Don't try to be smart and go clean %s up\n" ANSI_COLOR_RESET,lineno,s);
}
