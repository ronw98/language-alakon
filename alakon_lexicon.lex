/* The ideais to formally describe the lexicon of the alakon laguage*/
/*We start first by including some C libraries, between '%' beacons*/
%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <stdbool.h>
    void lexeme(void);
    unsigned int lineno = 1;
    bool error = false;
%}

/*Declaration of flex variables.  These are the terms we're gonna use in our language*/

/*numbers are in GauZoMeu notation (which is just a base 4)*/
number Ga$|(Ga|Bu|Zo|Meu)(Ga|Bu|Zo|Meu)*

variable [[:alpha:]][[:alnum:]]*

/*Between the %% beacons are all the actions to do when encountering a term*/

%%
{number}    {printf("\tNumber found on line %d. It is the number %s, counting %d digits\n",lineno,yytext,yyleng/2);}
"print"     {lexeme();}
"="         {lexeme();}
"+"         {lexeme();}
"-"         {lexeme();}
"*"         {lexeme();}
"/"         {lexeme();}
"and"       {lexeme();}
"or"        {lexeme();}
"nope"      {lexeme();}
";"         {lexeme();printf("\n");}
"("         {lexeme();}
")"         {lexeme();}
"true"      {lexeme();}
"false"     {lexeme();}
"maybe"     {lexeme();}
"int"       {lexeme();}
"bool"      {lexeme();}
"raccoon"   {printf("A raccoon was found line %d!\n",lineno);}
"\n"        {lineno++;}
{variable}  {printf("Variable found on line %d. Its name is %s\n",lineno,yytext);} /*We define the variable action after the rest, otherwise "print" and other alphanum terms could be considered as variables*/
" "|"\t"    {}  /*No action on spaces and tabs*/
.           {fprintf(stderr,"\tYOU got an UNKNOW term in your programm you moron!\nIt is line %d btw.\n",lineno);error = true;}
%%

/*Let's write the syntax analysor*/
int main(){
    printf("Analyse en cours... Analyse en cours...\n");
    yylex();
    printf("Terminé!\n");
    if(error){
        printf("I encountered trouble when analysing your text my liege.\n");
    }else{
        printf("Congrats! You didn't write nonesense shit (well, you did but in a good way)\n");
    }
    return EXIT_SUCCESS;
}

/* Just for the begining, we will pretend to be extremely happy when we encounter something totally normal*/

void lexeme(){
    printf("WE FOUND A WORD! THIS WORD IS \"%s\"! THIS IS AMAAAAZIIIIING!!\n",yytext);
}

/*This function is just to do something when encountering EOF. It must return 1*/
int yywrap(){
    return 1;
}
