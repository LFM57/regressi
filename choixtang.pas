unit choixtang;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IniFiles,
  FMX.Types,
  FMX.Controls,
  FMX.Colors,
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
  FMX.StdCtrls,
  FMX.SpinBox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  compile,
  graphker,
  maths,
  regutil;


type
  TChoixTangenteDlg = class(TForm)
    CancelBtn: TButton;
    OptionsBtn: TButton;
    TangenteCB: TComboBox;
    OKBtn: TButton;
    SupprCB: TCheckBox;
    OptionsPC: TTabControl;
    TabSheet1: TTabItem;
    StoechTS: TTabItem;
    TabSheet3: TTabItem;
    ComboBoxEx1: TComboBox;
    Label4: TLabel;
    NbreEdit: TEdit;
    Label3: TLabel;
    Burette: TSpinBox;
    Label5: TLabel;
    Becher: TSpinBox;
    Label1: TLabel;
    LargeurCB: TComboBox;
    Label6: TLabel;
    GridCB: TCheckBox;
    TangenteColor: TColorComboBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    procedure OptionsBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure TangenteCBChange(Sender: TObject);
    procedure NbreSpinButtonDownClick(Sender: TObject);
    procedure NbreSpinButtonUpClick(Sender: TObject);
  private
  public
  end;

var
  ChoixTangenteDlg: TChoixTangenteDlg;

implementation

{$R *.FMX}

procedure TChoixTangenteDlg.OptionsBtnClick(Sender: TObject);
begin
   TangenteCBChange(sender);
end;

procedure TChoixTangenteDlg.FormActivate(Sender: TObject);
begin
  case LigneRappelTangente of
     lrTangente : TangenteCB.itemIndex := 1;
     else TangenteCB.itemIndex := 0
  end;
//  if (stoechBecherGlb>1) or (stoechBuretteGlb>1)
 //    then optionsBtn.isPressed := true;
  largeurCB.itemIndex := round(1/LongueurTangente)-1;
  NbreEdit.text := IntToStr(NbrePointDerivee);
//  gridCB.IsChecked  := avecTableau;
  TangenteCBChange(sender);
end;

procedure TChoixTangenteDlg.NbreSpinButtonDownClick(Sender: TObject);
begin
     if NbrePointDerivee>MinPointsDerivee then begin
        dec(NbrePointDerivee,2);
        NbreEdit.text := IntToStr(NbrePointDerivee);
     end;
end;

procedure TChoixTangenteDlg.NbreSpinButtonUpClick(Sender: TObject);
begin
     if NbrePointDerivee<MaxPointsDerivee then begin
        inc(NbrePointDerivee,2);
        NbreEdit.text := IntToStr(NbrePointDerivee);
     end;
end;

procedure TChoixTangenteDlg.OKBtnClick(Sender: TObject);
begin
    case TangenteCB.itemIndex of
         1 : LigneRappelTangente := lrTangente;
         0 : LigneRappelTangente := lrEquivalence;
    end;
    //avecTableau := gridCB.isChecked;
    LigneRappelCourante := LigneRappelTangente;
    if stoechTS.visible
       then begin
     //     StoechBecherGlb := round(Becher.value);
      //    StoechBuretteGlb := round(Burette.value);
    //      pages[pageCourante].StoechBecher :=  StoechBecherGlb;
     //     pages[pageCourante].StoechBurette :=  StoechBuretteGlb;
       end
       else begin
      //    StoechBecherGlb := 1;
       //   StoechBuretteGlb := 1;
       end;
 //   LongueurTangente := 1/(largeurCB.itemIndex+1);
end;

procedure TChoixTangenteDlg.TangenteCBChange(Sender: TObject);
begin
   optionsPC.visible := optionsBtn.isPressed;
   stoechTS.Visible := TangenteCB.itemIndex<>2;
   largeurCB.visible := TangenteCB.itemIndex=2;
   if optionsBtn.isPressed
      then height := 248
      else height := round(248-optionsPC.height);
end;

end.


