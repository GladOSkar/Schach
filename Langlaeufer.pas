unit Langlaeufer;

interface

uses StdCtrls,SysUtils,Graphics,Schachfigur,Types;

type TLanglaeufer = class(TSchachfigur)
 private
  vertikalhorizontal:Boolean;
  diagonal:Boolean;
  procedure reset(var cux:byte;var cuy:byte);                     //setzt zurück für neue Richtung
  function OkToGo(n:byte):boolean;                                //gibt wahr zurück falls auf dem feld niemand oder ein gegner ist.
  procedure attackable(x,y:byte;cv:TCanvas);                      //malt ein gelbes rechteck auf ein feld, auf dem ein gegner schlagber ist.
  procedure mark(x,y:byte;cv:TCanvas;mem:TMemo;pbesetzt:TMatrix); //markiert alle erlaubten Felder

 public
  constructor create(px,py:byte;pf,vh,d:Boolean;pn,pt:string);
  procedure zeigeBewegungsmoeglichkeiten(AusgabeMemo:TMemo;FeldCanvas:TCanvas;besetzt:TMatrix); override; //probiert alle richtungen dieser figur (--> mark();)
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
 if PrevWasEnemy then                        /// ##### BUGGY!!! ##### ///
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

procedure TLanglaeufer.attackable;
begin
 with cv do
  begin
   Brush.Color:=clYellow;
   Pen.Color:=clYellow;                             //farbe setzen

   Rectangle((x-1)*75+14,(Inverty(y)-1)*75+40,
             (x-1)*75+61,(Inverty(y)-1)*75+61);     //rechteck zeichnen

   Brush.Color:=clAqua;
   Pen.Color:=clAqua;                               //farbe wieder zurücksetzen
  end;
end;

procedure TLanglaeufer.mark;
begin
 if pbesetzt[x][y] = 0 then
   begin                                                                                 //leeres Feld
     mem.Lines.add('Feld '+IntToStr(x)+' '+IntToStr(y)+' ist erlaubt.');                   //Textausgabe                                                   
     cv.Rectangle((x-1)*75+11,(Inverty(y)-1)*75+11,
                  (x-1)*75+64,(Inverty(y)-1)*75+64);                                       //Bildausgabe
   end
 else
   begin                                                                                 //feld mit gegner drauf
     mem.Lines.add('Auf Feld '+IntToStr(x)+' '+IntToStr(y)+' kannst du schlagen!');        //Textausgabe                                                                                     
     attackable(x,y,cv);                                                                   //Bildausgabe
   end;
 IsLegal[x][y]:=true;                                                                    //Feldfreigabe für nächsten Gehvorgang
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

end.
