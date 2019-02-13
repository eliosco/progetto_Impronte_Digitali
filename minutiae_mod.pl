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

bif(T):-

	findall(v(X,Y),biforcazione_1(X,Y,_),Biforcazioni_1),
	length(Biforcazioni_1,T).


biforcazione_1(X,Y,Ref):-
	a(X,Y,Ref),
	X1 is (X-1),
	Y1 is (Y-1),
	a(X1,Y1,_),
	X2 is X+1,
	Y2 is Y-1,
	a(X2,Y2,_),

	X3=X,Y3 is Y+1,
	a(X3,Y3,_),
	X4=X,Y4 is Y-1,
	\+ a(X4,Y4,_),
	send(Ref,colour,colour(red)).



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
	assert(a(XBianco,Y,Ref1)),
	new(Ref1, box(2,2)),
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
	assert(a(X,YBianco,Ref2)),
	new(Ref2, box(2,2)),
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
	send(Reef,colour,colour(red)),
	send(Finestra,display,Reef,point((Xf*2),(Yf*2))).

colora_pixel([Xf/Yf|C],Finestra):-
	a(Xf,Yf,_),
	retract(a(Xf,Yf,_)),
	assert(a(Xf,Yf,Reef)),
	new(Reef, box(2,2)),
	send(Reef,colour,colour(red)),
	send(Finestra,display,Reef,point((Xf*2),(Yf*2))),
	colora_pixel(C,Finestra).




controllo_4connection_neighbors([]).
controllo_4connection_neighbors([v(Xv,Yv)|Coda]):-
	a(Xv,Yv,_),
	%findall(v(Xv,Yv),(vicino(Xv/Yv,Xvv/Yvv),a(Xvv,Yvv,_)),ListaSottoVicini),
	%length(ListaSottoVicini,LunghezzaSotto),
	%LunghezzaSotto > 3,
        controllo_4connection_neighbors(Coda).


