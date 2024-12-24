# CDTV Language Test

`cdtv-language-test` is a CLI utility that tests if a certain language is configured in the CDTV System Preferences bookmark. It takes one parameter, which is the language code to test for.


## Background
The intended use is in AmigaDOS scripts like e.g. the startup-sequence. 

See the included `example-script` for an example of how to invoke the command and how to test the return code and proceed conditionally based on that return code.


## Usage
This software can test whether a certain language has been selected in the CDTV System Preferences bookmark. It accepts a two letter argument (in lower case) corresponding to one of the 18 selectable languages in the CDTV System Preferences screen. If no argument is given, it assumes 'en' (=UK English). 

The test result is returned as an AmigaDOS return code:

| Return code | Meaning                                                              |
|:-----------:|:---------------------------------------------------------------------|
| 0 - OK      |if tested language matches the set language|
| 5 - WARN   |if tested language does not match the set language
|10 - ERROR  |if tested language is not a valid language code (i.e. not known by CDTV)
|20 - FAIL   |if playerprefs.library failed to open, a good indicator you're not running on a CDTV system

This allows usage of this small and simple command in AmigaDOS scripts like
the startup-sequence in conjunction with `If WARN` statements to decide the
flow of the script.


