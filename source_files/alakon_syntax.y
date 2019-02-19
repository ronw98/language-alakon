/*So this is a bison file and I have no idea how it works
I'll try my best to comment it so that it is understandable*/

%{
    #include "alakon.h"
    #include <regex.h>

    #define ANSI_COLOR_RED     "\x1b[34;1m"
    #define ANSI_COLOR_GREEN   "\x1b[31;1m"
    #define ANSI_COLOR_YELLOW  "\x1b[33;1m"
    #define ANSI_COLOR_BLUE    "\x1b[34;1m"
    #define ANSI_COLOR_MAGENTA "\x1b[35;1m"
    #define ANSI_COLOR_CYAN    "\x1b[36;1m"
    #define ANSI_COLOR_ORANGE  "\x1b[32;1m"
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
        GNode* data;
    };

    //Pretty self explained but this is used to declaring variables
    GNode* variableDeclarHandling(GHashTable* hTable,GNode* type,GNode* varName)
    {
        printf("A variable of type %s has been declared\n",(char*)g_node_nth_child(type,0)->data);
        /*Checking the variable doesn't already exist*/
        GNode* res;
        Variable* var=g_hash_table_lookup(hTable,(char*)g_node_nth_child(varName,0)->data);
        if(var == NULL){
            /*Creation of the variable*/
            var = (Variable*) malloc(sizeof(Variable));
            if(var!=NULL){
                /*Affectation of its type*/
                var->type = strdup((char*)g_node_nth_child(type,0)->data);
                var->data = NULL;
                /*Insertion into the hash table*/
                if(g_hash_table_insert(hTable,g_node_nth_child(varName,0)->data,var)){
                    if(strcmp(var->type,"raccoon")!=0){
                        res=g_node_new((gpointer) DECLARATION);
                        g_node_append(res,type);
                        g_node_append(res,varName);
                    }else{
                        res=g_node_new((gpointer) RACCOON);
                        g_node_append(res,varName);
                    }

                }else{
                    fprintf(stderr,ANSI_COLOR_RED "PROBLEM DURING VARIABLE CREATION\n" ANSI_COLOR_RESET);
                    exit(-1);
                }
            }else{
                fprintf(stderr,ANSI_COLOR_RED "PROBLEM MALLOC VARIABLE\n" ANSI_COLOR_RESET);
                exit(-1);
            }
        }else{
            fprintf(stderr,ANSI_COLOR_RED "Varibale already exists!\n" ANSI_COLOR_RESET);
            error_semantic=true;
        }
        return res;
    }

    //Pretty self explained but this is used to affecting variables
    GNode * variableAffectHandling(GHashTable * hTable, char* expectedType,GNode* varName,GNode* data)
    {
        /*Get the variable from the hash table*/
        Variable* var=g_hash_table_lookup(hTable,(char*)g_node_nth_child(varName,0)->data);
        GNode * res;
        /*If it doesn't exist, this is a problem*/
        if(var != NULL){
            res= g_node_new((gpointer) AFFECTATION);
            g_node_append(res,varName);
            g_node_append(res,data);
        }else{
            printf(ANSI_COLOR_RED "ERROR! VARIABLE NOT DECLARED LINE %d\n" ANSI_COLOR_RESET,lineno);
            error_semantic=true;Variable* var = g_hash_table_lookup(hTable,varName);
        }
        return res;
    }

%}

/*The union is used to type our tokens and expressions. I have no idea what any of this means*/
%union {
    long number;
    char* text;
    GNode* node;
}

/*There go the operands. From the least prioritary to the most*/
%left   TOK_PLUS    TOK_MINUS   /*+ and -*/
%left   TOK_MUL     TOK_DIV     /* * and / */
%left   TOK_OR      TOK_AND     TOK_NOPE      /* and, or and nope*/
%right  TOK_LEFTP   TOK_RIGHTP  /* ( and ) */

/*List of all the expressions used by the language.
And we added a 'variable' expression because we need the variable name to be stored*/
%type<node>     code
%type<node>     instruction
%type<node>     declaration
%type<node>     type
%type<node>     display
%type<node>     affectation
%type<node>     variable
%type<node>     arithmetic_expression
%type<node>     boolean_expression
%type<node>     addition
%type<node>     substraction
%type<node>     multiplication
%type<node>     division

/*The token we use*/
%token<number>    TOK_NUM         /*Numbers*/
%token          TOK_DISP        /* print */
%token          TOK_AFFECT      /* = */
%token          TOK_ENDINSTR    /* ; */
%token          TOK_TRU        /* true */
%token          TOK_FALS       /* false */
%token          TOK_MAYBE       /* maybe */
%token          TOK_INT         /* int */
%token          TOK_BOOL        /* bool */
%token          TOK_RACC        /* raccoon */
%token<text>    TOK_VAR         /* variable */

%%

/*Let's define all the expressions we use in our language. This is basically a traduction of the .bnf file*/
start:                  code{
                            code_generation($1);
                            g_node_destroy($1);
                        }
code:                   %empty{$$=g_node_new((gpointer) EMPTY_CODE);}
                        |
                        code instruction{
                            printf(ANSI_COLOR_ORANGE "Processing instruction line %d\n" ANSI_COLOR_RESET,lineno);
                            /*From what I understand to this, we create a new node in the tree.
                            This node has the ID of a sequence. Then we add the code and instruction nodes as children of this node*/
                            $$=g_node_new((gpointer)SEQUENCE);
                            g_node_append($$,$1);
                            g_node_append($$,$2);

                            printf(ANSI_COLOR_ORANGE "Instruction processing finished line %d\n"ANSI_COLOR_RESET,lineno);
                        }
                        |
                        code error{
                            fprintf(stderr,ANSI_COLOR_RED "You did wrong! But I don't know what you did wrong. But it is not good! It is bad!\nAnd it is line %d\n"ANSI_COLOR_RESET,lineno);
                            error_syntax = true;
                        };
instruction:            affectation{
                            printf("Hey I recognized an affectation line %d! Proud of me daddy?\n",lineno);
                            $$=$1;
                        }
                        |
                        declaration{
                            printf("Wow! I wasn't expecting this instruction line %d to be a declaration but I guess I was wrong\n",lineno);
                            $$=$1;
                        }
                        |
                        display{
                            printf("This is a nice instruction to display things on line %d\n",lineno);
                            $$=$1;
                        };
variable:               TOK_VAR{
                            /*$1 is the variable name returned by the flex analysis*/
                            printf(ANSI_COLOR_YELLOW "\t\tVariable %s\n"ANSI_COLOR_RESET,$1);
                            /*We create a variable node which has the variable as data. It is a leaf*/
                            $$ = g_node_new((gpointer) VARIABLE);
                            g_node_append_data($$,strdup($1));
                        };
type:                   TOK_INT{
                            printf(ANSI_COLOR_YELLOW "\t\tInteger\n"ANSI_COLOR_RESET);
                            $$=g_node_new((gpointer) INTEGERT);
                            g_node_append_data($$,"int");
                        }
                        |
                        TOK_BOOL{
                            printf(ANSI_COLOR_YELLOW "\t\tBool\n"ANSI_COLOR_RESET);
                            $$=g_node_new((gpointer) BOOLEANT);
                            g_node_append_data($$,"bool");
                        }
                        |
                        TOK_RACC{
                            printf("\t\tOh look! A raccoon!\n");
                            $$=g_node_new((gpointer) RACCOON);
                            g_node_append_data($$,"raccoon");
                        };
declaration:            type variable TOK_ENDINSTR{
                            $$ = variableDeclarHandling(variable_table,$1,$2);
                            //printf("The variable %s of type %s has been declared\n",varName,type);
                            /*Checking the variable doesn't already exist*/
                            /*Variable* var=g_hash_table_lookup(variable_table,(char*)g_node_nth_child($2,0)->data);
                            if(var == NULL){*/
                                /*Creation of the variable*/
                                /*var = (Variable*) malloc(sizeof(Variable));
                                if(var!=NULL){*/
                                    /*Affectation of its type*/
                                    //var->type = strdup($1);
                                    //var->data = NULL;
                                    /*Insertion into the hash table*/
                                    /*if(g_hash_table_insert(variable_table,g_node_nth_child($2,0)->data,var)){
                                        $$=g_node_new((gpointer) DECLARATION);
                                        g_node_append($$,$2);
                                    }else{
                                        fprintf(stderr,ANSI_COLOR_RED "PROBLEM DURING VARIABLE CREATION\n" ANSI_COLOR_RESET);
                                        exit(-1);
                                    }
                                }else{
                                    fprintf(stderr,ANSI_COLOR_RED "PROBLEM MALLOC VARIABLE\n" ANSI_COLOR_RESET);
                                    exit(-1);
                                }
                            }else{
                                fprintf(stderr,ANSI_COLOR_RED "Varibale already exists!\n" ANSI_COLOR_RESET);
                            }*/
                        }
                        |
                        type variable TOK_AFFECT boolean_expression TOK_ENDINSTR{
                            printf("A variable has been declared and initialized as bool\n");
                            Variable* var=g_hash_table_lookup(variable_table,(char*)g_node_nth_child($2,0)->data);
                            if(var == NULL){
                                /*Creation of the variable*/
                                var = (Variable*) malloc(sizeof(Variable));
                                if(var!=NULL){
                                    /*Affectation of its type*/
                                    if(strcmp(g_node_nth_child($1,0)->data,"bool")==0){
                                        var->type = "bool";
                                        (var->data) = $4;
                                        /*Insertion into the hash table*/
                                        if(g_hash_table_insert(variable_table,g_node_nth_child($2,0)->data,var)){
                                            $$=g_node_new((gpointer)DECLARAFFECT);
                                            g_node_append($$,$1);
                                            g_node_append($$,$2);
                                            g_node_append($$,$4);
                                        }else{
                                            fprintf(stderr,ANSI_COLOR_RED "PROBLEM DURING VARIABLE CREATION\n" ANSI_COLOR_RESET);
                                            exit(-1);
                                        }
                                    }else{
                                        printf(ANSI_COLOR_RED "WRONG TYPE FOR VARIABLE LINE %d\n" ANSI_COLOR_RESET,lineno);
                                    }
                                }else{
                                    fprintf(stderr,ANSI_COLOR_RED "PROBLEM MALLOC VARIABLE\n" ANSI_COLOR_RESET);
                                    exit(-1);
                                }
                            }else{
                                fprintf(stderr,ANSI_COLOR_RED "Varibale already exists!\n" ANSI_COLOR_RESET);
                                error_semantic=true;
                            }
                        }
                        |
                        type variable TOK_AFFECT arithmetic_expression TOK_ENDINSTR{
                            printf("A variable has been declared and initialized as int\n");
                            Variable* var=g_hash_table_lookup(variable_table,(char*)g_node_nth_child($2,0)->data);
                            if(var == NULL){
                                /*Creation of the variable*/
                                var = (Variable*) malloc(sizeof(Variable));
                                if(var!=NULL){
                                    /*Affectation of its type*/
                                    if(strcmp(g_node_nth_child($1,0)->data,"int")==0){
                                        var->type = "int";
                                        (var->data) = $4;
                                        /*Insertion into the hash table*/
                                        if(g_hash_table_insert(variable_table,g_node_nth_child($2,0)->data,var)){
                                            $$=g_node_new((gpointer)DECLARAFFECT);
                                            g_node_append($$,$1);
                                            g_node_append($$,$2);
                                            g_node_append($$,$4);
                                        }else{
                                            fprintf(stderr,ANSI_COLOR_RED "PROBLEM DURING VARIABLE CREATION\n" ANSI_COLOR_RESET);
                                            exit(-1);
                                        }
                                    }else{
                                        printf(ANSI_COLOR_RED "WRONG TYPE FOR VARIABLE LINE %d\n" ANSI_COLOR_RESET,lineno);
                                        error_semantic = true;
                                    }
                                }else{
                                    fprintf(stderr,ANSI_COLOR_RED "PROBLEM MALLOC VARIABLE\n" ANSI_COLOR_RESET);
                                    exit(-1);
                                }
                            }else{
                                fprintf(stderr,ANSI_COLOR_RED "Varibale already exists!\n" ANSI_COLOR_RESET);
                            }
                        };
affectation:            variable TOK_AFFECT arithmetic_expression TOK_ENDINSTR{
                            $$=variableAffectHandling(variable_table, "int",$1,$3);
                        }
                        |
                        variable TOK_AFFECT boolean_expression TOK_ENDINSTR{
                            $$=variableAffectHandling(variable_table, "bool",$1,$3);
                        };
display:                TOK_DISP TOK_LEFTP variable TOK_RIGHTP TOK_ENDINSTR{
                            Variable* var =g_hash_table_lookup(variable_table,(char*) g_node_nth_child($3,0)->data);
                            if(strcmp("int",var->type)==0){
                                printf("Let's display this arithmetic thing: %s\n",(char*)$3);
                                $$ = g_node_new((gpointer) PRINTVARI);
                                g_node_append($$,$3);
                            }else{
                                printf("Let's display this boolean thing: %s\n",(char*)$3);
                                $$ = g_node_new((gpointer) PRINTB);
                                g_node_append($$,$3);
                            }
                        }
                        |
                        TOK_DISP TOK_LEFTP arithmetic_expression TOK_RIGHTP TOK_ENDINSTR{
                            printf("Let's display this arithmetic thing: %s\n",(char*)$3);
                            $$ = g_node_new((gpointer) PRINTI);
                            g_node_append($$,$3);
                        }
                        |
                        TOK_DISP TOK_LEFTP boolean_expression TOK_RIGHTP TOK_ENDINSTR{
                            printf("Let's display this boolean thing: %s\n",(char*)$3);
                            $$ = g_node_new((gpointer) PRINTB);
                            g_node_append($$,$3);
                        };
arithmetic_expression:  TOK_NUM{
                            printf(ANSI_COLOR_YELLOW "\t\tNumber %ld\n" ANSI_COLOR_RESET,$1);
                            int length=snprintf(NULL,0,"%ld",$1);
                            char* str=malloc(length+1);
                            snprintf(str,length+1,"%ld",$1);
                            $$=g_node_new((gpointer) NUM);
                            g_node_append_data($$,strdup(str));
                            free(str);
                        }
                        |
                        variable{
                            /* We get the variable */
                            Variable* var=g_hash_table_lookup(variable_table,(char*)g_node_nth_child($1,0)->data);
                            /* We verify its existence */
                            if(var!=NULL){
                                /* And its type */
                                if(strcmp(var->type,"int")==0){
                                    $$=$1;
                                }else{
                                    fprintf(stderr,ANSI_COLOR_RED "ERROR ON LINE %d. EXPECTED int GOT %s\n" ANSI_COLOR_RESET,lineno,var->type);
                                    error_semantic=true;
                                }
                            /* If it doesn't exist, it is not good */
                            }else{
                                    fprintf(stderr,ANSI_COLOR_RED "ERROR ON LINE %d, VARIABLE %s NEVER DECLARED!\n" ANSI_COLOR_RESET,lineno,(char*)$1);
                                    error_semantic=true;
                            }
                        }
                        |
                        addition{
                            $$=$1;
                        }
                        |
                        substraction{
                            $$=$1;
                        }
                        |
                        multiplication{
                            $$=$1;
                        }
                        |
                        division{
                            $$=$1;
                        }
                        |
                        TOK_LEFTP arithmetic_expression TOK_RIGHTP{
                            $$=g_node_new((gpointer)PAR_EXPR);
                            g_node_append($$,$2);
                        };
boolean_expression:     TOK_TRU{
                            $$=g_node_new((gpointer)TRU);
                        }
                        |
                        TOK_FALS{
                            $$=g_node_new((gpointer)FALS);
                        }
                        |
                        TOK_MAYBE{
                            $$=g_node_new((gpointer)MAYBE);
                        }
                        |
                        variable{
                            /* We get the variable */
                            Variable* var=g_hash_table_lookup(variable_table,g_node_nth_child($1,0)->data);
                            /* We verify its existence */
                            if(var!=NULL){
                                /* And its type */
                                if(strcmp(var->type,"bool")==0){
                                    $$=$1;
                                    printf("\nVariable treated\n");
                                }else{
                                    fprintf(stderr,ANSI_COLOR_RED "ERROR ON LINE %d. EXPECTED bool GOT %s\n" ANSI_COLOR_RESET,lineno,var->type);
                                    error_semantic=true;
                                }
                            /* If it doesn't exist, it is not good */
                            }else{
                                    fprintf(stderr,ANSI_COLOR_RED "ERROR ON LINE %d, VARIABLE %s NEVER DECLARED!\n" ANSI_COLOR_RESET,lineno,(char*)g_node_nth_child($1,0)->data);
                                    error_semantic=true;
                            }
                        }
                        |
                        TOK_NOPE boolean_expression{
                            printf("This is a nope\n");
                            $$=g_node_new((gpointer) NOPE);
                            g_node_append($$,$2);
                        }
                        |
                        boolean_expression TOK_OR boolean_expression{
                            $$=g_node_new((gpointer) OR);
                            g_node_append($$,$1);
                            g_node_append($$,$3);
                        }
                        |
                        boolean_expression TOK_AND boolean_expression{
                            $$=g_node_new((gpointer) AND);
                            g_node_append($$,$1);
                            g_node_append($$,$3);
                        }
                        |
                        TOK_LEFTP boolean_expression TOK_RIGHTP{
                            $$=g_node_new((gpointer) PAR_EXPR);
                            g_node_append($$,$2);
                        };
addition:               arithmetic_expression TOK_PLUS arithmetic_expression{
                            $$=g_node_new((gpointer) ADDITION);
                            g_node_append($$,$1);
                            g_node_append($$,$3);
                        }
substraction:           arithmetic_expression TOK_MINUS arithmetic_expression{
                            $$=g_node_new((gpointer) SUBSTRACTION);
                            g_node_append($$,$1);
                            g_node_append($$,$3);
                        }
multiplication:         arithmetic_expression TOK_MUL arithmetic_expression{
                            $$=g_node_new((gpointer) MULTIPLICATION);
                            g_node_append($$,$1);
                            g_node_append($$,$3);
                        }
division:               arithmetic_expression TOK_DIV arithmetic_expression{
                            $$=g_node_new((gpointer) DIVISION);
                            g_node_append($$,$1);
                            g_node_append($$,$3);
                        }

%%

/*In the main function, we call yyparse() generated by bison, that will call yylex from our lexicon analyser*/
int main(int argc, char** argv){
    srand(time(NULL));
    /*Checking the compiler is called the right way*/
    if(argc!=2){
        fprintf(stderr, ANSI_COLOR_RED "ERROR. Too many arguments to programm. Expected 1 got %d" ANSI_COLOR_RESET,argc);
        return EXIT_FAILURE;
    }
    /*Declaration of variables to check if given parameter has right extension .kon*/
    regex_t regex;
    char msgbuf[100];

    /*Compiling regular expression*/
    if(regcomp(&regex,"^.*\.kon$",0)){
        fprintf(stderr, ANSI_COLOR_RED "COULD NOT COMPILE REGEX\n" ANSI_COLOR_RESET);
        return EXIT_FAILURE;
    }

    /*We get the name of the source file*/
    char* srcFile = strdup(argv[1]);
    /*Checking the source file is the right format*/
    if(regexec(&regex, srcFile, 0, NULL, 0) == REG_NOMATCH){
        fprintf(stderr, ANSI_COLOR_RED "WRONG FILE FORMAT.\nExpected *.kon file" ANSI_COLOR_RESET);
        return EXIT_FAILURE;
    }
    /*Ok, so now everything's fine*/

    /*Opening the source file in stdin. I don't know if this is ok but I'll change it later if I can do it another way*/
    stdin = fopen(srcFile,"r");
    /*Creating the destination file, a .c file*/
    char* dstFile = strdup(srcFile);
    /*Replace the extension by .c*/
    strcpy(rindex(dstFile,'.'),".c");
    /*Opens the file in writing mode*/
    outFile=fopen(dstFile,"w");

    /*Hash Table creation*/
    variable_table = g_hash_table_new_full(g_str_hash,g_str_equal,free,free);
    printf(ANSI_COLOR_CYAN"Begining syntax analysis\n"ANSI_COLOR_RESET);

    code_start();
    yyparse();
    code_end();
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
    if(error_semantic){
        printf(ANSI_COLOR_RED "What you wrote doesn't make any sense!\n" ANSI_COLOR_RESET);
    }else{
        printf(ANSI_COLOR_GREEN "I understand what you are saying\n" ANSI_COLOR_RESET);
    }
    fclose(stdin);
    fclose(outFile);
    free(srcFile);
    free(dstFile);
    g_hash_table_destroy(variable_table);
    return EXIT_SUCCESS;
}

void yyerror(char *s){
    fprintf(stderr,ANSI_COLOR_RED "Unknown syntax on line %d.Don't try to be smart and go clean %s up\n" ANSI_COLOR_RESET,lineno,s);
}
