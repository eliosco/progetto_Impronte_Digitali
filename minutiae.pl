/*
 * Titolo:       minutiae
 * Autore:       Aldo Franco Dragoni
 * Creato:	 14 dicembre 2018
 * Linguaggio:	 SWI Prolog
 * Status:       1.0
 * Descrizione:  programma esempio per eterminare le minuzie all'interno
 * di una impronta digitale
 */

:- [impronta].

vicino(X/Y,Xv/Yv) :-
	(   Xv is X + 1,
	    Yv is Y + 1
	;   Xv is X + 1,
	    Yv = Y
	;   Xv is X + 1,
	    Yv is Y - 1
	;   Xv = X,
	    Yv is Y + 1
	;   Xv = X,
	    Yv is Y - 1
	;   Xv is X - 1,
	    Yv is Y + 1
	;   Xv is X - 1,
	    Yv = Y
	;   Xv is X - 1,
	    Yv is Y - 1
	).

isolati(T) :-
	findall(t(X,Y),isolato(X,Y,_),Isolati),
	length(Isolati,T).

isolato(X,Y,Ref) :-
	a(X,Y,Ref),
	findall(v(X,Y),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),[]),
	send(Ref, colour, colour(green)).

terminazioni(T) :-
	findall(t(X,Y),terminazione(X,Y,_),Terminazioni),
	length(Terminazioni,T).

terminazione(X,Y,Ref) :-
	a(X,Y,Ref),
	findall(v(X,Y),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),Vicini),
	length(Vicini,1),
	send(Ref, colour, colour(red)).


tratto_di_2(A,B,C,D,Ref1,Ref2) :-
	terminazione(A,B,Ref1),
	terminazione(C,D,Ref2),
	vicino(A/B,C/D).

%predicato per riempire gli spazi bianchi che creano dei buchi
riempi_spazi_bianchi(Finestra):-
	findall(v(X,Y),cerca_spazi_bianchi_orizzontali(X,Y,_, Finestra),_),
	findall(v(X,Y),cerca_spazi_bianchi_verticali(X,Y,_, Finestra),_).

cerca_spazi_bianchi_orizzontali(X,Y,Ref,Finestra):-
	a(X,Y,Ref),
	Xdx is (X+2),
	YUp is (Y-1),
	YDown is (Y+1),
	Y2Up is (Y-2),
	Y2Down is (Y+2),
	(a(Xdx,Y,_)
	;
	a(Xdx,YUp,_)
	;
	a(Xdx,YDown,_)),
	XBianco is (X+1),
	\+ a(XBianco,YUp,_),
	\+ a(XBianco,YDown,_),
	\+ a(XBianco,Y,_),
	new(Ref1, box(4,4)),
	assert(a(XBianco,Y,Ref1)),
	send(Ref1,colour,colour(black)),
	send(Ref1,fill_pattern,colour(black)),
	send(Finestra,display,Ref1,point((XBianco*4),(Y*4))).

cerca_spazi_bianchi_verticali(X,Y,Ref,Finestra):-
	a(X,Y,Ref),
	YDown is (Y+2),
	XSx is (X-1),
	XDx is (X+1),
	(a(X,YDown,_)
	;
	a(XSx,YDown,_)
	;
	a(XDx,YDown,_)),
	YBianco is (Y+1),
	\+ a(XSx,YBianco,_),
	\+ a(XDx,YBianco,_),
	\+ a(X,YBianco,_),
	new(Ref2, box(4,4)),
	assert(a(X,YBianco,Ref2)),
	send(Ref2,colour,colour(black)),
	send(Ref2,fill_pattern,colour(black)),
	send(Finestra,display,Ref2,point((X*4),(YBianco*4))).


% cancellazione dei pixel errati cioè di quei pixel che hanno un numero
% strettamente maggiore di pixel vicini i quali hanno a loro volta 4
% pixel vicini
cancella_pixel_errati(Finestra):-
	findall(X/Y,trova_pixel_errati(X,Y,_,Finestra),_).

trova_pixel_errati(X,Y,Ref,_):-
	a(X,Y,Ref),
	findall(v(Xv,Yv),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),ListaVicini),
	length(ListaVicini,LunghezzaVicini),
	LunghezzaVicini > 2,
	controllo_4connection_neighbors(ListaVicini,Prova),
	length(Prova,Lungh),
	Lungh > 2,
	send(Ref,colour,colour(white)),
	send(Ref,fill_pattern,colour(white)),
	retract(a(X,Y,_)).

controllo_4connection_neighbors([],[]).
controllo_4connection_neighbors([v(X,Y)|Coda],Prova1):-
	controllo_4connection_neighbors(Coda,Prova),
	findall(v(Xv,Yv),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),ListaSottoVicini),
	length(ListaSottoVicini,LunghezzaSotto),
	LunghezzaSotto > 3,
	!,
	append(Prova,[v(X,Y)],Prova1).


cancella_pixel_errati_3(Finestra):-
	findall(X/Y,trova_pixel_errati_3(X,Y,_,Finestra),_).

trova_pixel_errati_3(X,Y,Ref,_):-
	a(X,Y,Ref),

	findall(v(Xv,Yv),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),ListaVicini),
	length(ListaVicini,LunghezzaVicini),
	LunghezzaVicini > 2,
	controllo_3connection_neighbors(ListaVicini,Prova),
	length(Prova,Lungh),
	Lungh > 2,
	send(Ref,colour,colour(white)),
	send(Ref,fill_pattern,colour(white)),
	retract(a(X,Y,_)).
	%colora_pixel(ListaVicini,Finestra).

controllo_3connection_neighbors([],[]).
controllo_3connection_neighbors([v(X,Y)|Coda],Prova1):-
	controllo_3connection_neighbors(Coda,Prova),
	findall(v(Xv,Yv),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),ListaSottoVicini),
	length(ListaSottoVicini,LunghezzaSotto),
	LunghezzaSotto > 2,
	!,
	append(Prova,[v(X,Y)],Prova1).


biforcazioni(T) :-
	findall(Bif, biforcazione(Bif), Biforcazioni),
	length(Biforcazioni,T).

biforcazione(Bif) :-
	a(X,Y,Ref),
	bif(X,Y,Bif),
        send(Ref,colour,colour(red)),
	colora_lista(Bif).

laghi(T) :-
	findall(Lag,lago(Lag),Laghi),
	length(Laghi,T).

lago(VRef1) :-
	a(X,Y,Ref1),
	a(W,Z,Ref2),
	lag(X,Y,VRef1,W,Z,VRef2),
        send(Ref1,colour,colour(red)),
	send(Ref2,colour,colour(red)),
	colora_lista(VRef1),
	colora_lista(VRef2).


lag(X,Y,VRef1,W,Z,VRef2) :-
	semilago_nord(X,Y,VRef1),
	semilago_sud(W,Z,VRef2),
	distanza(X,Y,W,Z,Dist_oriz,Dist_vert)
	%Dist_oriz =< 5,
	%Dist_vert =< 20
	;
	semilago_ovest(X,Y,VRef1),
	semilago_est(W,Z,VRef2),
	distanza(X,Y,W,Z,Dist_oriz,Dist_vert).
	%Dist_oriz =< 20,
	%Dist_vert =< 5.

distanza(X,Y,W,Z,Dist_oriz,Dist_vert) :-
	Dist_oriz  is abs(X-W),
	Dist_vert is abs(Y-Z).

semilago_sud(X,Y,VRef) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref2),
	X8 is X,
	Y8 is Y+1,
	a(X8,Y8,Ref3),
	VRef = [Ref1,Ref2,Ref3].

semilago_nord(X,Y,VRef) :-
	X2 is X,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref2),
	X9 is X+1,
	Y9 is Y+1,
        a(X9,Y9,Ref3),
        VRef = [Ref1,Ref2,Ref3].

semilago_est(X,Y,VRef) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	X6 is X+1,
	Y6 is Y,
	a(X6,Y6,Ref2),
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref3),
	VRef = [Ref1,Ref2,Ref3].

semilago_ovest(X,Y,VRef) :-
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref1),
	X4 is X-1,
	Y4 is Y,
	a(X4,Y4,Ref2),
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	VRef = [Ref1,Ref2,Ref3].


%pattern 1
bif(X,Y,Bif) :-
	%a(X,Y,Ref0),
	X1 is X-1,
	Y1 is Y-1,
	X2 is X,
	Y2 is Y-1,
	\+ a(X2,Y2,_),
	a(X1,Y1,Ref1),
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref2),
	X8 is X,
	Y8 is Y+1,
	a(X8,Y8,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 2
bif(X,Y,Bif) :-
	%a(X,Y,Ref0),
	X2 is X,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref2),
	X8 is X,
	Y8 is Y+1,
	\+ a(X8,Y8,_),
	X9 is X+1,
	Y9 is Y+1,
        a(X9,Y9,Ref3),
        Bif = [Ref1,Ref2,Ref3].

%pattern 3
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	X4 is X-1,
	Y4 is Y,
	\+ a(X4,Y4,_),
	X6 is X+1,
	Y6 is Y,
	a(X6,Y6,Ref2),
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 4
bif(X,Y,Bif) :-
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref1),
	X4 is X-1,
	Y4 is Y,
	a(X4,Y4,Ref2),
	X6 is X+1,
	Y6 is Y,
	\+ a(X6,Y6,_),
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].
/*
%pattern17
bif(X, Y, Bif):-
    X3 is X+1,
    Y3 is Y-1,
    a(X3,Y3, Ref1),
    X4 is X-1,
    Y4 is Y,
    a(X4,Y4,Ref2),
    X8 is X,
    Y8 is Y+1,
    a(X8,Y8,Ref3),
    Bif = [Ref1,Ref2,Ref3].

%pattern18
bif(X, Y, Bif):-
    X2 is X,
    Y2 is Y-1,
    a(X2,Y2,Ref1),
    X6 is X+1,
    Y6 is Y,
    a(X6,Y6,Ref2),
    X7 is X-1,
    Y7 is Y+1,
    a(X7,Y7,Ref3),
    Bif = [Ref1,Ref2,Ref3].

%pattern19
bif(X, Y, Bif):-
    X2 is X,
    Y2 is Y-1,
    a(X2,Y2,Ref1),
    X4 is X-1,
    Y4 is Y,
    a(X4,Y4,Ref2),
    X9 is X+1,
    Y9 is Y+1,
    a(X9,Y9,Ref3),
    Bif = [Ref1,Ref2,Ref3].

%pattern20
bif(X, Y, Bif):-
    X1 is X-1,
    Y1 is Y-1,
    a(X1,Y1,Ref1),
    X6 is X+1,
    Y6 is Y,
    a(X6,Y6,Ref2),
    X8 is X,
    Y8 is Y+1,
    a(X8,Y8,Ref3),
    Bif = [Ref1,Ref2,Ref3].
*/

eliminatutto :-
	a(X,Y,Ref),
	retract(a(X,Y,Ref)),
	free(Ref).
