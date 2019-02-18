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
vicino2(X/Y,Xv/Yv) :-
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

	),
	terminazioni_esterne(X,Y).

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
	%findall(_,terminazioni_esterne(X,Y),Vicini),
	length(Vicini,1),
	findall(v(X,Y),terminazioni_esterne_dx(X,Y),Ter_dx),
	findall(v(X,Y),terminazioni_esterne_sx(X,Y),Ter_sx),
	length(Ter_dx,L_dx),
	L_dx>1,
	length(Ter_sx,L_sx),
	L_sx>1,
	send(Ref, colour, colour(red)).

%terminazioni_esterne(X,_) :- X=0; X=302.

terminazioni_esterne_dx(X,Y) :-
            a(Xv,Y,_),
            Xv > X .

terminazioni_esterne_sx(X,Y) :-
	 a(Xv,Y,_),
            Xv < X .






tratto_di_2(A,B,C,D,Ref1,Ref2) :-
	terminazione(A,B,Ref1),
	terminazione(C,D,Ref2),
	vicino(A/B,C/D).

% Predicato per migliorare il thinning di base dell'impronta, inserendo
% preventivamente pixel laddove vi erano spazi bianchi verticali od
% orizzonali, al fine di assottigliarla nel miglior modo possibile
correggi_impronta(Finestra):-
	riempi_spazi_bianchi(Finestra),
	thinning(Finestra),
	riempi_spazi_bianchi(Finestra),
	thinning(Finestra),
	perfezionamento(Finestra).

% Predicato di riconoscimento dei pattern da correggere all'interno
% dell'immagine bitmap localizzati in finestre 3x3 pixels
thinning(Finestra):-
	findall(X/Y,canc_T_up(X,Y,_,Finestra),_),
	findall(X/Y,canc_T_down(X,Y,_,Finestra),_),
	findall(X/Y,canc_T_dx(X,Y,_,Finestra),_),
	findall(X/Y,canc_T_sx(X,Y,_,Finestra),_),
	findall(X/Y,canc_L1(X,Y,_,Finestra),_),
	findall(X/Y,canc_L2(X,Y,_,Finestra),_),
	findall(X/Y,canc_L3(X,Y,_,Finestra),_),
	findall(X/Y,canc_L4(X,Y,_,Finestra),_).

%|_|_|_|
%| |X| |
%|X|X|X|
canc_T_up(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(X,Yd,_),
	a(Xdx,Yd,_),
	a(Xsx,Yd,_),
	\+ a(X,Yu,_),
	\+ a(Xdx,Yu,_),
	\+ a(Xsx,Yu,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%|X|X|X|
%| |X| |
%|_|_|_|
canc_T_down(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(X,Yu,_),
	a(Xdx,Yu,_),
	a(Xsx,Yu,_),
	\+ a(X,Yd,_),
	\+ a(Xdx,Yd,_),
	\+ a(Xsx,Yd,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%|X| |_|
%|X|X|_|
%|X| |_|
canc_T_dx(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(Xsx,Y,_),
	a(Xsx,Yu,_),
	a(Xsx,Yd,_),
	\+ a(Xdx,Y,_),
	\+ a(Xdx,Yu,_),
	\+ a(Xdx,Yd,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%|_| |X|
%|_|X|X|
%|_| |X|
canc_T_sx(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(Xdx,Y,_),
	a(Xdx,Yu,_),
	a(Xdx,Yd,_),
	\+ a(Xsx,Y,_),
	\+ a(Xsx,Yu,_),
	\+ a(Xsx,Yd,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%| |X| |
%|_|X|X|
%|_|_| |
canc_L1(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(Xdx,Y,_),
	a(X,Yu,_),
	\+ a(Xsx,Y,_),
	\+ a(Xsx,Yd,_),
	\+ a(X,Yd,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%| |X| |
%|X|X|_|
%| |_|_|
canc_L2(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(Xsx,Y,_),
	a(X,Yu,_),
	\+ a(Xdx,Y,_),
	\+ a(Xdx,Yd,_),
	\+ a(X,Yd,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%|_|_| |
%|_|X|X|
%| |X| |
canc_L3(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(Xdx,Y,_),
	a(X,Yd,_),
	\+ a(X,Yu,_),
	\+ a(Xsx,Yu,_),
	\+ a(Xsx,Y,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%| |_|_|
%|X|X|_|
%| |X| |
canc_L4(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(Xsx,Y,_),
	a(X,Yd,_),
	\+ a(X,Yu,_),
	\+ a(Xdx,Yu,_),
	\+ a(Xdx,Y,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

% Predicato in grado di trovare ulteriori pattern da correggere
% all'interno dell'immagine bitmap
perfezionamento(Finestra):-
	findall(X/Y,perfez1(X,Y,_,Finestra),_),
	findall(X/Y,perfez2(X,Y,_,Finestra),_),
	findall(X/Y,perfez3(X,Y,_,Finestra),_),
	findall(X/Y,perfez4(X,Y,_,Finestra),_).

%|_|_|X|   |_|_| |
%|_|X|X|   |_|X|X|
%|_|_| |   |_|_|X|
perfez1(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(Xdx,Y,_),
	(   a(Xdx,Yu,_)
	;
	    a(Xdx,Yd,_)),
	\+ a(X,Yu,_),
	\+ a(Xsx,Yu,_),
	\+ a(Xsx,Y,_),
	\+ a(Xsx,Yd,_),
	\+ a(X,Yd,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%| |_|_|   |X|_|_|
%|X|X|_|   |X|X|_|
%|X|_| |   | |_|_|
perfez2(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(Xsx,Y,_),
	(   a(Xsx,Yu,_)
	;
	    a(Xsx,Yd,_)),
	\+ a(X,Yu,_),
	\+ a(Xdx,Yu,_),
	\+ a(Xdx,Y,_),
	\+ a(Xdx,Yd,_),
	\+ a(X,Yd,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%| |X|X|   |X|X| |
%|_|X|_|   |_|X|_|
%|_|_|_|   |_|_|_|
perfez3(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(X,Yu,_),
	(   a(Xdx,Yu,_)
	;
	    a(Xsx,Yu,_)),
	\+ a(Xsx,Y,_),
	\+ a(Xsx,Yd,_),
	\+ a(X,Yd,_),
	\+ a(Xdx,Yd,_),
	\+ a(Xdx,Y,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).

%|_|_|_|   |_|_|_|
%|_|X|_|   |_|X|_|
%| |X|X|   |X|X| |
perfez4(X,Y,Ref,_):-
	a(X,Y,Ref),
	Xdx is X+1,
	Xsx is X-1,
	Yu is Y-1,
	Yd is Y+1,
	a(X,Yd,_),
	(   a(Xdx,Yd,_)
	;
	    a(Xsx,Yd,_)),
	\+ a(Xsx,Y,_),
	\+ a(Xsx,Yu,_),
	\+ a(X,Yu,_),
	\+ a(Xdx,Yu,_),
	\+ a(Xdx,Y,_),
	retract(a(X,Y,Ref)),
	%send(Ref,colour,colour(red)),
	%send(Ref,fill_pattern,colour(red)).
	free(Ref).







%predicato per riempire gli spazi bianchi che creano dei buchi
riempi_spazi_bianchi(Finestra):-
	findall(v(X,Y),cerca_spazi_bianchi_orizzontali(X,Y,_, Finestra),_),
	findall(v(X,Y),cerca_spazi_bianchi_verticali(X,Y,_, Finestra),_).

riempi_spazi_bianchi_diagonali(Finestra):-
	findall(v(X,Y),cerca_spazi_bianchi_diagonali_alto_sx(X,Y,_, Finestra),_),
	findall(v(X,Y),cerca_spazi_bianchi_diagonali_alto_dx(X,Y,_, Finestra),_),
	findall(v(X,Y),cerca_spazi_bianchi_diagonali_basso_sx(X,Y,_, Finestra),_),
	findall(v(X,Y),cerca_spazi_bianchi_diagonali_basso_dx(X,Y,_, Finestra),_).

cerca_spazi_bianchi_orizzontali(X,Y,Ref,Finestra):-
	a(X,Y,Ref),
	Xdx is (X+2),
	YUp is (Y-1),
	YDown is (Y+1),
	X1 is X+1,
	(a(Xdx,Y,_)
	;
	(   a(Xdx,YUp,_),
	    \+ a(X1,YUp,_))
	;
	(   a(Xdx,YDown,_),
	    \+ a(X1,YDown,_))),
	\+ a(X1,Y,_),
	new(Ref1, box(4,4)),
	assert(a(X1,Y,Ref1)),
	send(Ref1,colour,colour(black)),
	send(Ref1,fill_pattern,colour(black)),
	send(Finestra,display,Ref1,point((X1*4),(Y*4))).

cerca_spazi_bianchi_verticali(X,Y,Ref,Finestra):-
	a(X,Y,Ref),
	YDown is (Y+2),
	Yd is Y+1,
	XSx is (X-1),
	XDx is (X+1),
	(a(X,YDown,_)
	;
	(   a(XSx,YDown,_),
	    \+ a(XSx,Yd,_))
	;
	(   a(XDx,YDown,_),
	    \+ a(XDx,Yd,_))),
	\+ a(X,Yd,_),
	new(Ref2, box(4,4)),
	assert(a(X,Yd,Ref2)),
	send(Ref2,colour,colour(black)),
	send(Ref2,fill_pattern,colour(black)),
	send(Finestra,display,Ref2,point((X*4),(Yd*4))).



elimina_pixel(X,Y) :-
	a(X,Y,Ref),
	send(Ref,colour,colour(white)),
	send(Ref,fill_pattern,colour(white)),
	retract(a(X,Y,Ref)).

% NOTA: PER PULIRE MAGGIORMENTE L'IMMAGINE QUANDO SI INDIVIDUERANNO
% FALSE MINUZIE AD UNA DISTANZA UGUALE A ZERO, SOSTITUIRE CON UNA SERIE
% DI PIXEL CONTIGUI. :)

biforcazioni(T) :-
	findall(Bif, biforcazione(Bif), Biforcazioni),
	length(Biforcazioni,T).

biforcazione(Bif) :-
	a(X,Y,Ref),
	bif(X,Y,Bif),
	%new(Colore,colour(red)),
        %send(Ref,colour,colour(red)),
	send(Ref,colour(colour(red))),
	send(Ref,fill_pattern(colour(red))),
	colora_lista(Bif,colour(red)).

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

%pattern 5 pixel_riferimento=4
bif(X,Y,Bif) :-
	%X1 is X,
	%Y1 is Y-1,
	X2 is X+1,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	%X3 is X+2,
	%Y3 is Y-1,
	%X4 is X,
	%Y4 is Y,
	%X5 is X+1,
	%Y5 is Y,
	X6 is X+2,
	Y6 is Y,
	a(X6,Y6,Ref2),
	%X7 is X,
	%Y7 is Y-1,
	%X8 is X+1,
	%Y8 is Y+1,
	%X9 is X+2,
	%Y9 is Y+1,
	Bif = [Ref1,Ref2].

%pattern 6 riferimento_pixel=4
bif(X,Y,Bif) :-
	%X1 is X,
	%Y1 is Y-1,
	%X2 is X+1,
	%Y2 is Y-1,
	%X3 is X+2,
	%Y3 is Y-1,
	%X4 is X,
	%Y4 is Y,
	%X5 is X+1,
	%Y5 is Y,
	X6 is X+2,
	Y6 is Y,
	a(X6,Y6,Ref1),
	%X7 is X,
	%Y7 is Y-1,
	X8 is X+1,
	a(X8,Y8,Ref2),
	Y8 is Y+1,
	%X9 is X+2,
	%Y9 is Y+1,
	Bif = [Ref1,Ref2].

%pattern 7 riferimenti_pixel=4
bif(X,Y,Bif) :-
	%X1 is X,
	%Y1 is Y-1,
	X2 is X+1,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	%X3 is X+2,
	%Y3 is Y-1,
	%X4 is X,
	%Y4 is Y,
	%X5 is X+1,
	%Y5 is Y,
	%X6 is X+2,
	%Y6 is Y,
	%X7 is X,
	%Y7 is Y-1,
	X8 is X+1,
	Y8 is Y+1,
	a(X8,Y8,Ref2),
	%X9 is X+2,
	%Y9 is Y+1,
	Bif = [Ref1,Ref2].

%pattern 8 riferimenti_pixel=6
bif(X,Y,Bif) :-
	%X1 is X-2,
	%Y1 is Y-1,
	X2 is X-1,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	%X3 is X,
	%Y3 is Y-1,
	%X4 is X-2,
	%Y4 is Y,
	%X5 is X-1,
	%Y5 is Y,
	%X6 is X,
	%Y6 is Y,
	%X7 is X-2,
	%Y7 is Y+1,
	X8 is X-1,
	Y8 is Y+1,
	a(X8,Y8,Ref2),
	%X9 is X,
	%Y9 is Y+1,
	Bif = [Ref1,Ref2].

%pattern 9
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	%X2 is X,
	%Y2 is Y-1,
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref2),
	%X4 is X-1,
	%Y4 is Y,
	%X6 is X+1,
	%Y6 is Y,
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref3),
	%X8 is X,
	%Y8 is Y+1,
	%X9 is X+1,
	%Y9 is Y+1,
        Bif = [Ref1,Ref2,Ref3].

%pattern 10
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	%X2 is X,
	%Y2 is Y-1,
	%X3 is X+1,
	%Y3 is Y-1,
	%X4 is X-1,
	%Y4 is Y,
	%X6 is X+1,
	%Y6 is Y,
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref2),
	%X8 is X,
	%Y8 is Y+1,
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 11
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	%X2 is X,
	%Y2 is Y-1,
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref2),
	%X4 is X-1,
	%Y4 is Y,
	%X6 is X+1,
	%Y6 is Y,
	%X7 is X-1,
	%Y7 is Y+1,
	%X8 is X,
	%Y8 is Y+1,
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 12
bif(X,Y,Bif) :-
	%X1 is X-1,
	%Y1 is Y-1,
	%X2 is X,
	%Y2 is Y-1,
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref1),
	%X4 is X-1,
	%Y4 is Y,
	%X6 is X+1,
	%Y6 is Y,
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref2),
	%X8 is X,
	%Y8 is Y+1,
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern13, riferimento X2-Y2
bif(X, Y, Bif):-
	X4 is X-1,
	Y4 is Y+1,
	X6 is X+1,
	Y6 is Y+1,
	X7 is X-1,
	Y7 is Y+2,
	a(X4, Y4, Ref1),
	a(X6, Y6, Ref2),
	a(X7, Y7, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern14, riferimento X2-Y2
bif(X, Y, Bif):-
	X4 is X-1,
	Y4 is Y+1,
	X6 is X+1,
	Y6 is Y+1,
	X9 is X+1,
	Y9 is Y+2,
	a(X4, Y4, Ref1),
	a(X6, Y6, Ref2),
	a(X9, Y9, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern15, riferimento X8-Y8
bif(X, Y, Bif):-
	X1 is X-1,
	Y1 is Y-2,
	X4 is X-1,
	Y4 is Y-1,
	X6 is X+1,
	Y6 is Y-1,
	a(X1, Y1, Ref1),
	a(X4, Y4, Ref2),
	a(X6, Y6, Ref3),
	Bif = [Ref1,Ref2,Ref3].
%pattern16, riferimento X8-Y8
bif(X, Y, Bif):-
	X3 is X+1,
	Y3 is Y-2,
	X4 is X-1,
	Y4 is Y-1,
	X6 is X+1,
	Y6 is Y-1,
	a(X3, Y3, Ref1),
	a(X4, Y4, Ref2),
	a(X6, Y6, Ref3),
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


%pattern21, riferimento X2-Y2
bif(X, Y, Bif):-
 /* coordinate:
        X1 is X-1,
	Y1 is Y,
	X3 is X+1,
	Y3 is Y,
	X4 is X-1,
	Y4 is Y+1,
	X5 is X,
	Y5 is Y+1,
	X6 is X+1,
	Y6 is Y+1,
	X7 is X-1,
	Y7 is Y+2,
	X8 is X,
	Y8 is Y+2,
	X9 is X+1,
	Y9 is Y+2 */
	X6 is X+1,
	Y6 is Y+1,
	X7 is X-1,
	Y7 is Y+2,
	X8 is X,
	Y8 is Y+2,
	a(X6, Y6, Ref1),
	a(X7, Y7, Ref2),
	a(X8, Y8, Ref3),
	Bif = [Ref1,Ref2,Ref3].


%pattern22, riferimento X2-Y2
bif(X, Y, Bif):-
	X1 is X-1,
	Y1 is Y,
	X6 is X+1,
	Y6 is Y+1,
	X8 is X,
	Y8 is Y+2,
	a(X1, Y1, Ref1),
	a(X6, Y6, Ref2),
	a(X8, Y8, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern23, riferimento X2-Y2
bif(X, Y, Bif):-
	X3 is X+1,
	Y3 is Y,
	X4 is X-1,
	Y4 is Y+1,
	X8 is X,
	Y8 is Y+2,
	a(X3, Y3, Ref1),
	a(X4, Y4, Ref2),
	a(X8, Y8, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern24, riferimento X2-Y2
bif(X, Y, Bif):-
	X4 is X-1,
	Y4 is Y+1,
	X8 is X,
	Y8 is Y+2,
	X9 is X+1,
	Y9 is Y+2,
	a(X4, Y4, Ref1),
	a(X8, Y8, Ref2),
	a(X9, Y9, Ref3),
	Bif = [Ref1,Ref2,Ref3].


eliminatutto :-
	a(X,Y,Ref),
	retract(a(X,Y,Ref)),
	free(Ref).













