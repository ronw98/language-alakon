#Documentation
This is a small documentation file for the alakon laguage.
##Types
There are (for now) two types of variables in this language:
* Integers
* Booleans
Integers are under `GaBuZoMe` format. This is a base 4, `Ga = 0`, `Me = 3`
Booleans can take value `true`, `false` and `maybe`.
`maybe` is either true or false, randomly (the variable is set at the begining of the program).

##A bit of code
```
int varInt1;
int varInt2 = BuBuGaMeGa;
bool varBool1;
bool varBool2 = maybe;

varInt1 = varInt2 + Ga;
varInt1 = varInt2 * Ga;
varInt1 = varInt2 - Ga;
varInt1 = varInt2 / Ga;

varBool1 = varBool2 and false;
varBool1 = varBool2 or false;
varBool1 = nope varBool2;

print(varInt1);
print(varBool1);
print(Bu+Me);
print(maybe and maybe);
```
