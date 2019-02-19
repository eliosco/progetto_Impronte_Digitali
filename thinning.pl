/*
 * Titolo:       thinning
 * Autore:       Team Intelligenza Artificale
 * Creato:	 18 febbraio 2019
 * Linguaggio:	 SWI Prolog
 * Status:       1.0
 * Descrizione:  funzionalità per perfezionamento del thinning
 * dell'impronta
 */

% Predicato per migliorare il thinning di base dell'impronta, inserendo
% preventivamente pixel laddove vi erano spazi bianchi verticali od
% orizzonali, al fine di assottigliarla nel miglior modo possibile
correggi_impronta(Finestra):-
	riempi_spazi_bianchi(Finestra),
	thinning(Finestra),
	riempi_spazi_bianchi(Finestra),
	thinning(Finestra),
	perfezionamento(Finestra).

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

% NOTA: PER PULIRE MAGGIORMENTE L'IMMAGINE QUANDO SI INDIVIDUERANNO
% FALSE MINUZIE AD UNA DISTANZA UGUALE A ZERO, SOSTITUIRE CON UNA SERIE
% DI PIXEL CONTIGUI. :)


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

