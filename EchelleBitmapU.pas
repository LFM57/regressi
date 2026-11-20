unit echelleBitmapU;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Rtti,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Controls.Presentation,

  aideKey,
  compile,
  constreg,
  graphker,
  maths,
  regutil,
  uniteker,
  images,
  bitmapU;


type
  TEchelleBitmapDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    OrthonormeCB: TCheckBox;
    PolaireCB: TCheckBox;
    GridVariab: TTMSFNCGrid;
    avecTCB: TCheckBox;
    IncrementLabel: TLabel;
    deltatEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridVariabGetCellEditorType(Sender: TObject; ACol, ARow: Integer;
      var CellEditorType: TTMSFMXGridEditorType);
    procedure GridVariabGetCellClass(Sender: TObject; ACol, ARow: Integer;
      var CellClassType: TFmxObjectClass);
    procedure GridVariabGetCellEditorProperties(Sender: TObject; ACol,
      ARow: Integer; CellEditor: TFmxObject);
    procedure GridVariabSelectCell(Sender: TObject; ACol, ARow: Integer;
      var Allow: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure avecTCBChange(Sender: TObject);
    procedure GridVariabGetCellData(Sender: TObject; ACol, ARow: Integer;
      var CellString: string);
    procedure PolaireCBChange(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
  end;

var
  EchelleBitmapDlg: TEchelleBitmapDlg;

implementation

uses AideU;

{$R *.FMX}

procedure TEchelleBitmapDlg.avecTCBChange(Sender: TObject);
begin
    IncrementLabel.visible := avectCB.isChecked;
    deltatEdit.visible := avectCB.isChecked;
end;

procedure TEchelleBitmapDlg.FormActivate(Sender: TObject);
begin with bitmapForm do begin
    GridVariab.BeginUpdate;
    avecTCB.IsChecked := avecT;
    GridVariab.CheckBoxState[6,2] := echelleX=eLog;
    GridVariab.CheckBoxState[6,3] := echelleY=eLog;
    GridVariab.Cells[1,2] := nomX;
    GridVariab.Cells[2,2] := uniteX;
    GridVariab.Cells[1,1] := nomT;
    GridVariab.Cells[2,1] := uniteT;
    GridVariab.Cells[1,3] := nomY;
    GridVariab.Cells[2,3] := uniteY;
    GridVariab.Cells[3,1] := signifT;
    GridVariab.Cells[3,3] := signifY;
    GridVariab.Cells[3,2] := signifX;
    orthonormeCB.IsChecked := orthonorme;
    polaireCB.IsChecked := echelleX=ePolaire;
    gridVariab.EndUpdate;
end end;

procedure TEchelleBitmapDlg.FormCreate(Sender: TObject);
begin with GridVariab do begin
         BeginUpdate;
         columnWidths[3] := 180;
         cells[0,1] := stAxeT;
         cells[0,2] := stAxeX;
         cells[0,3] := stAxeY;
         cells[1,0] := stSymbole;
         cells[2,0] := stUnite;
         cells[3,0] := stSignif;
         cells[4,0] := stOrigine;
         cells[5,0] := stExtremite;
         cells[6,0] := stAxeLog;
         cells[4,2] := '0';
         cells[4,3] := '0';
         cells[5,2] := '1';
         cells[5,3] := '1';
         endUpdate;
end end;

procedure TEchelleBitmapDlg.FormShow(Sender: TObject);
begin
     inherited;
     gridVariab.focusedCell := Cell(1,1);
     GridVariab.SetFocus;
end;

procedure TEchelleBitmapDlg.GridVariabGetCellClass(Sender: TObject; ACol,
  ARow: Integer; var CellClassType: TFmxObjectClass);
begin
    if (Acol=6) and (Arow in [2,3]) then CellClassType := TTMSFMXCheckGridCell;
end;

procedure TEchelleBitmapDlg.GridVariabGetCellData(Sender: TObject; ACol,
  ARow: Integer; var CellString: string);
begin
    if (Arow>0) and (Acol in [0,1,2,3]) then
       cellString := GridVariab.Cells[Acol,ARow];
end;

procedure TEchelleBitmapDlg.GridVariabGetCellEditorProperties(Sender: TObject;
  ACol, ARow: Integer; CellEditor: TFmxObject);
begin
   if acol in [4,5] then (CellEditor as TTMSFMXEdit).validChars := validCharsGrid; // mini maxi
end;

procedure TEchelleBitmapDlg.GridVariabGetCellEditorType(Sender: TObject; ACol,
  ARow: Integer; var CellEditorType: TTMSFMXGridEditorType);
begin
      case Acol of
           1,2,3 : CellEditorType := etEdit; // nom Unite Signif
           4,5 : CellEditorType := etValidCharsEdit; // mini maxi
           6 : ; // log
      end;
end;

procedure TEchelleBitmapDlg.GridVariabSelectCell(Sender: TObject; ACol,
  ARow: Integer; var Allow: Boolean);
begin
    Allow := not ((Arow=1) and (ACol in[4,5,6]))
end;

procedure TEchelleBitmapDlg.OKBtnClick(Sender: TObject);

Procedure Ajoute(i : integer);
var newNom,newUnite,newSignif : string;
    newMini,newmaxi : double;
begin
      NewNom := gridVariab.cells[1,i];
      NewUnite := gridVariab.cells[2,i];
      NewSignif := gridVariab.cells[3,i];
      newmaxi := 1;
      newmini := 0;
      if i>1 then begin
          try
          newMaxi := StrToFloatWin(gridVariab.cells[5,i]);
          except
          newmaxi := 1;
          end;
          try
          newMini := StrToFloatWin(gridVariab.cells[4,i]);
          except
          newMini := newMaxi+1;
          end;
          if newmaxi=newmini then newmaxi := newmini+1;
      end;
      trimComplet(NewNom);
      if NomCorrect(newNom,grandeurInconnue)
         then begin
            if '°'=newUnite then AngleEnDegre := true;
            if 'rad'=newUnite then AngleEnDegre := false;
            case i of
               1: begin
                  bitmapForm.nomT := newNom;
                  bitmapForm.uniteT := newUnite;
               end;
               2: begin
                  bitmapForm.nomX := newNom;
                  bitmapForm.uniteX := newUnite;
                  bitmapForm.miniX := newMini;
                  bitmapForm.maxiX := newMaxi;
               end;
               3: begin
                  bitmapForm.nomY := newNom;
                  bitmapForm.uniteY := newUnite;
                  bitmapForm.miniY := newMini;
                  bitmapForm.maxiY := newMaxi;
               end;
            end;
         end
         else begin
              afficheErreur(codeErreurC,0);
              gridVariab.FocusedCell := cell(1,i);
              gridvariab.SetFocus;
         end;
end;

begin
     NomFichierData := '';
     ModeAcquisition := AcqClavier;
     modalResult := mrNone;
     GridVariab.StopEdit;
     ajoute(1);ajoute(2);ajoute(3);
     with bitmapForm do begin
        try
        deltat := StrToFloatWin(deltatEdit.text);
        except
           deltat := 1/25;
        end;
        echelleX := elin;
        echelleY := elin;
        orthonorme := orthonormeCB.IsChecked;
        avecT := avecTCB.IsChecked;
        if polaireCB.isChecked then begin
           echelleX := ePolaire;
           echelleY := ePolaire;
        end
        else begin
            if GridVariab.CheckBoxState[6,2] then begin
               echelleX := elog;
               orthonorme := false;
               if (miniX<=0) then miniX := 2;
               if (maxiX<=0) then maxiX := miniX+1;
            end;
            if GridVariab.CheckBoxState[6,3] then begin
               echelleY := elog;
               orthonorme := false;
               if  (miniY<=0) then miniY := 2;
               if  (maxiY<=0) then maxiY := miniY+1;
            end;
        end;
        modalResult := mrOK;
     end;
 end;

procedure TEchelleBitmapDlg.PolaireCBChange(Sender: TObject);
begin
    if polaireCB.isChecked then begin
         gridVariab.cells[0,2] := stAngle;
         gridVariab.cells[0,3] := stRayon;
    end
    else begin
         gridVariab.cells[0,2] := stAxeX;
         gridVariab.cells[0,3] := stAxeY;
    end;

end;


procedure TEchelleBitmapDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
