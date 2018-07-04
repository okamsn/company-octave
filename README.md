# company-octave

This is a Company backend for GNU Octave. It uses the Octave REPL to get completion candidates, and can complete for structs.

It is basically a Company version of `ac-octave` that can handle prefixes like "someStructName." and return candidates like "someStructName.someField".

Right now, given that Octave has a built-in mode for Emacs with all the feature support that comes with that, this has a minimum of features.
