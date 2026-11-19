unit AideIncertitudeU;

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
  FMX.ScrollBox,
  FMX.Controls.Presentation,
  FMX.StdCtrls;


type
  TAideIncertitudeForm = class(TForm)
    BitBtn1: TButton;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    Memo1: TMemo;
  private
  public
  end;

var
  AideIncertitudeForm: TAideIncertitudeForm;

implementation

{$R *.FMX}

end.
