/*So this is a bison file and I have no idea how it works
I'll try my best to comment it so that it is understandable*/

%{
    #include "alakon.h"
    bool error_syntax = false;
    extern unsigned int lineno;
    extern bool error_lexicon;
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
                        code instruction{
                            printf("I guess you did well but I have no idea what this code analyses. Anway, it is line %d\n",lineno);
                        }
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
                            printf("Variable %s\n",$1);
                            /* Then we give the bison variable $$ the value of $1 (using a copy)*/
                            $$ = strdup($1);
                        };
type:                   TOK_INT{
                            printf("\t\tInteger\n");
                            $$=strdup("int");
                        }
                        |
                        TOK_BOOL{
                            printf("\t\tBool\n");
                            $$=strdup("bool");
                        }
                        |
                        TOK_RACC{
                            printf("\t\tOh look! A raccoon!\n");
                            $$=strdup("raccoon");
                        };
declaration:            type variable TOK_ENDINSTR{
                            /* $1 is type, $2 variable etc...*/
                            printf("The variable %s has been declared\n",$2);
                        }
                        |
                        type  affectation{
                            printf("A variable has been declared and initialized\n");
                        };
affectation:            variable TOK_AFFECT expression TOK_ENDINSTR{
                            printf("Affect value to variable %s\n", $1);
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
                            printf("\t\tNumber %ld\n",$1);
                            int length=snprintf(NULL,0,"%ld",$1);
                            char* str=malloc(length+1);
                            snprintf(str,length+1,"%ld",$1);
                            $$=strdup(str);
                            free(str);
                        }
                        |
                        variable{}
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
                            $$=strdup($1);
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
    printf("Begining syntax analysis\n");
    yyparse();
    printf("End of the analysis\n");
    printf("Results:\n");
    if(error_lexicon){
        printf("You idiot wrote unknown words! Why would you do that?\n");
    }else{
        printf("Congrats! Your pityful mind managed to write down some actual words\n");
    }
    if(error_syntax){
        printf("Why make proper senteces when you can not\n");
    }else{
        printf("Nice lines here bro\n");
    }
    return EXIT_SUCCESS;
}

void yyerror(char *s){
    fprintf(stderr,"Unknown syntax on line %d.Don't try to be smart and go clean %s up\n",lineno,s);
}
