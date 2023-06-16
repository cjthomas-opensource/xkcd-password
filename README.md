# XKCD-style password generator

This script generates passwords using
[xkcd's algorithm](https://xkcd.com/936/) (stringing together several random
dictionary words). This gives passwords that are strong and easy to remember.

> Usage:  gen-password  <options>
> 
> Options:
> --help               Prints this screen.
> --dictionary=(file)  Specifies dictionary; default is "/usr/share/dict/words".
> --numwords=N         Specifies number of words; default is 4.
> --debug-dict         Prints dictionary debugging information.

**NOTE** - This uses `rand()` for random number generation. While that's
not cryptographically strong, it should be more than good enough for this
application.

The weakness in `rand()` means that if you know the first die roll you know
that certain subsequent die rolls are a bit more likely than others. In this
case, if an attacker had the dictionary list _and_ knew what version of
`rand()` was being used, they would only need to make a few trillion guesses
instead of a few quadrillion. That's still better than most passwords.

_(This is the end of the file.)_
