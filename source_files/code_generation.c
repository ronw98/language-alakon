#include "alakon.h"

char* fromIntToGa(int num){
    int i = 0;
    /*Getting the power of 4 too big to represent this number*/
    while(num / power(4,i)!=0){
        i++;
    }
    char * res = (char*) malloc(2*i*sizeof(char));
    for(i=i-1;i>=0;i--){
        int pow = power(4,i);
        int div = num / pow;
        num = num% pow;
        switch(div){
            case 0:
                *res = 'G';
                res++;
                *res = 'a';
                res++;
                break;
            case 1:
                *res = 'B';
                res++;
                *res = 'u';
                res++;
                break;
            case 2:
                *res = 'Z';
                res++;
                *res = 'o';
                res++;
                break;
            case 3:
                *res = 'M';
                res++;
                *res = 'e';
                res++;
                break;
        }
    }
    return res;
}

void code_start(){
    fprintf(outFile, "/* This file has been generated using the alakon compiler */\n");
    fprintf(outFile, "#include <stdio.h>\n#include <stdlib.h>\n#include <stdbool.h>\n#include<time.h>\n#include<string.h>\n#include<math.h>\n");
    fprintf(outFile, "int power(int a, int b){\n");
    fprintf(outFile, "int i, res =1;\n");
    fprintf(outFile, "for(i=0;i<b;i++){\n");
    fprintf(outFile, "res*=a;\n}\nreturn res;\n}\n");
    fprintf(outFile, "char * fromIntToGa(int num){\nint i=0;\nwhile(num/power(4,i)!=0){\n");
    fprintf(outFile, "i++;}\nchar * res = (char*) malloc(2*i*sizeof(char));int charIndex = 0;\nfor(i=i-1;i>=0;i--){\n");
    fprintf(outFile, "int pow = power(4,i);\nint div = num / pow;\nnum = num %s pow;\nswitch(div){\n","%");
    fprintf(outFile, "case 0:\nres[charIndex] = 'G';charIndex++;res[charIndex] = 'a';charIndex++;break;\ncase 1:\nres[charIndex] = 'B';charIndex++;res[charIndex] = 'u';charIndex++;break;\n");
    fprintf(outFile, "case 2:\nres[charIndex] = 'Z';charIndex++;res[charIndex] = 'o';charIndex++;break;\ncase 3:\nres[charIndex] = 'M',charIndex++;res[charIndex] = 'e';charIndex++;break;\n");
    fprintf(outFile, "}}return res;}\n");
    fprintf(outFile, "int main(){\nsrand(time(NULL));\n");
}

void code_end(){
    fprintf(outFile, "return EXIT_SUCCESS;\n}\n");
}

void code_generation(GNode * ast){
    if(ast){
        switch ((long)ast->data){
            case SEQUENCE:
                code_generation(g_node_nth_child(ast,0));
                code_generation(g_node_nth_child(ast,1));
                break;
            case VARIABLE:
                fprintf(outFile, "%s",(char*)g_node_nth_child(ast,0)->data);
                break;
            case INTEGERT:
                fprintf(outFile, "int ");
                break;
            case BOOLEANT:
                fprintf(outFile, "float ");
                break;
            case RACCOON:
                fprintf(outFile,"/*\n");
                fprintf(outFile,"                     Hello ");
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile, "!\n");
                fprintf(outFile,"                        ,       ,\n");
                fprintf(outFile,"                       ( \\     / (\n");
                fprintf(outFile,"                       \\  '---'  /\n");
                fprintf(outFile,"                       /.--. .--,\\   .-'''-,\n");
                fprintf(outFile,"                      /\\_(o) (o)_/\\ /\\ | /  \\\n");
                fprintf(outFile,"                  __.-.___(_c_)_.-./\\ \\ / / /)\n");
                fprintf(outFile,"                 (__(((_________)))__--''/ / /\n");
                fprintf(outFile,"                  |  ||  ||  ||  ||  ||   / )\n");
                fprintf(outFile,"                  |  ||  ||  ||  ||  ||   |/\n");
                fprintf(outFile,"                  |  ||  ||  ||  ||  ||   '\n");
                fprintf(outFile,"                  \\  ||  ||  ||  ||  ||\n");
                fprintf(outFile,"                   \\ ||  ||  ||  |.- -'''- -._\n");
                fprintf(outFile,"                   /\\||  ||  ||  ;            :\n");
                fprintf(outFile,"                  |  ||  ||  || :     __       ;\n");
                fprintf(outFile,"                  |  ||  ||  ||:     (  (       :\n");
                fprintf(outFile,"                  |  ||  ||  ||;               .\n");
                fprintf(outFile,"                  |  ||  ||  || ,             ,\n");
                fprintf(outFile,"                  .,_c__.,__1db__'- -,..,- -'\n");
                fprintf(outFile,"*/\n");
                break;
            case DECLARATION:
                code_generation(g_node_nth_child(ast,0));
                code_generation(g_node_nth_child(ast,1));
                fprintf(outFile,";\n");
                break;
            case DECLARAFFECT:
                code_generation(g_node_nth_child(ast,0));
                code_generation(g_node_nth_child(ast,1));
                fprintf(outFile,"=");
                code_generation(g_node_nth_child(ast,2));
                fprintf(outFile,";\n");
                break;
            case AFFECTATION:
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"=");
                code_generation(g_node_nth_child(ast,1));
                fprintf(outFile,";\n");
                break;
            case PRINTI:
                fprintf(outFile,"printf(\"%%d\\n\",");
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,");\n");
                break;
            case PRINTB:
                fprintf(outFile,"float tmpVarForBool =  ");
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,";\n");
                fprintf(outFile,"if(tmpVarForBool==0){printf(\"false\\n\");}else if(tmpVarForBool == floor(tmpVarForBool)){printf(\"true\\n\");}else{printf(\"maybe?\\n\");}");
                break;
            case NUM:
                fprintf(outFile,"%s",(char*)g_node_nth_child(ast,0)->data);
                break;
            case ADDITION:
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"+");
                code_generation(g_node_nth_child(ast,1));
                break;
            case SUBSTRACTION:
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"-");
                code_generation(g_node_nth_child(ast,1));
                break;
            case MULTIPLICATION:
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"*");
                code_generation(g_node_nth_child(ast,1));
                break;
            case DIVISION:
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"/");
                code_generation(g_node_nth_child(ast,1));
                break;
            case OR:
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"+");
                code_generation(g_node_nth_child(ast,1));
                break;
            case AND:
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"*");
                code_generation(g_node_nth_child(ast,1));
                break;
            case NOPE:
                fprintf(outFile,"(-(");
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"))");
                break;
            case TRU:
                fprintf(outFile,"1");
                break;
            case FALS:
                fprintf(outFile,"0");
                break;
            case MAYBE:
                fprintf(outFile,"0.5");
                break;
            case PAR_EXPR:
                fprintf(outFile,"(");
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,")");
                break;
            case PRINTVARI:
                fprintf(outFile, "printf(\"%%s\\n\",fromIntToGa(");
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"));\n");
        }
    }
}
