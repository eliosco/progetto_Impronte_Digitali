/*
 * Titolo:       improntagrey.pl
 * Autore:       Aldo Franco Dragoni
 * Creato:	 25 gennaio 2019
 * Linguaggio:	 SWI Prolog
 * Status:       1.0
 * Descrizione: programma base per caricare ed analizzare impronte
 * digitali da file bitmap ad 8 bits;
 * ho inserito un parametro "Soglia" che deve variare fra 0 (nero) e
 * 255 (bianco); serve per limtare la dimensione del database caricando
 * e renderizzando solo i pixels che hanno un'intensità di grigio
 * inferiore a Soglia (ovvero sono abbastanza scuri)
 */

 :- dynamic(a/4).

% apre una finestra e vi disegna l'impronta contenuta nel file.bmp
% es:
% ?- disegna_impronta('AN123YUQ3055.11.bmp', @a, 127).
disegna_impronta(FileName, Finestra, Soglia) :- % FileName e Finestra istanziati
	new(Finestra, picture('Impronta Digitale')), % genera finestra
	send(Finestra, size, size(500, 800)), % ne specifica dimensione
	send(Finestra, open), % apre finestra
	esamina_bmp(FileName,Stream,DimensioneImmagine,Larghezza),
	carica_bmp(Finestra,Stream,Soglia, DimensioneImmagine,Larghezza).

% visualizza a schermo i parametri del file.bmp caricato e restituisce:
% IS: stream di input associato al FileName
% DimensioneImmagine: numero bytes usati per rappresentare l'immagine
% Larghezza: dell'immagine in pixels, ovvero in bytes
% es:
% ?- esamina_bmp('fingprintbin.bmp',IS,DimensioneImmagine,Larghezza).
esamina_bmp(FileName,IS,DimensioneImmagine,Larghezza) :-
	open(FileName, read, IS,[encoding(octet)]),
	seek(IS, 0, bof, _),
	get_char(IS, Char1),get_char(IS, Char2),
	write('Formato del file ...: '),write(Char1), write(Char2),nl,
	readInt32(IS,Dim),
	write('Dimensione file ....: '),write(Dim), nl,
	seek(IS, 10, bof, _), readInt32(IS,Offset),
	write('Offset......... ....: '),write(Offset), nl,
	seek(IS, 14, bof, _), readInt32(IS,DimTit),
	write('Dimensione Titolo...: '),write(DimTit), nl,
	seek(IS, 18, bof, _), readInt32(IS,Larghezza),
	write('Larghezza...........: '),write(Larghezza), nl,
	seek(IS, 22, bof, _), readInt32(IS,Altezza),
        write('Altezza.............: '),write(Altezza), nl,
	seek(IS, 28, bof, _), readInt16(IS,Profondità),
	write('Profondità..........: '),write(Profondità), nl,
	seek(IS, 30, bof, _), readInt16(IS,Compressione),
	write('Compressione........: '),write(Compressione), nl,
%	seek(IS, 34, bof, _), readInt32(IS,DimensioneImmagine),
        DimensioneImmagine is Dim - Offset,
	write('Dimensione Immagine.: '),write(DimensioneImmagine), nl,
	seek(IS, 38, bof, _), readInt32(IS,RisOrizzontale),
	write('Risoluz. Orizzontale: '),write(RisOrizzontale), nl,
	seek(IS, 42, bof, _), readInt32(IS,RisVerticale),
	write('Risoluz. Verticale..: '),write(RisVerticale), nl,
	seek(IS, 46, bof, _), readInt32(IS,ColoriPalette),
	write('Colori Palette......: '),write(ColoriPalette), nl,
	seek(IS, 50, bof, _), readInt32(IS,SignificativiPalette),
	write('Colori Importanti...: '),write(SignificativiPalette), nl,
        seek(IS, Offset, bof, _). % setta il puntatore al primo byte dell'immagine

% disegna nella Finestra l'impronta digitale letta dallo stream IS
% ovvero i successivi DimensioneImmagine bytes organizzati in righe di
% Larghezza pixels ciascuna
% es:
% ?- carica_bmp((@a/picture, <stream>(0x55eab92f8410), 127, 15720, 302).
carica_bmp(Finestra,IS,Soglia, DimensioneImmagine,Larghezza) :-
        retractall(a(_,_,_,_)), % pulisce il database da eventuali precedenti elaborazioni
	carica_impronta(Finestra,IS,Soglia,1,DimensioneImmagine,Larghezza,1,-1).

% carica_impronta(+Finestra,+Stream,+Soglia,+PosIn,+PosFin,+Larghezza,+X0,+Y0)
% carica l'impronta digitale come database prolog di fatti del tipo
% a(X,Y,C,Ref) dove a(X,Y,C,Ref) significa che il pixel di coordinate X
% ed Y ha colore C ed è associato all'oggetto grafico Ref, leggendo i
% dati da +Stream a partire dalla posizione +PosIn fino alla posizione
% +PosFin, assegnando le coordinate X ed Y tenendo conto della Larghezza
% e del fatto che l'inizio dello spazio cartesiano è alle coordinate X0
% ed Y0; inoltre il predicato genera un oggetto grafico in
% corrispondenza di ogni pixel e lo disegna sulla Finestra
carica_impronta(_,_,_,PosFin,PosFin,_,_,_) :-!.
carica_impronta(Finestra,Stream,Soglia,PosIn,PosFin,Larghezza,X0,Y0) :-
	get_byte(Stream, Byte),
	Pos is PosIn + 1,
	processa(Finestra,Soglia,Byte,Larghezza,X0,Y0,X,Y), % genera i fatti a(X0,Y0,Colore,Ref) e disegna i corrispondenti oggetti
        carica_impronta(Finestra,Stream,Soglia, Pos,PosFin,Larghezza,X,Y).

% processa(+Finestra,+Soglia,+Byte,Larghezza,Xc,Yc,X,Y),
% dato il Byte ovvero il Colore letto, genera il fatto
% a(Xc,Yc,Colore,Ref) corrispondente e disegna il corrispondente oggetto
% grafico Ref sulla Finestra
processa(Finestra,Soglia, Numero,Larghezza,Xc,Yc,X,Yc) :-
	Xc < Larghezza, % il pixel non è ultimo sulla riga
	Numero < Soglia, % il pixel è significativo
	Grado is round(Numero/255 * 100), % scaliamo il tono di grigio su una scala a 100
	atom_number(Atomo,Grado), % convertiamo il numero in sequenza di ASCII
	atom_concat('grey',Atomo,Grigio), % concateniamo la sequenza a "grey"
	send(Finestra,display,new(Ref,line(0)),point(Xc,Yc)), % genera un oggetto pixel alle coordinate Xc, Yc
	send(Ref, colour, colour(Grigio)), % e gli dà il colore Grigio
	assert(a(Xc,Yc,Numero,Ref)), % si asserisce del DB PROLOG il fatto a(Xc,Yc,Numero,Ref)
	X is Xc + 1. % si aggiorna l'ascissa pel prossimo pixel
processa(_,Soglia,Numero,Larghezza,Xc,Yc,X,Yc) :-
	Numero >= Soglia,  % il pixel non è significativo perché supera la Soglia
	Xc < Larghezza, % e non è ultimo sulla riga
	X is Xc + 1. % si aggiorna l'ascissa pel prossimo pixel e nient'altro
processa(Finestra,Soglia, Numero,Larghezza,Larghezza,Yc,1,Y) :- % è ultimo sulla riga
        Numero < Soglia, % il pixel è significativo
	Grado is round(Numero/255 * 100),
	atom_number(Atomo,Grado),
	atom_concat('grey',Atomo,Grigio),
	send(Finestra,display,new(Ref,line(0)),point(Larghezza,Yc)), % genera un oggetto pixel ..
	send(Ref, colour, colour(Grigio)), % .. alle coordinate Larghezze,Yc e gli si dà il colore Grigio
	assert(a(Larghezza,Yc,Numero,Ref)), % si asserisce del DB PROLOG il fatto a(Larghezza,Yc,Numero,Ref)
	Y is Yc - 1. % il prossimo pixel sarà all'ascissa 1 della riga successiva
processa(_, Soglia,Numero, Larghezza,Larghezza,Yc,1,Y) :- % è ultimo sulla riga e
	Numero >= Soglia,  % il pixel non è significativo
	Y is Yc - 1.  % il prossimo pixel sarà all'ascissa 1 della riga successiva

readInt32(IS, Number) :-
    get_byte(IS, B0),
    get_byte(IS, B1),
    get_byte(IS, B2),
    get_byte(IS, B3),
    Number is B0 + B1<<8 + B2<<16 + B3<<24.

readInt16(IS, Number) :-
    get_byte(IS, B0),
    get_byte(IS, B1),
    Number is B0 + B1<<8.


