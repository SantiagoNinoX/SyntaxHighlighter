This is a syntax highlighter, a lexer program for the C++ programming language. A 
lexer is a program that reads code and breaks it into tokens (small meaningful parts like 
keywords, numbers, strings, or punctuation).  

It's usually the first step in a compiler or interpreter, before it goes to a parser (another 
program that takes as input the tokens generated previously by the lexer). The difference 
with a parser is that this one verifies if the written code makes sense or not, so that the 
statements received do an instruction for the computer, and then it goes to a compiler. 

A lexer (short for lexical analyzer) scans source code character by character, groups 
characters into tokens, and outputs a sequence of those tokens. 

The developed lexer receives a source C++ file and reads it to generate tokens. The average 
execution time of the program is 0.50 seconds, though it depends on the computable 
capacity of the device which is running the program, and other factors such as RAM 
availability or other programs running.

This is a lexer written in Racket (functional programming) using the library parser-tools/lex. It scans source code that 
resembles C++ and tokenizes it (breaks down the input into a stream of tokens, which 
represent meaningful components of the language).
