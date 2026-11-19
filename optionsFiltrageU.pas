unit optionsFiltrageU;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.TreeView,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Controls.Presentation,
  FMX.ScrollBox,

  fft, images, FMX.Memo.Types;

type
  TOptionsFiltreDlg = class(TForm)

    Memo1: TMemo;
    BitBtn1: TButton;
    BitBtn2: TButton;
    BitBtn3: TButton;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
  public
  end;

var
  OptionsFiltreDlg: TOptionsFiltreDlg;

implementation

{$R *.FMX}

procedure TOptionsFiltreDlg.BitBtn1Click(Sender: TObject);
begin
	fenetre := rectangulaire
end;

procedure TOptionsFiltreDlg.BitBtn2Click(Sender: TObject);
begin
	fenetre := rectangleAjuste
end;

end.
