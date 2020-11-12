program Integra;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {Form4},
  Integra.Onvio in '..\src\Integra.Onvio.pas',
  Integra.Onvio.Classes in '..\src\Integra.Onvio.Classes.pas',
  Integra.Onvio.Intf in '..\src\Integra.Onvio.Intf.pas',
  Integra.Onvio.Types in '..\src\Integra.Onvio.Types.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
