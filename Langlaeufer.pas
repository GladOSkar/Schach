unit Langlaeufer;

interface

uses StdCtrls,SysUtils,Graphics,Schachfigur,Types;

//type
//  TMatrix = array[1..8] of array[1..8] of Byte;

type TLanglaeufer = class(TSchachfigur)
 public
  vertikalhorizontal:Boolean;
  diagonal:Boolean;
  procedure zeigeBewegungsmoeglichkeiten(AusgabeMemo:TMemo;FeldCanvas:TCanvas{;besetzt:TMatrix}); override; //markiert alle erlaubten Felder türkis
end;

implementation

procedure TLanglaeufer.zeigeBewegungsmoeglichkeiten;
var cux,cuy:integer; //Prüffeld - Index

begin

inherited zeigebewegungsmoeglichkeiten(AusgabeMemo,FeldCanvas);

if vertikalhorizontal = true then
 begin

  cux:=x;
  cuy:=y;

  //NACH UNTEN

  while cuy < 8 do
   begin
    cuy:=cuy+1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');                   //Textausgabe
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);  //Bildausgabe
    IsLegal[cux][cuy]:=true;                                                                          //Platzfreigabe für nächsten Gehvorgang
   end;

  cux:=x;
  cuy:=y;

  //NACH RECHTS

  while (cux < 8) {and (besetzt[cux][cuy]=0)} do           //TEST
   begin
    cux:=cux+1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
   end;

  cux:=x;
  cuy:=y;

  //NACH OBEN

  while cuy > 1 do
   begin
    cuy:=cuy-1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
   end;

  cux:=x;
  cuy:=y;

  //NACH LINKS

  while cux > 1 do
   begin
    cux:=cux-1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
   end;

 end;

if diagonal = true then
 begin

  cux:=x;
  cuy:=y;

  //NACH OBENRECHTS

  while (cuy < 8) and (cux < 8) do
   begin
    cuy:=cuy+1;
    cux:=cux+1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
   end;

  cux:=x;
  cuy:=y;

  //NACH RECHTSUNTEN

  while (cux < 8) and (cuy > 1) do
   begin
    cux:=cux+1;
    cuy:=cuy-1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
   end;

  cux:=x;
  cuy:=y;

  //NACH UNTENLINKS

  while (cuy > 1) and (cux > 1) do
   begin
    cuy:=cuy-1;
    cux:=cux-1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
  end;

  cux:=x;
  cuy:=y;

  //NACH LINKSOBEN

  while (cux > 1) and (cuy < 8) do
   begin
    cux:=cux-1;
    cuy:=cuy+1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
   end;

 end;
end;

end.
