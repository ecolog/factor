! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl stdio ;

! A label gadget draws a string.
TUPLE: label text delegate ;

C: label ( text -- )
    <empty-gadget> over set-label-delegate
    [ set-label-text ] keep ;

M: label pref-size ( label -- ) label-text pref-size ;

M: label draw-shape ( label -- )
    dup label-delegate draw-shape
    dup shape-pos [ label-text draw-shape ] with-trans ;
