IN: scratchpad
USE: compiler
USE: test
USE: stack
USE: words
USE: combinators
USE: lists
USE: math

! Make sure that stack ops compile to correct code.
: compile-call ( quot -- word )
    gensym [ swap define-compound ] keep dup compile execute ;

[ ] [ 1 [ drop ] compile-call ] unit-test
[ ] [ [ 1 drop ] compile-call ] unit-test
[ ] [ [ 1 2 2drop ] compile-call ] unit-test
[ ] [ 1 [ 2 2drop ] compile-call ] unit-test
[ ] [ 1 2 [ 2drop ] compile-call ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-call ] unit-test
[ 1 1 ] [ [ 1 dup ] compile-call ] unit-test

! Test various kill combinations

: kill-1
    [ 1 2 3 ] [ + ] over drop drop ; compiled

[ [ 1 2 3 ] ] [ kill-1 ] unit-test

: kill-2
    [ + ] [ 1 2 3 ] over drop nip ; compiled

[ [ 1 2 3 ] ] [ kill-2 ] unit-test

: kill-3
    [ + ] dup over 3drop ;

[ ] [ kill-3 ] unit-test

: kill-4
    [ 1 2 3 ] [ + ] [ - ] pick >r 2drop r> ; compiled

[ [ 1 2 3 ] [ 1 2 3 ] ] [ kill-4 ] unit-test

: kill-5
    [ + ] [ - ] [ 1 2 3 ] pick pick 2drop >r 2drop r> ; compiled

[ [ 1 2 3 ] ] [ kill-5 ] unit-test

: kill-6
    [ 1 2 3 ] [ 4 5 6 ] [ + ] pick >r drop r> ; compiled

[ [ 1 2 3 ] [ 4 5 6 ] [ 1 2 3 ] ] [ kill-6 ] unit-test
