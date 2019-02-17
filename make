#!/bin/bash
if [[ $1 == "clean" ]]
	then rm alakon alakon_syntax.tab.* alakon_lexicon.c
else
	flex -o alakon_lexicon.c alakon_lexicon.lex
	bison -d alakon_syntax.y
	gcc -o alakon alakon_lexicon.c alakon_syntax.tab.c
	rm alakon_syntax.tab.* alakon_lexicon.c
fi
