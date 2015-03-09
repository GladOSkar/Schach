unit Langlaeufer;

interface

uses StdCtrls,SysUtils,Graphics,Schachfigur,Types;

type TLanglaeufer = class(TSchachfigur)
 private
  vertikalhorizontal:Boolean;
  diagonal:Boolean;
  procedure reset(var cux:byte;var cuy:byte);   //setzt zurück für neue Richtung
  function OkToGo(n:byte):boolean;              //gibt wahr zurück falls auf dem feld niemand oder ein gegner ist.

 public
  constructor create(px,py:byte;pf,vh,d:Boolean;pn,pt:string);
  procedure zeigeBewegungsmoeglichkeiten(AusgabeMemo:TMemo;FeldCanvas:TCanvas;besetzt:TMatrix); override; //probiert alle richtungen dieser figur (--> mark();)
  procedure zeichnen(cv:TCanvas;mem:TMemo); override; //zeichnet bewegtes objekt
end;

implementation
                                             
var PrevWasEnemy:Boolean;                    //siehe unten

constructor TLanglaeufer.create;
begin
 inherited create(px,py,pf,pn,pt);
 vertikalhorizontal:=vh;
 diagonal:=d;
end;

procedure TLanglaeufer.reset;
begin
 cux:=x;
 cuy:=y;
 PrevWasEnemy:=false;
end;


function TLanglaeufer.OkToGo;
begin
 if PrevWasEnemy then
  begin
   result:=false;                            //falls auf dem vorigen Feld ein Gegner war, breche die Prüfung ab.
   PrevWasEnemy:=false;
  end else
 if PrevWasEnemy=false then                  //andernfalls
  begin
   if n=0 then result:=true else               //falls das Feld leer ist, mache weiter
   if n=1 then                                 //falls auf dem Feld eine weisse Figur ist
    begin
     result:=f;                                  //falls du schwarz bist: mache weiter, falls du weiss bist: breche ab.
     PrevWasEnemy:=f;                            //falls du schwarz bist: breche das nächste Mal ab.
    end else
   if n=2 then                                 //falls auf dem Feld eine schwarze Figur ist
    begin
     result:=not(f);                             //falls du weiss bist: mache weiter, falls du schwarz bist: breche ab.
     PrevWasEnemy:=not(f);                       //falls du weiss bist: breche das nächste Mal ab.
    end;
  end;
end;

procedure TLanglaeufer.zeigeBewegungsmoeglichkeiten;
var cux,cuy:byte; //Prüffeld - Index
begin

inherited zeigebewegungsmoeglichkeiten(AusgabeMemo,FeldCanvas,besetzt);

if vertikalhorizontal = true then   //prüfung auf Längs- und Querachse
 begin

  reset(cux,cuy);                   //prüfcursor auf position der figur setzen (siehe oben)

  //NACH OBEN

  while (cuy < 8) and (OkToGo(besetzt[cux][cuy+1])=true) do     //falls nicht aus dem Schachfeld heraus und das Feld begehbar ist.
   begin                                                                                              //(Kriterien oben unter "OkToGo")
    cuy:=cuy+1;                                                        //verschiebe cursor auf nächstes feld
    mark(cux,cuy,FeldCanvas,AusgabeMemo,besetzt);                      //Markieren
   end;

  reset(cux,cuy);

  //NACH RECHTS

  while (cux < 8) and (OkToGo(besetzt[cux+1][cuy])=true) do
   begin
    cux:=cux+1;
    mark(cux,cuy,FeldCanvas,AusgabeMemo,besetzt);
   end;

  reset(cux,cuy);

  //NACH UNTEN

  while (cuy > 1) and (OkToGo(besetzt[cux][cuy-1])=true) do
   begin
    cuy:=cuy-1;
    mark(cux,cuy,FeldCanvas,AusgabeMemo,besetzt);
   end;

  reset(cux,cuy);

  //NACH LINKS

  while (cux > 1) and (OkToGo(besetzt[cux-1][cuy])=true) do
   begin
    cux:=cux-1;
    mark(cux,cuy,FeldCanvas,AusgabeMemo,besetzt);
   end;

 end;

if diagonal = true then
 begin

  reset(cux,cuy);

  //NACH OBENRECHTS

  while ((cuy < 8) and (cux < 8)) and (OkToGo(besetzt[cux+1][cuy+1])=true) do
   begin
    cuy:=cuy+1;
    cux:=cux+1;
    mark(cux,cuy,FeldCanvas,AusgabeMemo,besetzt);
   end;

  reset(cux,cuy);

  //NACH RECHTSUNTEN

  while ((cux < 8) and (cuy > 1)) and (OkToGo(besetzt[cux+1][cuy-1])=true) do
   begin
    cux:=cux+1;
    cuy:=cuy-1;
    mark(cux,cuy,FeldCanvas,AusgabeMemo,besetzt);
   end;

  reset(cux,cuy);

  //NACH UNTENLINKS

  while ((cuy > 1) and (cux > 1)) and (OkToGo(besetzt[cux-1][cuy-1])=true) do
   begin
    cuy:=cuy-1;
    cux:=cux-1;
    mark(cux,cuy,FeldCanvas,AusgabeMemo,besetzt);
  end;

  reset(cux,cuy);

  //NACH LINKSOBEN

  while ((cux > 1) and (cuy < 8)) and (OkToGo(besetzt[cux-1][cuy+1])=true) do
   begin
    cux:=cux-1;
    cuy:=cuy+1;
    mark(cux,cuy,FeldCanvas,AusgabeMemo,besetzt);
   end;

 end;
end;

procedure TLanglaeufer.zeichnen;
var x,y:word;
 begin

  inherited zeichnen(cv,mem);                   //Farben setzen

  x:=(xpos-1)*75;
  y:=(Inverty(ypos)-1)*75;                      //umwandlung in Bildschirmkoordinaten

  with cv do
   begin
    if vertikalhorizontal and not(diagonal) then       //Turm
     begin
      Rectangle(x+11,y+55,x+64,y+64);
      Rectangle(x+21,y+30,x+54,y+56);
      Rectangle(x+16,y+20,x+59,y+31);
      Rectangle(x+16,y+11,x+26,y+21);
      Rectangle(x+33,y+11,x+43,y+21);
      Rectangle(x+49,y+11,x+59,y+21);
     end
    else if not(vertikalhorizontal) and diagonal then  //Läufer
     begin
      Rectangle(x+11,y+55,x+64,y+64);
      Rectangle(x+26,y+30,x+49,y+56);
      Ellipse(x+21,y+11,x+54,y+50);
     end
    else                                               //Dame
     begin
      Rectangle(x+11,y+55,x+64,y+64);
      Rectangle(x+21,y+30,x+54,y+56);
     end;
   end;

 end;
end.
