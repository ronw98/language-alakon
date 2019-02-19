#include "alakon.h"

void code_start(){
    fprintf(outFile, "/* This file has been generated using the alakon compiler */\n");
    fprintf(outFile, "#include <stdio.h>\n#include <stdlib.h>\n#include <stdbool.h>\n#include<time.h>\n");
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
                fprintf(outFile, "bool ");
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
                fprintf(outFile,"printf(\"%%s\\n\",");
                GNode * maybe = g_node_find(ast,G_IN_ORDER,G_TRAVERSE_LEAVES,(gpointer)MAYBE);
                if(maybe!=NULL){
                    fprintf(outFile,"maybe?");
                }else{
                    code_generation(g_node_nth_child(ast,0));
                    fprintf(outFile,"?\"true\":\"false\"");
                }
                fprintf(outFile,");\n");
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
                fprintf(outFile,"||");
                code_generation(g_node_nth_child(ast,1));
                break;
            case AND:
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,"&&");
                code_generation(g_node_nth_child(ast,1));
                break;
            case NOPE:
                fprintf(outFile,"!");
                code_generation(g_node_nth_child(ast,0));
                break;
            case TRU:
                fprintf(outFile,"true");
                break;
            case FALS:
                fprintf(outFile,"false");
                break;
            case MAYBE:
                fprintf(outFile,"rand() %s","\%2");
                /*bo=rand()%2;
                if(bo){
                    fprintf(outFile,"true");
                }else{
                    fprintf(outFile,"false");
                }*/
                break;
            case PAR_EXPR:
                fprintf(outFile,"(");
                code_generation(g_node_nth_child(ast,0));
                fprintf(outFile,")");
        }
    }
}
