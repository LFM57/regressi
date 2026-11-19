unit OptionsAffModeleU;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IniFiles,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.Grid,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.TreeView,
  FMX.Memo,
  FMX.TabControl,
  FMXTee.RadioGroup,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Bind.Editors,
  FMX.Bind.Navigator,
  FMX.StdCtrls, 
  FMX.Controls.Presentation;

type
  TOptionsAffModeleDlg = class(TForm)
    GroupBox1: TGroupBox;
    OKBtn: TButton;
    CancelBtn: TButton;
    ListeModeleGB: TGroupBox;
    ListeModeleBox: TListBox;
    ListeParamBox: TListBox;
    PrecisionRG: TListBox;
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
  public
  end;

var
  OptionsAffModeleDlg: TOptionsAffModeleDlg;

implementation

uses compile,graphker;

{$R *.FMX}

procedure TOptionsAffModeleDlg.FormActivate(Sender: TObject);
var i : integer;
    sauve : array[0..MaxParametres] of boolean;
begin
with ListeParamBox do begin
     for i := 0 to pred(count) do
         sauve[i] := ListItems[i].isChecked;
     Items.Clear;
     for i := 1 to NbreParam do begin
         Items.add(Parametres[i].nom);
         ListItems[i-1].isChecked := sauve[i-1];
     end;
end;
ListeModeleGB.Visible := nbreModele>1;
with ListeModeleBox do begin
     for i := 0 to pred(count) do
         sauve[i] := listItems[i].isChecked;
     Items.Clear;
     for i := 1 to NbreModele do begin
         Items.add(FonctionTheorique[i].expression);
         listItems[i-1].isChecked := sauve[i-1];
     end;
     if nbreModele=1 then listItems[0].isChecked := true;
end;
//PrecisionRG.itemIndex := ord(AffichagePrecision);
end;

procedure TOptionsAffModeleDlg.OKBtnClick(Sender: TObject);
begin
  // AffichagePrecision := TaffichagePrecision(precisionRG.itemIndex);
end;

end.
