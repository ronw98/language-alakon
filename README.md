# langage-alakon
This idea is to familiarize with programming language creation by creating a crazy language.
For now, the only thing written down is the lexicon analizer.
## Installation
You will need to compile the alakon_lexicon.lex file using flex.
To do so, you need flex.

### On ubuntu
```bash
sudo apt install flex
flex -o lexicon.c alakon_lexicon.lex
gcc -o lexicon lexicon.c
```

Once you have your analyser compiled you can analyse your programm.
```bash
./lexicon < myprogram.kon
```

