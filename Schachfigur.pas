unit Schachfigur;

interface

uses StdCtrls,SysUtils,Graphics,Types;

type
  TMatrix = array[1..8] of array[1..8] of Byte;       //64 Bytes, siehe "besetzt" in main.pas Z.45

type
  TBFeld = array[1..8] of array[1..8] of Boolean;     //64 Booleans

type TSchachfigur = class(TObject)
 private
  indexinalive:byte;                         //position im "alive"-array
  xpos:byte;                                 
  ypos:byte;                                 //position
  farbe:boolean;                             //true=schwarz , false=weiss
  dead:boolean;
  name:string;                               //Ausgabename
  typname:string;                            //Grafische Beschriftung
  procedure clearlegal;                      //sperren aller felder für nächsten Geh- oder Prüfvorgang

 protected
  function InvertY(a:byte):byte;             //Umkehrung informatisches <-> mathematisches Koordinatensystem (8-1-->1-8)

 public
  IsLegal:TBFeld;                            //freigabetabelle für den nächsten Gehvorgang (funktioniert nicht mit property)

  property i:byte read indexinalive write indexinalive;
  property x:byte read xpos;
  property y:byte read ypos;
  property f:boolean read farbe;
  property d:boolean read dead;              //zugriffe

  procedure zeigeBewegungsmoeglichkeiten(AusgabeMemo:TMemo;FeldCanvas:TCanvas;besetzt:TMatrix); virtual;  //markiert alle erlaubten Felder türkis
  procedure gehe(gx,gy:byte);                //geht auf Feld xy
  procedure zeichnen(cv:TCanvas;mem:TMemo);  //zeichnet bewegtes objekt
  procedure stirb;

  constructor create(px,py:byte;pf:Boolean;pn,pt:string);
end;

implementation

function TSchachfigur.InvertY;
begin
 Result:=-a+9;
end;

procedure TSchachfigur.clearlegal;
var i,j:byte;
begin

for i:=1 to 8 do
 begin
  for j:=1 to 8 do
   begin
    IsLegal[i][j]:=false;
   end;
 end;

end;

constructor TSchachfigur.create;
begin
 inherited create;
 xpos:=px;
 ypos:=py;
 farbe:=pf;
 name:=pn;
 typname:=pt;
end;

procedure TSchachfigur.zeigeBewegungsmoeglichkeiten;
begin

 AusgabeMemo.Lines.add('Figur ' + name + ' angewählt.');   //textausgabe
 AusgabeMemo.Lines.add('Bewegungsmöglichkeiten sind: ');

 clearlegal;                                               //zurücksetzen der letzten routine

 FeldCanvas.Brush.Color:=clAqua;                           //setzen der farbe
 FeldCanvas.Pen.Color:=clAqua;

end;

procedure TSchachfigur.zeichnen;
begin
 if farbe=true then                                        //farbe setzen
  begin
   cv.Brush.Color:=clMaroon;                               //füllung
   cv.Pen.Color:=clWhite;                                  //rand
  end
 else
  begin
   cv.Brush.Color:=clInfoBk;                               //füllung
   cv.Pen.Color:=clBlack;                                  //rand
  end;

 cv.Font.Color:=(cv.Pen.Color);                            //textfarbe

 cv.Rectangle((xpos-1)*75+11,(Inverty(ypos)-1)*75+11,(xpos-1)*75+64,(Inverty(ypos)-1)*75+64);  //figur zeichnen
 cv.TextOut((xpos-1)*75+20,(Inverty(ypos)-1)*75+20,typname);                                   //beschriften

 mem.Lines.add(name+': X=' + IntToStr(xpos) + ', Y=' + IntToStr(ypos));                        //textausgabe

end;

procedure TSchachfigur.gehe;
begin
 xpos:=gx;
 ypos:=gy;
 clearlegal;
end;

procedure TSchachfigur.stirb;
begin
 free;
end;

end.
