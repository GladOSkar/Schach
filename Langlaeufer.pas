unit Langlaeufer;

interface

uses StdCtrls,SysUtils,Graphics,Schachfigur,Types;

type TLanglaeufer = class(TSchachfigur)
 private
  vertikalhorizontal:Boolean;
  diagonal:Boolean;
  function nofriendthere(n:byte):boolean;                    //gibt wahr zur�ck falls auf dem feld niemand oder ein gegner ist.
  procedure attackable(x,y:byte;cv:TCanvas);                 //malt ein gelbes rechteck auf ein feld, auf dem ein gegner schlagber ist.

 public
  constructor create(px,py:byte;pf,vh,d:Boolean;pn,pt:string);
  procedure zeigeBewegungsmoeglichkeiten(AusgabeMemo:TMemo;FeldCanvas:TCanvas;besetzt:TMatrix); override; //markiert alle erlaubten Felder t�rkis
end;

implementation

constructor TLanglaeufer.create;
begin
 inherited create(px,py,pf,pn,pt);
 vertikalhorizontal:=vh;
 diagonal:=d;
end;

function TLanglaeufer.nofriendthere;
begin
 if n=0 then result:=true else
 if (n=1) and (f=false) then result:=false else
 if (n=1) and (f=true)  then result:=true  else
 if (n=2) and (f=false) then result:=true  else
 if (n=2) and (f=true)  then result:=false;
end;

procedure TLanglaeufer.attackable;
begin
 with cv do
  begin
   Brush.Color:=clYellow;
   Pen.Color:=clYellow;

   Rectangle((x-1)*75+14,(Inverty(y)-1)*75+40,
             (x-1)*75+61,(Inverty(y)-1)*75+61);

   Brush.Color:=clAqua;
   Pen.Color:=clAqua;
  end;
end;

procedure TLanglaeufer.zeigeBewegungsmoeglichkeiten;
var cux,cuy:byte; //Pr�ffeld - Index
begin

inherited zeigebewegungsmoeglichkeiten(AusgabeMemo,FeldCanvas,besetzt);

if vertikalhorizontal = true then   //pr�fung auf L�ngs- und Querachse
 begin

  cux:=x;                           //pr�fcursor auf position der figur setzen
  cuy:=y;

  //NACH OBEN

  while (cuy < 8) and (nofriendthere(besetzt[cux][cuy+1])=true) do     //falls nicht aus dem Schachfeld heraus und keine Figur der eigenen Farbe auf dem Feld ist.
   begin
    cuy:=cuy+1;                                                        //verschiebe cursor auf n�chstes feld

    if besetzt[cux][cuy] = 0 then
     begin
      AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');                   //Textausgabe                                                   //Bildausgabe
      FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64)   //anmalen
     end
    else
     begin
      AusgabeMemo.Lines.add('Auf Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' kannst du schlagen!');        //Textausgabe                                                                                     //feld mit gegner drauf
      attackable(cux,cuy,FeldCanvas);                                                                   //anmalen
     end;
    IsLegal[cux][cuy]:=true;                                                                            //Platzfreigabe f�r n�chsten Gehvorgang
   end;

  cux:=x;
  cuy:=y;

  //NACH RECHTS

  while (cux < 8) and (nofriendthere(besetzt[cux+1][cuy])=true) do
   begin
    cux:=cux+1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
   end;

  cux:=x;
  cuy:=y;

  //NACH UNTEN

  while (cuy > 1) and (nofriendthere(besetzt[cux][cuy-1])=true) do
   begin
    cuy:=cuy-1;
    AusgabeMemo.Lines.add('Feld '+IntToStr(cux)+' '+IntToStr(cuy)+' ist erlaubt.');
    FeldCanvas.Rectangle((cux-1)*75+11,(Inverty(cuy)-1)*75+11,(cux-1)*75+64,(Inverty(cuy)-1)*75+64);
    IsLegal[cux][cuy]:=true;
   end;

  cux:=x;
  cuy:=y;

  //NACH LINKS

  while (cux > 1) and (nofriendthere(besetzt[cux-1][cuy])=true) do
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

  while ((cuy < 8) and (cux < 8)) and (nofriendthere(besetzt[cux+1][cuy+1])=true) do
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

  while ((cux < 8) and (cuy > 1)) and (nofriendthere(besetzt[cux+1][cuy-1])=true) do
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

  while ((cuy > 1) and (cux > 1)) and (nofriendthere(besetzt[cux-1][cuy-1])=true) do
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

  while ((cux > 1) and (cuy < 8)) and (nofriendthere(besetzt[cux-1][cuy+1])=true) do
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
