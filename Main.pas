unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, jpeg, Schachfigur, Langlaeufer,Types;

type
  TMatrix = array[1..8] of array[1..8] of Byte;

type
  TForm1 = class(TForm)

    StartButton: TButton;
    Memo1: TMemo;
    Image1: TImage;
    Edit1: TEdit;
    enter: TButton;
    procedure enterClick(Sender: TObject);               //-->eval;
    procedure StartButtonClick(Sender: TObject);         //-->DrawField;
    procedure FormCreate(Sender: TObject);               //Erstellt alle figuren und skaliert die Elemente
    procedure FormClose(Sender: TObject; var Action: TCloseAction); //gibt den Ram wieder Frei
    procedure Edit1Enter(Sender: TObject);               //macht die kommandozeile leer
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); //-->eval;
    procedure Edit1Exit(Sender: TObject);                //setzt wieder hilfe in kommandozeile

  private
    { Private-Deklarationen }
    procedure DrawField;                                 //zeichnet das Feld und alle figuren neu
    procedure eval;                                      //kommandozeilenauswertung
    function StrToFig(s:string):TSchachfigur;            //wandelt einen string in einen Figurenbezeichner um
    function IsInteger(const AString: String): Boolean;  //prüft, ob ein String in einen Integer umgewandelt werden kann

  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var turms1, turms2, laeufers1, laeufers2, dames,
    turmw1, turmw2, laeuferw1, laeuferw2, damew: TLanglaeufer;

    koenigs, pferds1: TSchachfigur;

    auswahl:TSchachfigur; //auswahl ist hier, damit es nach anwählen der figur auch fürs gehen erhalten bleibt.

    besetzt:TMatrix;                                        //für kollisionsprüfung    //0=leer, 1=weiss, 2=schwarz
    whosthere:array[1..8] of array[1..8] of TSchachfigur;   //für anwählen & schlagen

function TForm1.IsInteger(const AString: String): Boolean;
begin
  Result:=StrToIntDef(AString,0)=StrToIntDef(AString,1);
end;

function TForm1.StrToFig;
begin
 if s='turms1' then Result:=turms1;
 if s='turms2' then Result:=turms2;
 if s='laeufers1' then Result:=laeufers1;
 if s='laeufers2' then Result:=laeufers2;
 if s='dames' then Result:=dames;

 if s='turmw1' then Result:=turmw1;
 if s='turmw2' then Result:=turmw2;
 if s='laeuferw1' then Result:=laeuferw1;
 if s='laeuferw2' then Result:=laeuferw2;
 if s='damew' then Result:=damew;
end;

procedure TForm1.DrawField;
var x,y:Byte;
begin
 with Canvas do                                    //#####   zeichnet das Schachfeld
  begin
   Brush.Color:=clBlack;
   Pen.Color:=clBlack;
   for x:=0 to 7 do
    begin
     for y:=0 to 7 do
      begin

       if ( ( ( abs( x - y ) ) mod 2 ) = 0 ) then  //karoprinzip
        begin
         Brush.Color:=clWhite;
         Pen.Color:=clWhite;
        end
       else
        begin
         Brush.Color:=clBlack;
         Pen.Color:=clBlack;
        end;

       Rectangle(x*75,y*75,x*75+76,y*75+76);      //#####

      end;
    end;
  end;

 turms1.zeichnen(Canvas,Memo1);
 turms2.zeichnen(Canvas,Memo1);
 laeufers1.zeichnen(Canvas,Memo1);
 laeufers2.zeichnen(Canvas,Memo1);
 dames.zeichnen(Canvas,Memo1);

 turmw1.zeichnen(Canvas,Memo1);
 turmw2.zeichnen(Canvas,Memo1);
 laeuferw1.zeichnen(Canvas,Memo1);
 laeuferw2.zeichnen(Canvas,Memo1);
 damew.zeichnen(Canvas,Memo1);

end;

procedure TForm1.eval;
var s:string;
    cx,cy:Byte;
begin

 s:=Edit1.Text;

 if (copy(s,1,2) = 'go') or (copy(s,1,2) = 'cf') then

  begin

   if copy(s,1,2) = 'go' then                                       //GEHEN

    begin

     cx:=StrToInt(s[3]);
     cy:=StrToInt(s[4]);

     if (IsInteger(s[3])=true) and (IsInteger(s[4])=true) then

      begin

       if (auswahl=turms1) or (auswahl=turms2) or (auswahl=laeufers1) or (auswahl=laeufers2) or (auswahl=dames) or
          (auswahl=turmw1) or (auswahl=turmw2) or (auswahl=laeuferw1) or (auswahl=laeuferw2) or (auswahl=damew) then

        begin

         if auswahl.IsLegal[cx][cy]=true then

          begin
           auswahl.gehe(cx,cy);
           DrawField;
          end

         else memo1.Lines.Add('Feld nicht erlaubt oder keine Figur angewählt, du Doofkopf!');

        end

       else memo1.Lines.Add('Keine Figur angewählt.');

      end

     else memo1.Lines.Add('nach "go" zwei Ziffern eingeben!');

    end;

   if copy(s,1,2) = 'cf' then                                      //FIGUR WECHSELN

    begin

     auswahl:=StrToFig(copy(s,3,length(s)));

     if (auswahl=turms1) or (auswahl=turms2) or (auswahl=laeufers1) or (auswahl=laeufers2) or (auswahl=dames) or
        (auswahl=turmw1) or (auswahl=turmw2) or (auswahl=laeuferw1) or (auswahl=laeuferw2) or (auswahl=damew) then

      begin
       DrawField;
       auswahl.zeigebewegungsmoeglichkeiten(Memo1,Canvas{,besetzt});
      end

     else memo1.Lines.Add('nach "cf" name einer figur eingeben (z.B.: cfturms1)');

    end

  end

 else memo1.Lines.Add('Fehlerhafte Eingabe!!!');

 Edit1.Text:='';

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 Form1.ClientWidth:=850;
 Form1.ClientHeight:=700;

 Image1.Top:=600;
 Image1.Left:=0;
 Image1.Width:=600;
 Image1.Height:=100;

 Edit1.Top:=660;
 Edit1.Left:=15;
 Edit1.Width:=570;
 Edit1.Height:=25;

 StartButton.Top:=615;
 StartButton.Left:=15;
 StartButton.Width:=100;
 StartButton.Height:=30;

 enter.Top:=615;
 enter.Left:=130;
 enter.Width:=100;
 enter.Height:=30;

 Memo1.Top:=0;
 Memo1.Left:=600;
 Memo1.Width:=250;
 Memo1.Height:=700;



 turms1:=TLanglaeufer.create(1,8,true,'Turm Schwarz Links','Turm');
 turms1.vertikalhorizontal:=true;
 turms1.diagonal:=false;
 whosthere[1][8]:=turms1;
 besetzt[1][8]:=2;

 turms2:=TLanglaeufer.create(8,8,true,'Turm Schwarz Rechts','Turm');
 turms2.vertikalhorizontal:=true;
 turms2.diagonal:=false;
 whosthere[8][8]:=turms2;
 besetzt[8][8]:=2;

 laeufers1:=TLanglaeufer.create(3,8,true,'Läufer Schwarz Links','Läufer');
 laeufers1.vertikalhorizontal:=false;
 laeufers1.diagonal:=true;
 whosthere[3][8]:=laeufers1;
 besetzt[3][8]:=2;

 laeufers2:=TLanglaeufer.create(6,8,true,'Läufer Schwarz Rechts','Läufer');
 laeufers2.vertikalhorizontal:=false;
 laeufers2.diagonal:=true;
 whosthere[6][8]:=laeufers2;
 besetzt[6][8]:=2;

 dames:=TLanglaeufer.create(4,8,true,'Dame Schwarz','Dame');
 dames.vertikalhorizontal:=true;
 dames.diagonal:=true;
 whosthere[4][8]:=dames;
 besetzt[4][8]:=2;



 turmw1:=TLanglaeufer.create(1,1,false,'Turm Weiss Links','Turm');
 turmw1.vertikalhorizontal:=true;
 turmw1.diagonal:=false;
 whosthere[1][1]:=turmw1;
 besetzt[1][1]:=1;

 turmw2:=TLanglaeufer.create(8,1,false,'Turm Weiss Rechts','Turm');
 turmw2.vertikalhorizontal:=true;
 turmw2.diagonal:=false;
 whosthere[8][1]:=turmw2;
 besetzt[8][1]:=1;

 laeuferw1:=TLanglaeufer.create(3,1,false,'Läufer Weiss Links','Läufer');
 laeuferw1.vertikalhorizontal:=false;
 laeuferw1.diagonal:=true;
 whosthere[3][1]:=laeuferw1;
 besetzt[3][1]:=1;

 laeuferw2:=TLanglaeufer.create(6,1,false,'Läufer Weiss Rechts','Läufer');
 laeuferw2.vertikalhorizontal:=false;
 laeuferw2.diagonal:=true;
 whosthere[6][1]:=laeuferw2;
 besetzt[6][1]:=1;

 damew:=TLanglaeufer.create(4,1,false,'Dame Weiss','Dame');
 damew.vertikalhorizontal:=true;
 damew.diagonal:=true;
 whosthere[4][1]:=damew;
 besetzt[4][1]:=1;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 turms1.stirb;
 turms2.stirb;
 laeufers1.stirb;
 laeufers2.stirb;
 dames.stirb;

 turmw1.stirb;
 turmw2.stirb;
 laeuferw1.stirb;
 laeuferw2.stirb;
 damew.stirb;
end;

procedure TForm1.Edit1Enter(Sender: TObject);
begin
 Edit1.Text:='';
end;

procedure TForm1.enterClick(Sender: TObject);
begin
 eval;
end;

procedure TForm1.StartButtonClick(Sender: TObject);
begin
 DrawField;
end;

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 if key = VK_Return then eval;
end;

procedure TForm1.Edit1Exit(Sender: TObject);
begin
 Edit1.Text:='cmd: "go<x><y>" or "cf<figur>" z.B.: "go23" or "cfturms1"'
end;

end.
