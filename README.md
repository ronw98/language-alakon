# langage-alakon
This idea is to familiarize with programming language creation by creating a crazy language.
For now, the only things written down are the lexicon analizer and the begining of the syntax analyzer.
##Installation
You will need to compile the alakon_lexicon.lex file using flex, and the alakon_syntax.y using bison.
To do so, you need flex and bison.

###On ubuntu
```bash
sudo apt install flex
sudo apt install bison
./make
```
Yup, making a proper makefile is overrated.

Once you have your analyser compiled you can analyse your programm.
```bash
alakon < myprogram.kon
```
##What's next to do
Modify the variables so that `int varWrong = nope randBool;` is not possible.
