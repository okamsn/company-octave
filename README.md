# company-octave

This is a Company backend for GNU Octave. It uses the Octave REPL to get completion candidates, and can complete for structs. The REPL must be aware of the desired completion candidate for it to be suggested. It (the inferior Octave process) will suggest built-in functions and variables, and anything that has been submitted to the REPL.

It is basically a Company version of `ac-octave` that can handle prefixes like "someStructName." (the '.' is required) and return candidates like "someStructName.someField".

Right now, given that Octave has a built-in mode for Emacs with all the feature support that comes with that, this has a minimum of features.

## Using the backend

To use the backend, add the function `company-octave-setting` (or equivalent) to the hook for Octave mode. Company mode must be active.
