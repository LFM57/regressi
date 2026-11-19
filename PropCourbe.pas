unit PropCourbe;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Math,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.StdCtrls,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Spinbox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  FMX.TMSFNCTypes,
  FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCGridCell,
  FMX.TMSFNCGridOptions,
  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomScrollControl,
  FMX.TMSFNCGridData,
  FMX.TMSFNCCustomGrid,
  FMX.TMSFNCGrid,

  compile,
  graphker,
  maths,
  regutil,
  uniteker,
  images;

type
  TPropCourbeForm = class(TForm)
    LissageGB: TGroupBox;
    OrdreLissageSE: TSpinBox;
    DeriveGB: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    SplineGB: TGroupBox;
    Label3: TLabel;
    OrdreSplineSE: TSpinBox;
    BitBtn1: TButton;
    ExtrapoleDerCB: TCheckBox;
    CourbeEdit: TEdit;
    NbreDeriveeSB: TSpinBox;
    Grid: TTMSFNCGrid;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OrdreSplineSEChange(Sender: TObject);
    procedure NbreSpinButtonDownClick(Sender: TObject);
    procedure NbreSpinButtonUpClick(Sender: TObject);
    procedure DegreRGClick(Sender: TObject);
    procedure OrdreLissageSEChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ExtrapoleDerCBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    varF : Tunite;
    procedure ModifDerivee;
  public
    Acourbe : Tcourbe;
    Agraphe : TgrapheReg;
    procedure MaJ;
  end;

var
  PropCourbeForm: TPropCourbeForm;

implementation

uses regmain;

{$R *.FMX}

procedure TPropCourbeForm.FormDestroy(Sender: TObject);
begin
     varF.free;
     PropCourbeForm := nil;
     inherited 
end;

procedure TPropCourbeForm.FormShow(Sender: TObject);
var Gder : Tsetgrandeur;
    i : integer;
    codeX,codeY : integer;
begin
    inherited;
    ExtrapoleDerCB.IsChecked  := ExtrapoleDerivee;
    splineGB.Visible := (trLigne in Acourbe.trace) and
                        ((Acourbe.optionLigne=LiSpline) or
                         (Acourbe.optionLigne=LiSinc));
    lissageGB.Visible := (Acourbe.varY.fonct.genreC=g_lissage) and
                         (Acourbe.varY.fonct.calcul.OperandDebut=nil);
    if Acourbe.optionLigne=LiSpline
       then begin
          splineGB.text := 'Lissage par une B-spline';
          ordreSplineSE.Max := ordreMaxSpline;
       end
       else begin
          splineGB.text := 'Lissage de Shannon par un sinc';
          ordreSplineSE.Max := ordreMaxSinc;
       end;
    OrdreLissageSE.Value := OrdreFiltrage;
    OrdreSplineSE.Value := OrdreLissage;
    NbreDeriveeSB.value := NbrePointDerivee;
    Gder := [];
    for i := 1 to pred(NbreGrandeurs) do begin
        if grandeurs[i].fonct.genreC=g_derivee then include(GDer,i);
        if grandeurs[i].fonct.genreC=g_enveloppe then include(GDer,i);
    end;
    codeX := Acourbe.varX.indexG;
    codeY := Acourbe.varY.indexG;
    deriveGB.Visible := (codeX in Gder) or
                        (codeY in Gder) or
                        ((Acourbe.varX.fonct.depend * Gder)<>[]) or
                        ((Acourbe.varY.fonct.depend * Gder)<>[]) or
                        (trVitesse in Acourbe.trace) or
                        (trAcceleration in Acourbe.trace);
end;

procedure TPropCourbeForm.FormCreate(Sender: TObject);
begin with Grid do begin
       cells[0,0] := 'Période';
       cells[0,1] := 'Fréquence';
       cells[0,2] := 'Crête à crête';
       cells[0,3] := 'Efficace';
       cells[0,4] := 'Moyenne';
       varF := Tunite.create;
end end;

procedure TPropCourbeForm.MaJ;
begin with aCourbe do begin
   courbeEdit.text := 'Caractéristiques de '+varY.nom+'('+varX.nom+')';
   courbeEdit.fontColor := acourbe.couleur;
   calcul;
   varF.RecopieUnite(varX);
   varF.uniteDonnee := false;
   varF.uniteImposee := false;
   varF.InverseUnite;
   if isNan(periode)
      then begin
           Grid.cells[1,0] := '?';
           Grid.cells[1,1] := '?';
           Grid.cells[1,3] := '';
      end
      else begin
          Grid.cells[1,0] := varX.formatValeurEtUnite(periode);
          Grid.cells[1,1] := varF.formatValeurEtUnite(1/periode);
          Grid.cells[1,3] := varY.formatValeurEtUnite(ValeurEff);
      end;
   Grid.cells[1,2] := varY.formatValeurEtUnite(ValeurMax-ValeurMin);
   Grid.cells[1,4] := varY.formatValeurEtUnite(ValeurMoy);
end end;

procedure TPropCourbeForm.OrdreSplineSEChange(Sender: TObject);
begin
    OrdreLissage := round(OrdreSplineSE.Value);
    Agraphe.paintBox.repaint;
end;

procedure TPropCourbeForm.ModifDerivee;
begin
    ExtrapoleDerivee := ExtrapoleDerCB.isChecked;
    OrdreFiltrage := round(OrdreLissageSE.Value);
    NbrePointDerivee := round(NbreDeriveeSB.Value);
    recalculE;
    FRegressiMain.WMRegMaj(MajValeur)
end;

procedure TPropCourbeForm.NbreSpinButtonDownClick(Sender: TObject);
begin
    ModifDerivee;
end;

procedure TPropCourbeForm.NbreSpinButtonUpClick(Sender: TObject);
begin
    ModifDerivee;
end;

procedure TPropCourbeForm.DegreRGClick(Sender: TObject);
begin
    ModifDerivee
end;

procedure TPropCourbeForm.OrdreLissageSEChange(Sender: TObject);
begin
    ModifDerivee
end;

procedure TPropCourbeForm.BitBtn1Click(Sender: TObject);
begin
  close
end;

procedure TPropCourbeForm.ExtrapoleDerCBClick(Sender: TObject);
begin
    ModifDerivee
end;

end.

