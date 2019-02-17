/* The ideais to formally describe the lexicon of the alakon laguage*/
/*We start first by including some C libraries, between '%' beacons*/
%{
    #include "alakon.h"
    #include <math.h>
    void lexeme(void);
    unsigned int lineno = 1;
    bool error_lexicon = false;

    /*Declaration of some functions useful later*/
    int power(int a, int b);

    int power(int a, int b){
            int i, res=1;
            for(i=0;i<b;i++){
                    res*=a;
            }
            return res;
    }

    int fromGaToDec(char * num);

    int fromGaToDec(char* num)
    {
        int numberOfDigits = strlen(num)/2;
        char * currDig = (char*) malloc(2*sizeof(char));
        int i,res=0;
        for(i = 0; i<numberOfDigits;i++)
        {
            *currDig = *(num++); *(currDig+1) = *(num++);
            if(strcmp(currDig,"Bu")==0){
                res += power(4,numberOfDigits-1-i);
            }
            if(strcmp(currDig,"Zo")==0){
                res += 2* power(4,numberOfDigits-1-i);
            }
            if(strcmp(currDig,"Me")==0){
                res += 3 *power(4,numberOfDigits-1-i);
            }
        }
        free(currDig);
        return res;
    }
%}

/*Declaration of flex variables.  These are the terms we're gonna use in our language*/

/*numbers are in GauZoMeu notation (which is just a base 4)*/
number Ga$|(Ga|Bu|Zo|Me)(Ga|Bu|Zo|Me)*

variable [[:alpha:]][[:alnum:]]*

/*Between the %% beacons are all the actions to do when encountering a term*/

%%
{number}    {yylval.number=fromGaToDec(yytext);return TOK_NUM;}
"print"     {return TOK_DISP;}
"="         {return TOK_AFFECT;}
"+"         {return TOK_PLUS;}
"-"         {return TOK_MINUS;}
"*"         {return TOK_MUL;}
"/"         {return TOK_DIV;}
"and"       {return TOK_AND;}
"or"        {return TOK_OR;}
"nope"      {return TOK_NOPE;}
";"         {return TOK_ENDINSTR;}
"("         {return TOK_LEFTP;}
")"         {return TOK_RIGHTP;}
"true"      {return TOK_TRUE;}
"false"     {return TOK_FALSE;}
"maybe"     {return TOK_MAYBE;}
"int"       {return TOK_INT;}
"bool"      {return TOK_BOOL;}
"raccoon"   {return TOK_RACC;}
"\n"        {lineno++;}
{variable}  {yylval.text = yytext; return TOK_VAR;} /*We define the variable action after the rest, otherwise "print" and other alphanum terms could be considered as variables*/
" "|"\t"    {}  /*No action on spaces and tabs*/
.           {
                fprintf(stderr,"\tYOU got an UNKNOW term in your programm you moron!\nIt is line %d btw.\n",lineno);
                error_lexicon = true;
                return yytext[0];
            }
%%

/*Let's write the syntax analysor*/
/*int main(){
    printf("Analyse en cours... Analyse en cours...\n");
    yylex();
    printf("Terminé!\n");
    if(error){
        printf("I encountered trouble when analysing your text my liege.\n");
    }else{
        printf("Congrats! You didn't write nonesense shit (well, you did but in a good way)\n");
    }
    return EXIT_SUCCESS;
}*/

/* Just for the begining, we will pretend to be extremely happy when we encounter something totally normal*/

/*void lexeme(){
    printf("WE FOUND A WORD! THIS WORD IS \"%s\"! THIS IS AMAAAAZIIIIING!!\n",yytext);
}*/

/*This function is just to do something when encountering EOF. It must return 1*/
int yywrap(){
    return 1;
}
