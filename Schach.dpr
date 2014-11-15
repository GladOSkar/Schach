program Schach;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  Schachfigur in 'Schachfigur.pas',
  Langlaeufer in 'Langlaeufer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Schach von Hannah, Mira und Oskar';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
