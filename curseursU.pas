unit curseursU;

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
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Bind.Editors,
  FMX.Bind.Navigator,

  Graphker;

type
  TCurseursForm = class(TForm)
    Grid: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
  public
    isFFT : boolean;
  end;

var
  CurseursForm: TCurseursForm;

implementation

uses graphvar, graphfft;

{$R *.FMX}

procedure TCurseursForm.FormCreate(Sender: TObject);
begin
//  grid.ColWidths[0] := 60;
//  grid.ColWidths[1] := 100;
end;

end.
