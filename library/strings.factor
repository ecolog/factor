! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: strings
USE: kernel
USE: lists
USE: math

: f-or-"" ( obj -- ? )
    dup not swap "" = or ;

: f>"" ( str/f -- str )
    [ "" ] unless* ;

: str-length< ( str str -- boolean )
    #! Compare string lengths.
    swap str-length swap str-length < ;

: cat ( [ "a" "b" "c" ] -- "abc" )
    ! If f appears in the list, it is not appended to the
    ! string.
    80 <sbuf> swap [ [ over sbuf-append ] when* ] each sbuf>str ;

: cat2 ( "a" "b" -- "ab" )
    swap
    80 <sbuf>
    dup >r sbuf-append r>
    dup >r sbuf-append r>
    sbuf>str ;

: cat3 ( "a" "b" "c" -- "abc" )
    [ ] cons cons cons cat ;

: index-of ( string substring -- index )
    0 -rot index-of* ;

: str-lexi> ( str1 str2 -- ? )
    ! Returns if the first string lexicographically follows str2
    str-compare 0 > ;

: str-head ( index str -- str )
    #! Returns a new string, from the beginning of the string
    #! until the given index.
    0 -rot substring ;

: str-contains? ( substr str -- ? )
    swap index-of -1 = not ;

: str-tail ( index str -- str )
    #! Returns a new string, from the given index until the end
    #! of the string.
    [ str-length ] keep substring ;

: str/ ( str index -- str str )
    #! Returns 2 strings, that when concatenated yield the
    #! original string.
    [ swap str-head ] 2keep swap str-tail ;

: str// ( str index -- str str )
    #! Returns 2 strings, that when concatenated yield the
    #! original string, without the character at the given
    #! index.
    [ swap str-head ] 2keep succ swap str-tail ;

: str-headcut ( str begin -- str str )
    str-length str/ ;

: =? ( x y z -- z/f )
    #! Push z if x = y, otherwise f.
    >r = r> f ? ;

: str-head? ( str begin -- str )
    #! If the string starts with begin, return the rest of the
    #! string after begin. Otherwise, return f.
    2dup str-length< [ 2drop f ] [ tuck str-headcut =? ] ifte ;

: ?str-head ( str begin -- str ? )
    dupd str-head? dup [ nip t ] [ drop f ] ifte ;

: str-tailcut ( str end -- str str )
    str-length >r dup str-length r> - str/ swap ;

: str-tail? ( str end -- str )
    #! If the string ends with end, return the start of the
    #! string before end. Otherwise, return f.
    2dup str-length< [ 2drop f ] [ tuck str-tailcut =? ] ifte ;

: ?str-tail ( str end -- str ? )
    dupd str-tail? dup [ nip t ] [ drop f ] ifte ;

: split1 ( string split -- before after )
    2dup index-of dup -1 = [
        2drop f
    ] [
        [ swap str-length + over str-tail ] keep
        rot str-head swap
    ] ifte ;

: max-str-length ( list -- len )
    #! Returns the length of the longest string in the given
    #! list.
    0 swap [ str-length max ] each ;

: str-each ( str [ code ] -- )
    #! Execute the code, with each character of the string
    #! pushed onto the stack.
    over str-length [
        -rot 2dup >r >r >r str-nth r> call r> r>
    ] times* 2drop ; inline

: str-sort ( list -- sorted )
    #! Sorts the list into ascending lexicographical string
    #! order.
    [ str-lexi> ] sort ;

: blank? ( ch -- ? ) " \t\n\r" str-contains? ;
: letter? ( ch -- ? ) CHAR: a CHAR: z between? ;
: LETTER? ( ch -- ? ) CHAR: A CHAR: Z between? ;
: digit? ( ch -- ? ) CHAR: 0 CHAR: 9 between? ;
: printable? ( ch -- ? ) CHAR: \s CHAR: ~ between? ;

: quotable? ( ch -- ? )
    #! In a string literal, can this character be used without
    #! escaping?
    dup printable? swap "\"\\" str-contains? not and ;

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    dup letter?
    over LETTER? or
    over digit? or
    swap "/_?." str-contains? or ;
