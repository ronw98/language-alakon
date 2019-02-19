#!/bin/bash

#Ths script is the equivalent of a makefile but for some reason I didn't want to do a true makefile so I made this
#It compiles all the source files into the translator.
#It also create the compiling script 'alk'. This is the script you want to call to compile a kon file.

if [[ $1 == "clean" ]]
	then rm source_files/alakon source_files/alakon_syntax.tab.* source_files/alakon_lexicon.c
else
	flex -o source_files/alakon_lexicon.c source_files/alakon_lexicon.lex
	bison -d source_files/alakon_syntax.y
	mv alakon_syntax.tab.* source_files/
	gcc source_files/alakon_lexicon.c source_files/alakon_syntax.tab.c source_files/code_generation.c `pkg-config --cflags --libs glib-2.0` -o bin/alakon
	rm source_files/alakon_syntax.tab.* source_files/alakon_lexicon.c alk
	echo "#!/bin/bash" >> alk 
	echo "#This script compiles .kon files into executables. It is called this way: ./alk file.kon and creates the file executable" >> alk
	echo "bin/alakon \$1" >> alk
	echo "inCfile=\$(echo "\$1"|sed 's/.kon/.c/')" >> alk
	echo "outfile=\$(echo "\$1"|sed 's/.kon//')" >> alk
	echo "gcc -o \$outfile \$inCfile" >> alk
	echo "rm \$inCfile" >> alk
	chmod u+x alk
fi
