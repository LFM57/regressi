unit about;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Inifiles,
  System.IOUtils,
  system.dateUtils,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.Edit,
  FMX.StdCtrls,
  FMX.Platform,
  FMX.Controls.Presentation,

  regutil, images;

type
  TAboutBox = class(TForm)
    PanelCop: TPanel;
    OKButton: TButton;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Copyright: TLabel;
    NumeroVersionLabel: TLabel;
    Email: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    ReleaseBtn: TButton;
    VersionLabel: TLabel;
    CommentLabel: TLabel;
    procedure FormCreate(Sender: TObject);
  private
  //  VersionFileName: string;
 //   procedure setIni;
  public
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.FMX}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
     ReleaseBtn.Visible := false;
     ReleaseBtn.Visible := true;
end;

(*
procedure TAboutBox.setIni;
begin
end;
*)

end.

