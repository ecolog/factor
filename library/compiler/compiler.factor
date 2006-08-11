! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: errors generic hashtables inference io kernel math
namespaces optimizer parser prettyprint sequences test threads
words ;

: (compile) ( word -- )
    dup compiling? not over compound? and [
        "Compiling " write dup . flush
        dup specialized-def dataflow optimize generate
    ] [
        drop
    ] if ;

: compile ( word -- )
    [ (compile) ] with-compiler ;

: try-compile ( word -- )
    [ compile ] [ error. update-xt ] recover ;

: compile-vocabs ( vocabs -- )
    [ words ] map concat
    dup [ f "no-effect" set-word-prop ] each
    [ try-compile ] each ;

: compile-all ( -- ) vocabs compile-vocabs ;

: compile-quot ( quot -- word )
    define-temp "compile" get [ dup compile ] when ;

: compile-1 ( quot -- ) compile-quot execute ;

: recompile ( -- )
    #! If we are recompiling a lot of words, we can save time
    #! with the class<cache.
    changed-words get [
        dup hash-keys [ [ try-compile ] each clear-hash ]
        over length 20 > [ with-class<cache ] [ call ] if
    ] when* ;

[ recompile ] parse-hook set
