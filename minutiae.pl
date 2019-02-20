/*
 * Titolo:       minutiae
 * Autore:       Aldo Franco Dragoni - Team Intelligenza Artificale
 * Creato:	 14 dicembre 2018
 * Linguaggio:	 SWI Prolog
 * Status:       1.0
 * Descrizione:  funzionalitÃ  determinare le minuzie all'interno
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


% predicato per individuare le terminazioni interne all'impronta
terminazione(X,Y,Ref) :-
	a(X,Y,Ref),
	findall(v(X,Y),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),Vicini),
        length(Vicini,1),
	findall(v(X,Y),terminazioni_esterne_dx(X,Y),Ter_dx),
	findall(v(X,Y),terminazioni_esterne_sx(X,Y),Ter_sx),
	length(Ter_dx,L_dx),
	L_dx>0,
	length(Ter_sx,L_sx),
	L_sx>0,
	send(Ref, colour, colour(green)),
	send(Ref, fill_pattern, colour(green)).

terminazioni_esterne_dx(X,Y) :-
            a(Xv,Y,_),
            Xv > X .

terminazioni_esterne_sx(X,Y) :-
	    a(Xv,Y,_),
            Xv < X .

trova_tratti(X1) :-
	findall(t(X,Y),(terminazione(X,Y,_),tratto(t(X,Y),[],0)),Tratti),
	length(Tratti,X),
	X1 is X/2.

tratto(t(X,Y),Tratti,Acc) :-
	Acc =< 10,
	a(X,Y,Ref),
	calcolo_vicini(t(X,Y),N),
	N < 3,
	vicino(X/Y,Xv/Yv),
	a(Xv,Yv,_),
        \+ member(t(Xv,Yv),Tratti),
	Acc1 is Acc +1,
	!,
	tratto(t(Xv,Yv),[t(X,Y)|Tratti],Acc1),
	send(Ref, colour, colour(green)),
	send(Ref, fill_pattern, colour(green)).


tratto(t(X,Y),_,_) :-
	a(X,Y,Ref),
	terminazione(X,Y,_),
	send(Ref, colour, colour(green)),
	send(Ref, fill_pattern, colour(green)).



calcolo_vicini(t(X,Y),N) :-
	findall(t(X,Y),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),L),
	length(L,N).

tratto_di_2(A,B,C,D,Ref1,Ref2) :-
	terminazione(A,B,Ref1),
	terminazione(C,D,Ref2),
	vicino(A/B,C/D).

biforcazioni(T) :-
	findall(Bif, biforcazione(Bif), Biforcazioni),
	length(Biforcazioni,T).

biforcazione(Bif2) :-
	a(X,Y,Ref),
	bif(X,Y,Bif),
	append(Bif,[Ref],Bif2),
	%new(Colore,colour(red)),
        %send(Ref,colour,colour(red)),
	%send(Ref,colour(colour(red))),
	%send(Ref,fill_pattern(colour(red))),
	colora_lista(Bif2,colour(red)).

%pattern 1
bif(X,Y,Bif) :-
	%a(X,Y,Ref0),
	X1 is X-1,
	Y1 is Y-1,
	%X2 is X,
	%Y2 is Y-1,
	%\+ a(X2,Y2,_),
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
	%X8 is X,
	%Y8 is Y+1,
	%\+ a(X8,Y8,_),
	X9 is X+1,
	Y9 is Y+1,
        a(X9,Y9,Ref3),
        Bif = [Ref1,Ref2,Ref3].

%pattern 3
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	%X4 is X-1,
	%Y4 is Y,
	%\+ a(X4,Y4,_),
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
	%X6 is X+1,
	%Y6 is Y,
	%\+ a(X6,Y6,_),
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
	X5 is X+1,
	Y5 is Y,
	\+ a(X5,Y5,_),
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
	X5 is X+1,
	Y5 is Y,
	\+ a(X5,Y5,_),
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
	X5 is X+1,
	Y5 is Y,
	\+ a(X5,Y5,_),
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
	X5 is X+1,
	Y5 is Y,
	\+ a(X5,Y5,_),
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
/*
laghi(T) :-
	findall(Lag, lago(Lag), Laghi),
	length(Laghi,T).

lago(Lag) :-
	a(X,Y,Ref),
	append([],[l(X,Y,Ref)],Lag),
	lag([l(X,Y,Ref)],Lag),
        %send(Ref,fill_pattern(colour(red))),
	%send(Ref,colour(colour(red))).
lag([],_).
lag([l(X,Y,Ref)|T],Lag) :-
	findall(l(Xv,Yv,Ref),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),Vicini),
	(
	lag_vicini(Vicini,Lag),
	append(Lag,Vicini,NuovoLag),
	lag(Vicini,NuovoLag)
	;
	send(Ref,colour(colour(green))),
	send(Ref,fill_pattern(colour(green)))
	),
	lag(T,NuovoLag).


lag_vicini([],_).
lag_vicini([H|T],Lag) :-
	\+ member(H,Lag),
	lag_vicini(T,Lag).*/

/*
laghi(T) :-
	findall(Lago, lago(Lago), Laghi),
	length(Laghi,T).

lago(Lago) :-
	a(X,Y,_),
	lag(l(X,Y),[],l(X,Y),Lago).

lag(l(Xi,Yi),Lag,l(X,Y),[l(X,Y)|Lag]) :- s(l(X,Y),l(Xi,Yi)).
lag(l(Xi,Yi),Lag,l(X,Y),Lago) :-
	findall(l(Xn,Yn),s(l(X,Y),l(Xn,Yn)),Vicini),
        member(l(Xv,Yv),Vicini),
	\+ member(l(Xv,Yv),Lag),
	lag(l(Xi,Yi),[l(X,Y)|Lag],l(Xv,Yv),Lago).

s(l(X,Y),l(Xv,Yv)) :-
	a(Xv,Yv,_),
	vicino(X/Y,Xv/Yv).
*/
%#######False minutiae##############
/*Predicato che individua le false minutiae dapprima nelle coppie
 * biforcazioni/terminazioni, poi nelle coppie di biforcazioni
 * ed infine nelle coppie di terminazioni.
 * Effettuata l'eliminazione delle false minuziae evidenzia
 * sull'impronta disegnata le terminazioni e le biforcazioni
 * rimanenti restituendone il numero.
*/
false_minutiae(T,B):-
	trova_minutiae_biforc_term,
	trova_minutiae_biforcazioni,
	trova_minutiae_terminazioni,
	terminazioni(T),
	biforcazioni(B).

% innanzitutto ho bisogno di un predicato che calcoli la distanza tra
% due minutie qualsiasi(due biforcazioni, due terminazioni, una bif
% una terminazione).
distanza_minutiae(Xa/Ya,Xb/Yb,Distanza):-
	Xdiff is Xb-Xa,
	Ydiff is Yb-Ya,
	XQ is Xdiff^2,
	YQ is Ydiff^2,
	Dist is XQ+YQ,
	Distanza is sqrt(Dist).
/*dopodiché abbiamo creato un predicato che esamini le coppie di
 * terminazioni ed elimina quelle che distano meno di 6 pixel e
 * sono quindi catalogate come false minutiae
 * */

% di seguito mi occorre calcolare la distanza media tra due creste D,
% che si ottiene riga per riga:
% 1-scannerizzando la riga e sommando tutti i pixel il cui valore Ã¨
% 1(neri)
% 2- Divido la lunghezza della riga per la somma ottenuta, il risultato
% sarÃ  D per quella riga.
% 3- Ripeto procedimento per tutte le righe e faccio la media per
% ottenere la distanza media tra due creste D(average inter-rigde
% width).
%
% Per ora metto D=6
trova_minutiae_terminazioni :-
	findall(t(X,Y),trova_false_terminazioni(t(X,Y),t(_,_)),_).

trova_false_terminazioni(t(X1,Y1),t(X2,Y2)):-
	terminazione(X1,Y1,_),
	terminazione(X2,Y2,_),
	X1\=X2,
	Y1\=Y2,
	distanza_minutiae(X1/Y1,X2/Y2,Distanza),
	Distanza =<6,
	retract(a(X1,Y2,_)),
	retract(a(X2,Y2,_)).

%facciamo stessa cosa per due biforcazioni
trova_minutiae_biforcazioni :-
	findall(t(X,Y,Bif),trova_false_biforcazioni(t(X,Y,Bif),t(_,_,_)),_).

trova_false_biforcazioni(t(X1,Y1,Bif),t(X2,Y2,Bif2)):-
	biforcazionecoordinate(X1,Y1,Bif),
	biforcazionecoordinate(X2,Y2,Bif2),
	X1\=X2,
	Y1\=Y2,
	Bif\=Bif2,
	distanza_minutiae(X1/Y1,X2/Y2,Distanza),
	Distanza=<6,
	retract(a(X1,Y1,_)),
	retract(a(X2,Y2,_)).

%facciamo stessa cosa per una biforcazione e una terminazione
trova_minutiae_biforc_term :-
	findall(t(X,Y,Bif),trova_false_bt(t(X,Y,Bif),t(_,_)),_).

trova_false_bt(t(X1,Y1,Bif),t(X2,Y2)):-
	biforcazionecoordinate(X1,Y1,Bif),
	terminazione(X2,Y2,_),
	X1\=X2,
	Y1\=Y2,
	distanza_minutiae(X1/Y1,X2/Y2,Distanza),
	Distanza=<6,
	retract(a(X1,Y1,_)),
	retract(a(X2,Y2,_)).

biforcazionecoordinate(X,Y,Bif) :-
	a(X,Y,_),
	bif(X,Y,Bif).


%%% CALCOLO D %%%%
% D rappresenta la distanza media tra due creste vicine e parallele. 
% attraverso un algoritmo, per calcolare D basta:
% 1-scannerizzando la riga e sommando tutti i pixel il cui valore Ã¨
% 1(neri)
% 2- Divido la lunghezza della riga per la somma ottenuta, il risultato
% sarÃ  D per quella riga.
% per la lunghezza della riga Ã¨ stata considerata la distanza tra il primo pixel nero che si trova nella riga e l ultimo
% 3- Ripeto procedimento per tutte le righe e faccio la media per
% ottenere la distanza media tra due creste D(average inter-rigde
% width).

calcolo_D(D) :-
	calcolo_punti_estremi(Xs,Xd,Yb,Ya), 
	somma_riga(Xs,Yb,Xd,Ya,ListaSommaI,ListaXiXf), % restituisce una lista con le somme per ogni riga
	calcola_lung_riga(ListaXiXf,ListaLunghezzaRiga),
	NumeroRighe is -(Ya-Yb),
	dividi_D(ListaLunghezzaRiga,ListaSommaI,ListaDI),
	somma_li(ListaDI,DSomma),
	D is DSomma/NumeroRighe.


% serve per definire lo spazio dell immagine in cui si trova l impronta
calcolo_punti_estremi(XS,XD,YB,YA) :-
	calcolo_x_sx(0,XS),
	calcolo_x_dx(302,XD), % 302 Ã¨ la lunghezza massima dell impronta
	calcolo_y_bs(0,YB),
	calcolo_y_al(-393,YA), % -393 Ã¨ l altezza massima dell impronta
	!.

% parto da un X=0, tento a(0,_,_), se matcha redtituisce X=0, se non
% matcha incrementa la X di 1, finche non matcha con qualche a(X,_,_) e
% restituisce quell X
calcolo_x_sx(X,X) :-
	a(X,_,_),
	!.
calcolo_x_sx(X,Xv) :-
	\+ a(X,_,_),
	X1 is X+1,
	calcolo_x_sx(X1,Xv),
	!.

% si parte dal punto piu estremo (302) e si decrementa il valore di X finche non si trova 
% un matching
calcolo_x_dx(X,X) :-
	a(X,_,_),
	!.
calcolo_x_dx(X,Xv) :-
	\+ a(X,_,_),
	X1 is X-1,
	calcolo_x_dx(X1,Xv),
	!.

% si parte da Y=0 e si decrementa il suo valore finche non si ha un matching
calcolo_y_bs(Y,Y) :-
	a(_,Y,_),
	!.
calcolo_y_bs(Y,Yv) :-
	\+ a(_,Y,_),
	Y1 is Y-1,
	calcolo_y_bs(Y1,Yv),
	!.

% si parte dal punto piu estremo(-393) e si incrementa finche non si ha un matching
calcolo_y_al(Y,Y) :-
	a(_,Y,_),
	!.
calcolo_y_al(Y,Yv) :-
	\+ a(_,Y,_),
	Y1 is Y+1,
	calcolo_y_al(Y1,Yv),
	!.


% calcola la lunghezza di ogni riga a partire da una lista formata da
% elementi Xi/Xf dove sono rispettivamente il primo X in cui si Ã¨ avuto
% un matching con una certa a(X,_,_) e l ultimo X
% quindi si calcola la lunghezza della riga che Ã¨ la differenza tra Xf e
% Xi e la si restituisce in una lista che andra a contenere tutte le
% lunghezze delle righe
calcola_lung_riga([],[]) :-
	!.
calcola_lung_riga([Xi/Xf|C],[Lung|C1]) :-
	Lung is Xf-Xi,
	calcola_lung_riga(C,C1),
	!.


% divide la lunghezza di ogni riga per la somma dei pixel neri di quella
% riga e restituisce una lista formata da queste divisioni, una per ogni
% riga
% la lunghezza di ogni riga Ã¨ una lista di lunghezze
dividi_D([],[],[]) :-
	!.
dividi_D([0|C2],[0|C],[0|C1]) :-
	dividi_D(C2,C,C1),
	!.
dividi_D([T2|C2],[T|C],[T1|C1]) :-
	T1 is T2/T,
	dividi_D(C2,C,C1),
	!.

% somma gli elementi di una lista
somma_li([],0) :-
    !.
somma_li([T|C],S) :-
    somma_li(C,S1),
    S is S1 + T.


% scorre tutte le righe dell impronta, restituendo una lista con le
% somme dei pixel neri per ogni riga
% inoltre restituisce una lista del tipo Xi/Xf in cui Xi Ã¨ il primo X
% con il pixel nero della riga e Xf Ã¨ l ultimo
somma_riga(X,Y,_,Ya,[],[]) :-
	\+ a(X,Y,_),
	Y < Ya,
	!.
somma_riga(X,Y,Xd,Ya,[SommaRiga|CodaSomme],[Xi/Xf|C]) :-
	uno_riga(X,Y,Xd,SommaRiga,ListaX),
	prendi_primo(Xi,ListaX),
	prendi_ultimo(Xf,ListaX),
	Y1 is Y-1,
	somma_riga(X,Y1,Xd,Ya,CodaSomme,C),
	!.

% prende il primo elemento di una lista
% nel caso sia vuota, assegna 0 al elemento
prendi_primo(0,[]) :-
	!.
prendi_primo(T,[T|_]) :-
	!.


% prende l ultimo elemento di una lista
% nel caso in cui la lista Ã¨ vuota, assegna 0 all elemento
prendi_ultimo(0,[]) :-
	!.
prendi_ultimo(T,[T]):-
        !.
prendi_ultimo(X,[_|C]) :-
        prendi_ultimo(X,C).


% prende cordinate X Y, se il pixel corrispondente Ã¨ a 1 allora
% incrementa il valore della somma
% altrimenti se il pixel Ã¨ a 0 e la X Ã¨ <= Xd, ovvero la lunghezza dell
% impronta allora si prosegue nella ricerca del prossimo pixel,
% altrimenti se X > Xd si restituisce la somma per passare alla riga
% successiva
% dove Xd Ã¨ la X piu estrema di destra = 281
uno_riga(X1,Y,Xd,0,[]) :-
	\+ a(X1,Y,_),
	X1 > Xd,
	!.
uno_riga(X1,Y,Xd,S,C) :-
	\+ a(X1,Y,_),
        X1 =< Xd,
	X2 is X1+1,
	uno_riga(X2,Y,Xd,S,C),
	!.
uno_riga(X1,Y,Xd,S1,[X1|C]) :-
	a(X1,Y,_),
	X2 is X1+1,
        uno_riga(X2,Y,Xd,S,C),
	S1 is S+1,
	!.




















