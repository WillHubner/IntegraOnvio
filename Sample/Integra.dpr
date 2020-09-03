program Integra;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {Form4},
  Integra.Onvio in '..\src\Integra.Onvio.pas',
  Integra.Onvio.Interfaces in '..\src\Integra.Onvio.Interfaces.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
