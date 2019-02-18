
/*
 * Titolo:       impronta
 * Autore:       Aldo Franco Dragoni
 * Creato:	 14 dicembre 2018
 * Linguaggio:	 SWI Prolog
 * Status:       1.0
 * Descrizione: programma base per caricare ed analizzare impronte
 * digitali in formato binario assottigliate da file bitmap
 */


 :- dynamic(a/3).

% apre una finestra e vi disegna l'impronta contenuta nel file.bmp
% ?- disegna_impronta('fingprintbin.bmp', @a).
disegna_impronta(FileName, Finestra) :- % FileName e Finestra istanziati
	new(@impronta, picture('Impronta Digitale')),%carica l'impronta
	%new(Finestra, picture('Impronta Digitale')), %genera finestra
	new(Finestra, @impronta),%genera finestra con impronta
	send(Finestra, size, size(600 , 800)), % ne specifica dimensione
	send(Finestra, open), % apre finestra
	esamina_bmp(FileName,Stream,DimensioneImmagine,Larghezza),
	carica_bmp(Finestra,Stream,DimensioneImmagine,Larghezza),
        correggi_impronta(Finestra),
	false_minutiae(_,_).


% visualizza a schermo i parametri del file.bmp caricato e restituisce:
% IS: stream di input associato al FileName
% DimensioneImmagine: numero bytes usati per rappresentare l'immagine
% Larghezza: dell'immagine in pixels (binario: 1 px - 1 bit)
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
% ?- carica_bmp((@a/picture,<stream>(0x55eab92f8410),15720,302).
carica_bmp(Finestra,IS,DimensioneImmagine,Larghezza) :-
        retractall(a(_,_,_)), % pulisce il database da eventuali precedenti elaborazioni
	divmod(Larghezza,8,Q,_), % per calcolare la successiva ...
	LarghezzaInBytesRigaImmagine is Q + 1, % .. larghezza dell'immagine in bytes
	larghezzaInBytesRigaFile(LarghezzaInBytesRigaImmagine,LarghezzaInBytesRigaFile),
	carica_impronta(Finestra,IS,1,DimensioneImmagine,Larghezza,LarghezzaInBytesRigaImmagine,LarghezzaInBytesRigaFile,1,-1).

% in un file *.bmp ogni linea di pixel dell'immagine deve essere
% descritta mediante un numero totale di bytes multiplo di 4. Se non è
% questo il caso, la linea deve essere completata con degli 0 in modo da
% rispettarne il criterio appena indicato. Quindi questo predicato
% prende in input la presunta LarghezzaRigaImmagine in bytes
% e restituisce la vera LarghezzaRigaFile in bytes relativa ad una riga
% dell'immagine
larghezzaInBytesRigaFile(LarghezzaRigaImmagine,LarghezzaRigaFile) :-
	LarghezzaRigaFile is LarghezzaRigaImmagine + 1,
	divmod(LarghezzaRigaFile,4,_,0), !.
larghezzaInBytesRigaFile(LarghezzaRigaImmagine,LarghezzaRigaFile) :-
	LarghezzaRigaFile is LarghezzaRigaImmagine + 2,
	divmod(LarghezzaRigaFile,4,_,0), !.
larghezzaInBytesRigaFile(LarghezzaRigaImmagine,LarghezzaRigaFile) :-
	LarghezzaRigaFile is LarghezzaRigaImmagine + 3,
	divmod(LarghezzaRigaFile,4,_,0), !.
larghezzaInBytesRigaFile(LarghezzaRigaImmagine,LarghezzaRigaImmagine).

% carica_impronta(+Finestra,+Stream,+PosIn,+PosFin,+Larg,+LargInBytesRigaImg,+LargInBytesRigaFile,+X0,+Y0)
% carica l'impronta digitale come database prolog di fatti del tipo
% a(X,Y) dove a(X,Y) significa che il pixel di coordinate X ed Y è nero
% leggendo i dati da +Stream a partire dalla posizione +PosIn fino alla
% posizione +PosFin, assegnando le coordinate X ed Y tenendo conto delle
% varie larghezze calcolate precedentemente e del fatto che l'inizio
% dello spazio cartesiano è alle coordinate X0 ed Y0
% inoltre il predicato produce un oggetto grafico in corrispondenza di
% ogni pixel e lo disegna sulla Finestra
carica_impronta(_,_,PosFin,PosFin,_,_,_,_,_) :-!.
carica_impronta(Finestra,Stream,PosIn,PosFin,Larghezza,LarghezzaInBytesRigaImmagine,LarghezzaInBytesRigaFile,X0,Y0) :-
	informativo(PosIn,LarghezzaInBytesRigaFile,LarghezzaInBytesRigaImmagine), % è un byte significativo?
	!,
	get_byte(Stream, Byte),
	Pos is PosIn + 1,
	processa(Finestra,Byte,128,Larghezza,X0,Y0,X,Y), % genera i fatti a(X,Y,Ref) e disegna i corrispondenti oggetti
        carica_impronta(Finestra,Stream,Pos,PosFin,Larghezza,LarghezzaInBytesRigaImmagine,LarghezzaInBytesRigaFile,X,Y).

carica_impronta(Finestra,Stream,PosIn,PosFin,Larghezza,LarghezzaInBytesRigaImmagine,LarghezzaInBytesRigaFile,X,Y) :-
	get_byte(Stream, _),
	Pos is PosIn + 1,
        carica_impronta(Finestra,Stream,Pos,PosFin,Larghezza,LarghezzaInBytesRigaImmagine,LarghezzaInBytesRigaFile,X,Y).

% informativo(+PosIn,+LarghezzaInBytesRigaFile,+LarghezzaInBytesRigaImmagine),
% è true se e solo se quello in PosIn è un byte significativo
informativo(_,L,L) :-!.
informativo(PosIn,LarghezzaInBytesRigaFile,LarghezzaInBytesRigaImmagine) :-
	divmod(PosIn,LarghezzaInBytesRigaFile,_,Resto),
	Resto \== 0,
	Resto =< LarghezzaInBytesRigaImmagine.

% processa(+Finestra,+Byte,128,Larghezza,X0,Y0,X,Y),
% dato il Byte genera i fatti a(X,Y,Ref) corrispondenti ai suoi bits
% e disegna i corrispondenti oggetti grafici Ref sulla Finestra
processa(_,_,0.5,_,X,Y,X,Y).
processa(_,_,_,Larghezza,Xc,Yc,1,Y) :-
	Xc > Larghezza, % è finita la riga quindi ..
	!,
	Y is Yc - 1. % .. si cambia riga
processa(Finestra,Numero,Base,Larghezza,Xc,Yc,X,Y) :-
	A is (Numero /\ Base)/Base,
	(   A==0, !,
	    XC is Xc*4, YC is Yc*4,
	    new(Ref, box(4,4)),
	    send(Ref, fill_pattern, colour(black)),
	    send(Finestra,display,Ref,point(XC,YC)),
	    assert(a(Xc,Yc,Ref))
	;
	   true
	),
	NXc is Xc + 1,
	NuovaBase is Base / 2,
	processa(Finestra,Numero,NuovaBase,Larghezza,NXc,Yc,X,Y).

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

colora_lista([],_).
colora_lista([H|T],Colore) :-
	send(H,colour(Colore)),
	send(H,fill_pattern(Colore)),
	colora_lista(T,Colore).

dimensioni_impronta(Immagine,Altezza,Larghezza) :-
	get(Immagine,height,Altezza),
	get(Immagine,width,Larghezza).
/*
colorapixel(Ref,Colore) :-
	send(Ref, colour, colour(Colore)),
	send(Ref, fillpattern, colour(Colore)).
*/





















