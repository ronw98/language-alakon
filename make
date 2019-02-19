#!/bin/bash
if [[ $1 == "clean" ]]
	then rm alakon alakon_syntax.tab.* alakon_lexicon.c
else
	flex -o alakon_lexicon.c alakon_lexicon.lex
	bison -d alakon_syntax.y
	gcc alakon_lexicon.c alakon_syntax.tab.c code_generation.c `pkg-config --cflags --libs glib-2.0` -o alakon
	rm alakon_syntax.tab.* alakon_lexicon.c
fi
