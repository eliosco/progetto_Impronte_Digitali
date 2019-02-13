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

biforcazioni(T) :-
	findall(Bif, biforcazione(Bif), Biforcazioni),
	length(Biforcazioni,T).

biforcazione(Bif) :-
	a(X,Y,Ref),
	bif(X,Y,Bif),
        send(Ref,colour,colour(red)),
	colorapixel(Bif).

laghi(T) :-
	findall(Lag,lago(Lag),Laghi),
	length(Laghi,T).

lago(VRef1) :-
	a(X,Y,Ref1),
	a(W,Z,Ref2),
	lag(X,Y,VRef1,W,Z,VRef2),
        send(Ref1,colour,colour(red)),
	send(Ref2,colour,colour(red)),
	colorapixel(VRef1),
	colorapixel(VRef2).


lag(X,Y,VRef1,W,Z,VRef2) :-
	semilago_nord(X,Y,VRef1),
	semilago_sud(W,Z,VRef2),
	distanza(X,Y,W,Z,Dist_oriz,Dist_vert),
	Dist_oriz =< 5,
	Dist_vert =< 20
	;
	semilago_ovest(X,Y,VRef1),
	semilago_est(W,Z,VRef2),
	distanza(X,Y,W,Z,Dist_oriz,Dist_vert),
	Dist_oriz =< 20,
	Dist_vert =< 5.

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
	X9 is X+1,
	Y9 is Y+1,
        a(X9,Y9,Ref3),
        Bif = [Ref1,Ref2,Ref3].

%pattern 3
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
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
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].

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

%predicato per riempire gli spazi bianchi che creano dei buchi
riempi_spazi_bianchi(Finestra):-

	findall(v(X,Y),cerca_spazi_bianchi_orizzontali(X,Y,_, Finestra),_),
	findall(v(X,Y),cerca_spazi_bianchi_verticali(X,Y,_, Finestra),_).


cerca_spazi_bianchi_orizzontali(X,Y,Ref,Finestra):-
	a(X,Y,Ref),
	Xdx is (X+2),
	a(Xdx,Y,_),
	XBianco is (X+1),
	YBiancoUp is (Y-1),
	YBiancoDown is (Y+1),
	\+ a(XBianco,YBiancoUp,_),
	\+ a(XBianco,YBiancoDown,_),
	\+ a(XBianco,Y,_),
	new(Ref1, box(2,2)),
	assert(a(XBianco,Y,Ref1)),
	send(Ref1,colour,colour(blue)),
	send(Finestra,display,Ref1,point((XBianco*2),(Y*2))).

cerca_spazi_bianchi_verticali(X,Y,Ref,Finestra):-
	a(X,Y,Ref),
	YDown is (Y+2),
	a(X,YDown,_),
	YBianco is (Y+1),
	XBiancoSx is (X-1),
	XBiancoDx is (X+1),
	\+ a(XBiancoSx,YBianco,_),
	\+ a(XBiancoDx,YBianco,_),
	\+ a(X,YBianco,_),
	new(Ref2, box(2,2)),
	assert(a(X,YBianco,Ref2)),
	send(Ref2,colour,colour(green)),
	send(Finestra,display,Ref2,point((X*2),(YBianco*2))).


% cancellazione dei pixel errati cioè di quei pixel che hanno un numero
% strettamente maggiore di pixel vicini i quali hanno a loro volta 4
% pixel vicini
cancella_pixel_errati(Finestra):-
	findall(X/Y,trova_pixel_errati(X,Y,_,Finestra),_).

% abbiamo individuato e colorato di rosso i pixel che hanno un numero di
% vicini strettamente maggiore di 2
% NOTA: ORA DOBBIAMO PRIMA EVIDENZIARE PER VERIFICARE LA CORRETTEZZA E
% POI CANCELLARE I PIXEL ERRATI (VEDI DEFINIZIONE)
trova_pixel_errati(X,Y,Ref,Finestra):-
	a(X,Y,Ref),
	findall(X/Y,(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),ListaVicini),
	length(ListaVicini,LunghezzaVicini),
	(LunghezzaVicini > 2),
	colora_pixel(ListaVicini,Finestra).

      % NOTA:RIFARE PROCEDMENTO DEL ASSERT RETRACT COME SU COLORA PIXEL E CONTROLLARE IL CASO DEI 4 VICINI DEI VICINI DEL PIXEL ERRATO
	%controllo_4connection_neighbors(ListaVicini),
	%retract(a(X,Y,Ref)).
	%send(Ref,colour,colour(red)),
	%send(Finestra,display,Ref,point((X*2),(Y*2))).

colora_pixel([],_).
colora_pixel([Xf/Yf],Finestra):-
	a(Xf,Yf,_),
	retract(a(Xf,Yf,_)),
	assert(a(Xf,Yf,Reef)),
	new(Reef, box(2,2)),
	send(Reef,colour,colour(black)),
	send(Finestra,display,Reef,point((Xf*2),(Yf*2))).

colora_pixel([Xf/Yf|C],Finestra):-
	a(Xf,Yf,_),
	retract(a(Xf,Yf,_)),
	assert(a(Xf,Yf,Reef)),
	new(Reef, box(2,2)),
	send(Reef,colour,colour(black)),
	send(Finestra,display,Reef,point((Xf*2),(Yf*2))),
	colora_pixel(C,Finestra).




controllo_4connection_neighbors([]).
controllo_4connection_neighbors([v(Xv,Yv)|Coda]):-
	a(Xv,Yv,_),
	%findall(v(Xv,Yv),(vicino(Xv/Yv,Xvv/Yvv),a(Xvv,Yvv,_)),ListaSottoVicini),
	%length(ListaSottoVicini,LunghezzaSotto),
	%LunghezzaSotto > 3,
        controllo_4connection_neighbors(Coda).

eliminatutto :-
	a(X,Y,Ref),
	retract(a(X,Y,Ref)),
	free(Ref).


