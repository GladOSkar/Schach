unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, jpeg, Schachfigur, Langlaeufer,Types;

type
  TForm1 = class(TForm)
    FeldZeichnen: TButton;
    Memo1: TMemo;
    Image1: TImage;
    CommandEdit: TEdit;
    function InvertY(a:byte):byte;                       //Umkehrung informatisches <-> mathematisches Koordinatensystem (8-1-->1-8)
    procedure FeldZeichnenClick(Sender: TObject);                                     //-->DrawField;
    procedure FormCreate(Sender: TObject);                                            //Erstellt alle figuren und skaliert das GUI
    procedure FormClose(Sender: TObject; var Action: TCloseAction);                   //gibt den Ram wieder Frei
    procedure CommandEditEnter(Sender: TObject);                                      //macht die kommandozeile leer
    procedure CommandEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); //-->eval;
    procedure CommandEditExit(Sender: TObject);                                       //setzt wieder hilfe in kommandozeile
    procedure FormClick(Sender: TObject);                                             //trigger für das anklicken von figuren

  private
    procedure DrawField;                                 //zeichnet das Feld und alle figuren neu
    procedure eval;                                      //kommandozeilenauswertung
    function StrToFig(s:string):TSchachfigur;            //wandelt einen string in einen Figurenbezeichner um
    function IsInteger(const AString: String): Boolean;  //prüft, ob ein String in einen Integer umgewandelt werden kann
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var turms1, turms2, laeufers1, laeufers2, dames,            // ### figuren
    turmw1, turmw2, laeuferw1, laeuferw2, damew: TLanglaeufer;

    //koenigs, pferds1: TSchachfigur;                         // ###

    alive:array[0..9] of TSchachfigur;                      //liste aller aktiven(!) figuren (nil=inaktiv)

    auswahl:TSchachfigur; //auswahl ist hier, damit es nach anwählen der figur auch fürs gehen erhalten bleibt.

    besetzt:TMatrix;                                        //für kollisionsprüfung    //0=leer, 1=weiss, 2=schwarz
    whosthere:array[1..8] of array[1..8] of TSchachfigur;   //für anwählen & schlagen
    dran:boolean;

function TForm1.IsInteger(const AString: String): Boolean;
begin
  Result:=StrToIntDef(AString,0)=StrToIntDef(AString,1);
end;

function TForm1.InvertY;
begin
 Result:=-a+9;
end;

function TForm1.StrToFig;
begin
 if s='turms1'    then Result:=turms1    else
 if s='turms2'    then Result:=turms2    else
 if s='laeufers1' then Result:=laeufers1 else
 if s='laeufers2' then Result:=laeufers2 else
 if s='dames'     then Result:=dames     else

 if s='turmw1'    then Result:=turmw1    else
 if s='turmw2'    then Result:=turmw2    else
 if s='laeuferw1' then Result:=laeuferw1 else
 if s='laeuferw2' then Result:=laeuferw2 else
 if s='damew'     then Result:=damew     else

 Result:=nil;
end;

procedure TForm1.DrawField;
var x,y,i:Byte;
begin
 with Canvas do                                    //#####   zeichnet das Schachfeld
  begin
   Brush.Color:=clWhite;
   Pen.Color:=clWhite;
   Rectangle(1,1,600,600);                             //hintergrund weiss

   Brush.Color:=clBlack;
   Pen.Color:=clBlack;
   for x:=0 to 7 do
    begin
     for y:=0 to 7 do
      begin
       if ( ( ( abs( x - y ) ) mod 2 ) = 1 ) then      //für alle felder wo |x-y| ungerade ist
        Rectangle(x*75,y*75,x*75+76,y*75+76);          //karomuster schwarz
      end;
    end;
  end;                                             //#####

 for i:=0 to High(alive) do
  if alive[i]<>nil then
   alive[i].zeichnen(Canvas,Memo1);                //alle lebenden figuren zeichnen

end;

procedure TForm1.eval;
var s:string;
    cx,cy:Byte;
begin
s:=CommandEdit.Text;                                    //eingabe einlesen

if copy(s,1,2) = 'cf' then                              //   #####   FIGUR WECHSELN   #####   //
 begin
  auswahl:=StrToFig(copy(s,3,length(s)));                       //figur einlesen & ANWÄHLEN

  if (auswahl <> nil) and (alive[auswahl.i]<>nil) then          //nur wenn gültige figur
   begin
    if auswahl.f=dran then
     begin
      DrawField;                                                  //alte überzeichnungen entfernen
      auswahl.zeigebewegungsmoeglichkeiten(Memo1,Canvas,besetzt); //bewegungsmöglichkeiten anzeigen
     end else memo1.Lines.Add('DIE FARBE DIESER FIGUR IST NICHT DRAN!');

   end else memo1.Lines.Add('KEINE AKTIVE FIGUR MIT DEM NAMEN "'+ copy(s,3,length(s)) +'" GEFUNDEN! ("cf<typ><farbinitial><nummer>" z.B.: "cfturms1")');

  end else

if copy(s,1,2) = 'go' then                               //   #####   GEHEN   #####   //
 begin
  cx:=StrToInt(s[3]);
  cy:=StrToInt(s[4]);                                            //koordinaten einlesen

  if (IsInteger(s[3])=true) and (IsInteger(s[4])=true) then      //nach go müssen 2 ziffern folgen
   begin
    if auswahl <> nil then                                       //nur wenn eine figur angewählt ist
     begin
      if auswahl.IsLegal[cx][cy]=true then                       //nur wenn das feld bei der anwahl als begehbar deklariert wurde
       begin
        if besetzt[cx][cy]<>0 then                               // ### schlagen?!
         begin
          alive[whosthere[cx][cy].i]:=nil;                          //alive-eintrag nullen
          whosthere[cx][cy].stirb(memo1);                           //-->free;
         end;                                                    // ###

        besetzt[auswahl.x][auswahl.y]:=0;                        //altes feld freigeben
        whosthere[auswahl.x][auswahl.y]:=nil;

        auswahl.gehe(cx,cy);                                     //gehen (attribute setzen)

        if auswahl.f=false then besetzt[auswahl.x][auswahl.y]:=1
                           else besetzt[auswahl.x][auswahl.y]:=2;//feld besetzen

        whosthere[auswahl.x][auswahl.y]:=auswahl;

        auswahl:=nil;                                            //auswahl löschen
        DrawField;                                               //neu zeichnen

        dran:=not(dran);                                         //der andere Spieler ist dran

        if dran then memo1.Lines.Add('SCHWARZ ist jetzt dran!')  //|
                  else memo1.Lines.Add('WEISS ist jetzt dran!')  //|Ausgabe

       end else memo1.Lines.Add('FELD NICHT ERLAUBT oder NOCH KEINE FIGUR ANGEWÄHLT!');

     end else memo1.Lines.Add('KEINE FIGUR ANGEWÄHLT!');

   end else memo1.Lines.Add('NACH "go" ZWEI ZIFFERN ZIFFERN EINGEBEN!');

 end else memo1.Lines.Add('FEHLERHAFTE EINGABE!!!');

CommandEdit.Text:='';                                    //eingabefeld leeren

end;

procedure TForm1.FormCreate(Sender: TObject);
var k:byte;
begin
 Form1.ClientWidth:=850;                         //GUI anpassen
 Form1.ClientHeight:=700;                        //weil sonst auf unterschiedlichen computern falsch angezeigt

 Image1.Top:=600;
 Image1.Left:=0;
 Image1.Width:=600;
 Image1.Height:=100;

 CommandEdit.Top:=660;
 CommandEdit.Left:=15;
 CommandEdit.Width:=570;
 CommandEdit.Height:=25;

 FeldZeichnen.Top:=615;
 FeldZeichnen.Left:=15;
 FeldZeichnen.Width:=100;
 FeldZeichnen.Height:=30;

 Memo1.Top:=0;
 Memo1.Left:=600;
 Memo1.Width:=250;
 Memo1.Height:=700;

                                                 //FIGUREN ERSCHAFFEN

 turms1:=TLanglaeufer.create(1,8,true,true,false,'Turm Schwarz Links','Turm');
 whosthere[1][8]:=turms1;
 besetzt[1][8]:=2;

 turms2:=TLanglaeufer.create(8,8,true,true,false,'Turm Schwarz Rechts','Turm');
 whosthere[8][8]:=turms2;
 besetzt[8][8]:=2;

 laeufers1:=TLanglaeufer.create(3,8,true,false,true,'Läufer Schwarz Links','Läufer');
 whosthere[3][8]:=laeufers1;
 besetzt[3][8]:=2;

 laeufers2:=TLanglaeufer.create(6,8,true,false,true,'Läufer Schwarz Rechts','Läufer');
 whosthere[6][8]:=laeufers2;
 besetzt[6][8]:=2;

 dames:=TLanglaeufer.create(4,8,true,true,true,'Dame Schwarz','Dame');
 whosthere[4][8]:=dames;
 besetzt[4][8]:=2;



 turmw1:=TLanglaeufer.create(1,1,false,true,false,'Turm Weiss Links','Turm');
 whosthere[1][1]:=turmw1;
 besetzt[1][1]:=1;

 turmw2:=TLanglaeufer.create(8,1,false,true,false,'Turm Weiss Rechts','Turm');
 whosthere[8][1]:=turmw2;
 besetzt[8][1]:=1;

 laeuferw1:=TLanglaeufer.create(3,1,false,false,true,'Läufer Weiss Links','Läufer');
 whosthere[3][1]:=laeuferw1;
 besetzt[3][1]:=1;

 laeuferw2:=TLanglaeufer.create(6,1,false,false,true,'Läufer Weiss Rechts','Läufer');
 whosthere[6][1]:=laeuferw2;
 besetzt[6][1]:=1;

 damew:=TLanglaeufer.create(4,1,false,true,true,'Dame Weiss','Dame');
 whosthere[4][1]:=damew;
 besetzt[4][1]:=1;

 alive[0]:=turms1;
 alive[1]:=turms2;
 alive[2]:=laeufers1;
 alive[3]:=laeufers2;
 alive[4]:=dames;
 alive[5]:=turmw1;
 alive[6]:=turmw2;
 alive[7]:=laeuferw1;
 alive[8]:=laeuferw2;
 alive[9]:=damew;                                  //in alive einsetzen

 for k:=0 to 9 do
  alive[k].i:=k;                                   //indexinalive setzen

 dran:=false;                                      //weiss ist dran
 auswahl:=nil;                                     //keine Figur angewählt
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var i:byte;
begin
 for i:=0 to (length(alive)-1) do
  if alive[i]<> nil then
   alive[i].stirb(memo1);
end;

procedure TForm1.CommandEditEnter(Sender: TObject);
begin
 CommandEdit.Text:='';
end;

procedure TForm1.FeldZeichnenClick(Sender: TObject);
begin
 DrawField;
end;

procedure TForm1.CommandEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 if key = VK_Return then eval;
end;

procedure TForm1.CommandEditExit(Sender: TObject);
begin
 CommandEdit.Text:='cmd: "go<x><y>" or "cf<figur>" z.B.: "go23" or "cfturms1"'
end;

procedure TForm1.FormClick(Sender: TObject);
var x,y:integer;
    xf,yf:byte;
begin
 x:=ScreenToClient(Mouse.CursorPos).X;
 y:=ScreenToClient(Mouse.CursorPos).Y;
 Memo1.Lines.Add('Position '+IntToStr(x)+' '+IntToStr(y)+' angeklickt.');

 xf:= x div 75 + 1;
 yf:= InvertY(y div 75 + 1);

 Memo1.Lines.Add('Feld '+IntToStr(xf)+' '+IntToStr(yf)+' angeklickt.');


 if (auswahl<>nil) and auswahl.IsLegal[xf][yf] then    //FALLS das feld als begehbar gekennzeichnet ist ==> HINGEHEN
  begin

   if whosthere[xf][yf]<>nil then                            //FALLS sich eine Figur auf dem Feld befindet (muss vom Gegner sein, wäre sonst nicht erlaubt) ==> FIGUR TÖTEN
    begin
     alive[whosthere[xf][yf].i]:=nil;                            //alive-eintrag nullen
     whosthere[xf][yf].stirb(memo1);                             //-->free;
    end;

   besetzt[auswahl.x][auswahl.y]:=0;                         //|altes Feld freigeben
   whosthere[auswahl.x][auswahl.y]:=nil;                     //|

   auswahl.gehe(xf,yf);                                      //GEHEN (attribute setzen)

   if not(auswahl.f) then besetzt[auswahl.x][auswahl.y]:=1   //|
                     else besetzt[auswahl.x][auswahl.y]:=2;  //|Feld besetzen
                                                             //|
   whosthere[auswahl.x][auswahl.y]:=auswahl;                 //|

   auswahl:=nil;                                             //|auswahl löschen
   DrawField;                                                //|

   dran:=not(dran);                                          //der andere Spieler ist dran

   if dran then memo1.Lines.Add('SCHWARZ ist jetzt dran!')   //|
             else memo1.Lines.Add('WEISS ist jetzt dran!')   //|Ausgabe

  end
 else                                                    //FALLS das feld nicht begehbar ist
  begin
   if whosthere[xf][yf]<>nil then                            //FALLS sich eine Figur auf dem Feld befindet (muss eigene sein, wäre sonst begehbar) ==> ANWÄHLEN
    begin
     if whosthere[xf][yf].f=dran then                            //FALLS sich eine Figur auf dem Feld befindet (muss eigene sein, wäre sonst begehbar) ==> ANWÄHLEN
      begin

       DrawField;                                                    //alte überzeichnungen entfernen
       auswahl:=whosthere[xf][yf];
       auswahl.zeigebewegungsmoeglichkeiten(Memo1,Canvas,besetzt);   //bewegungsmöglichkeiten anzeigen

      end;
    end
   else                                                      //FALLS das feld leer ist ==> NIX MACHEN
    begin

     auswahl:=nil;                                               //|auswahl löschen
     DrawField;                                                  //|

     Memo1.Lines.Add('Feld nicht erlaubt, du Horst!');           //Ausgabe

    end;
  end;
end;

end.
