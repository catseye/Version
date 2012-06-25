Version
=======

Copyright ©2001-2010 Cat's Eye Technologies. All rights reserved.

What is Version?
----------------

Version is a programming language based on the concept of
*ignorance-spaces*. An ignorance-space is represented by a pattern
(irregular expression.) All instructions in a Version program have a tag
or label. Instructions with labels which match the current
ignorance-space are ignored. Other instructions are executed
sequentially. When the last instruction is reached, execution wraps
around to the beginning of the program. The only way to halt a program
is to put it in a state in which all instructions will be ignored.

Other than this ignorance-space, there are no jumping or conditional
execution mechanisms in Version.

Instructions
------------

Each Version instruction must occur on its own line of source code, and
looks like:

    label: destination = expression

The label is a string. The destination is the name of a variable, or a
special destination name listed below. The expression may be made up of
prefix operators, string variables, and special expression terms, listed
below.

The result of executing an instruction is that a message containing the
expression is sent to the destination. If the destination is a variable,
this generally results in the state of the variable changing. This may
not however hold true under all conditions - future extensions to
Version may add further effects under prescribed conditions.

Special Destinations
--------------------

-   `OUTPUT`

    Sending a message to `OUTPUT` causes the datum in question to appear
    on the standard output communications channel.

-   `IGNORE`

    Sending a message to `IGNORE` constitutes a request to change from the
    current ignorance-space to a new one.

-   `CAT`

    Sending a message to `CAT` concatenates a value to the last
    (non-Special) variable assigned (at runtime, not in source code). If
    there was never a variable assigned, the last variable assigned is
    considered to be `DUANE` for some reason.

-   `PUT`

    Sending a message to `PUT` concatenates a value to the *name* of the
    last variable, and copies the value from the the last variable to
    the newly named variable. Used to simulate associative arrays.

-   `GET`

    Like `PUT`, except it copies the value of the newly named variable
    into the last variable. Note that the name of the last variable does
    not actually change while using `PUT` or `GET`.

Special Expression Terms
------------------------

-   `INPUT`

    Accessing the name `INPUT` causes the standard input communications
    channel to wait for a line of text and return it (complete with
    trailing newline.)

-   `IGNORE`

    Accessing the name `IGNORE` allows the program to inquire as to the
    current ignorance-space.

-   `EOL`

    The name `EOL` evaluates to the end-of-line character sequence
    apropriate for the system.

-   `EOF`

    The variable `EOF` is actually a true variable, so its value can be
    reset if needed. It takes on the value `TRUE` (a string) should the
    end of the standard input channel be reached.

Functions
---------

-   `PRED n`

    Returns the predecessor of n, that is the integer that comes before
    n in the domain of integers, where n is a string containing an
    integer in decimal notation.

-   `SUCC n`

    Returns the successor of n, that is the integer that comes after n
    in the domain of integers, where n is a string containing an integer
    in decimal notation.

-   `CHOP s`

    Returns the string s with the last character missing.

-   `POP s`

    Returns the string s with the first character missing.

-   `LEN s`

    Returns the length of the string s as a string containing an integer
    in decimal notation.

Ignorance-Spaces
----------------

The current ignorance-space is accessed through the keyword `IGNORE`,
whether as a destination or as a term in an expression.

The ignorance-space is defined by an irregular expression, which is
encoded in a string. An irregular expression is like a regular
expression in that it contains special wildcard characters. The wildcard
characters resemble those used in MS-DOS.

-   `?` - question mark - match any character
-   `*` - asterisk - match any number of characters
-   `|` - vertical bar - seperate alternatives

Any characters, except `:`, are allowed in labels, which are case
sensitive. The characters `*`, `?`, and `|`, if used, cannot be matched
literally (use `?` to match them, or don't use them - for simplicity,
wildcard characters cannot be "quoted".)

So `DOG|CAT` would match `DOG` or `CAT` but not `cat` or `antelope` or
`seahorse`. But `a*e` would match `antelope`. As would `a?t?l?p?`.

Conventions
-----------

For reasons that are not well known, the common filename extension for
Version source files is `_7%` (underscore, seven, percent sign).

Each source line which does not even contain a colon is treated as a
comment.
