# langage-alakon
The idea is to learn how to create an programming laguage, in a crazy way.
For now, the lexicon and syntax analyzers are written, but will be improved (as the language evolves).

## Installation
This project requires flex and bison in order to work.
To install them on Ubuntu, open a terminal and type:
```bash
sudo apt install flex bison
```
You will also need gcc (which should be already installed on your computer).

## Running the programm
To build the compiler (or what there is of it), just execute the make script:
```bash
./make
```
To analyse a programm you wrote, just type:
```bash
alakon < testProgram.kon
```
(.kon is the extension for alakon programs)

## What is coming next
The next thing to do is to implement the variable type so that `int var = boolVar * 5` is not possible.
