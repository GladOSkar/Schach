unit Schachfigur;

interface

uses StdCtrls,SysUtils,Graphics,Types;

//type
//  TMatrix = array[1..8] of array[1..8] of Byte;

type TSchachfigur = class(TObject)
 public
  x:Byte;                                    //position
  y:Byte;
  farbe:boolean;                             //1=schwarz,0=weiss
  name:string;                               //Ausgabename
  typname:string;                            //Grafische Beschriftung

  IsLegal:array[1..8] of array[1..8] of Boolean;  //freigabetabelle für den nächsten Gehvorgang
  
  procedure zeigeBewegungsmoeglichkeiten(AusgabeMemo:TMemo;FeldCanvas:TCanvas{;besetzt:TMatrix}); virtual;  //markiert alle erlaubten Felder türkis
  procedure gehe(gx,gy:integer);             //geht auf Feld xy
  procedure zeichnen(cv:TCanvas;mem:TMemo);  //zeichnet bewegtes objekt
  procedure stirb;

  constructor create(px,py:integer;pf:Boolean;pn,pt:string);

 protected
  function InvertY(a:Integer):Integer;      //Umkehrung informatisches <-> mathematisches Koordinatensystem (8-1-->1-8)

 private
  procedure clearlegal;                     //sperren aller felder für nächsten Geh- oder Prüfvorgang
end;

implementation

function TSchachfigur.InvertY(a:Integer):Integer;
begin
 Result:=(a*(-1))+9;
end;

procedure TSchachfigur.clearlegal;
var i,j:Byte;
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
 inherited Create;
 x:=px;
 y:=py;
 farbe:=pf;
 name:=pn;
 typname:=pt;
end;

procedure TSchachfigur.zeigeBewegungsmoeglichkeiten;
begin

 AusgabeMemo.Lines.add('Figur ' + name + ' angewählt.');
 AusgabeMemo.Lines.add('Bewegungsmöglichkeiten sind: ');

 clearlegal;

 FeldCanvas.Brush.Color:=clAqua;
 FeldCanvas.Pen.Color:=clAqua;

end;

procedure TSchachfigur.zeichnen;
begin
 if farbe=true then
  begin
   cv.Brush.Color:=clMaroon;
   cv.Pen.Color:=clWhite;
  end
 else
  begin
   cv.Brush.Color:=clInfoBk;
   cv.Pen.Color:=clBlack;
  end;

 cv.Font.Color:=(cv.Pen.Color);
 cv.Rectangle((x-1)*75+11,(Inverty(y)-1)*75+11,(x-1)*75+64,(Inverty(y)-1)*75+64);
 cv.TextOut((x-1)*75+20,(Inverty(y)-1)*75+20,typname);

 mem.Lines.add(name+': X=' + IntToStr(x) + ', Y=' + IntToStr(y)); // ### AUSGABE ###

end;

procedure TSchachfigur.gehe;
begin
 x:=gx;
 y:=gy;
 clearlegal;
end;

procedure TSchachfigur.stirb;
begin
 free;
end;

end.
