unit ChoixParamAnim;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  
  FMX.Types,
  FMX.Controls, 
  FMX.Forms, FMX.Graphics, 
  FMX.Dialogs,
  
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
  
  FMX.Controls.Presentation, 
  FMX.StdCtrls,
  FMX.ScrollBox,
  FMX.Memo, FMX.Memo.Types;

type
  TParamAnimationDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    EchelleAutoCB: TCheckBox;
    Memo1: TMemo;
    ParamGrid: TTMSFNCGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ParamGridGetCellIsFixed(Sender: TObject; ACol, ARow: Integer;
      var ACellFixed: Boolean);
  private
  public
  end;

var
  ParamAnimationDlg: TParamAnimationDlg;

implementation

uses regutil, math, constreg, compile, maths;

{$R *.fmx}

procedure TParamAnimationDlg.FormActivate(Sender: TObject);
var i : integer;
begin
    inherited;
    ParamGrid.RowCount := NbreParamAnimation+1;
    for i := 1 to pred(ParamGrid.rowCount) do
    with paramAnimation[pred(i)] do begin
       ParamGrid.cells[1,i] := FormatReg(debutA);
       ParamGrid.cells[2,i] := FormatReg(finA);
       ParamGrid.cells[3,i] := FormatReg(pasA);
       ParamGrid.cells[0,i] := nomA;
       ParamGrid.AddDataCheckBox(4,i,active);
       ParamGrid.AddDataCheckBox(5,i,variationLog);
    end;
end;

procedure TParamAnimationDlg.FormCreate(Sender: TObject);
begin
     ParamGrid.cells[1,0] := 'Début';
     ParamGrid.cells[2,0] := 'Fin';
     ParamGrid.cells[3,0] := 'Pas';
     ParamGrid.cells[4,0] := 'Actif';
     ParamGrid.cells[5,0] := 'Exp.';
     paramGrid.columnWidths[4] := 32;
     paramGrid.columnWidths[5] := 32;
end;

procedure TParamAnimationDlg.OKBtnClick(Sender: TObject);
var i : integer;
    UnActif : boolean;
begin
    for i := 1 to pred(ParamGrid.rowCount) do
    with paramAnimation[pred(i)] do begin
        try
        DebutA := GetFloat(ParamGrid.cells[1,i]);
        except end;
        try
        FinA := GetFloat(ParamGrid.cells[2,i]);
        except end;
        try
        PasA := GetFloat(ParamGrid.cells[3,i]);
        except end;
        PasA := abs(PasA);
        active := ParamGrid.Cells[4,i] = ParamGrid.CheckTrue;
        variationLog := ParamGrid.Cells[5,i] = ParamGrid.CheckTrue;
    end;
    UnActif := false;
    for i := 0 to pred(NbreParamAnimation) do
        UnActif := UnActif or paramAnimation[i].active;
    if not UnActif then paramAnimation[pred(NbreParamAnimation)].active := true;
    for i := 0 to pred(NbreParamAnimation) do with paramAnimation[i] do begin
        codeA := indexConstExp[i];
        if variationLog
              then begin
                try
                  DebutA := abs(DebutA);
                  FinA := abs(FinA);
                  VerifMinMaxReal(DebutA,FinA);
                  if pasA<=1 then pasA := 1.05;
                  if (log10(finA/debutA)/log10(pasA))>MaxPasAnimation then
                     pasA := power(10,log10(finA/debutA)/MaxPasAnimation);
                  if (log10(finA/debutA)/log10(pasA))<4 then
                     pasA := power(10,log10(finA/debutA)/4);
                  except
                     pasA := power(10,2/MaxPasAnimation);
                     debutA := finA/100;
                     AfficheErreur(erRemplitLog,0);
                  end;
                  if valeurA<debutA then valeurA := debutA;
                  if valeurA>finA then valeurA := finA;
             end
             else begin { linéaire }
                 VerifMinMaxReal(DebutA,FinA);
                 if (finA-debutA)/pasA>MaxPasAnimation
                    then pasA := (finA-debutA)/MaxPasAnimation;
                 if (finA-debutA)/pasA<2 then pasA := (finA-debutA)/5;
                 if valeurA<debutA then valeurA := debutA;
                 if valeurA>finA then valeurA := finA;
             end;
       end;
end;

procedure TParamAnimationDlg.ParamGridGetCellIsFixed(Sender: TObject; ACol, ARow: Integer;
  var ACellFixed: Boolean);
begin
    AcellFixed := (Arow=0) or (Acol=0)
end;

end.
