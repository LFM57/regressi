unit varKeyb;

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

  aideKey,
  compile,
  constreg,
  graphker,
  maths,
  regutil,
  uniteker,
  images;


type
  TNewClavierDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    GroupBox1: TGroupBox;
    ConstGB: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    TriCB: TCheckBox;
    GridVariab: TTMSFNCGrid;
    GridConst: TTMSFNCGrid;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure GridConstExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
  end;

var
  NewClavierDlg: TNewClavierDlg;

implementation

uses AideU;

{$R *.FMX}

procedure TNewClavierDlg.FormCreate(Sender: TObject);

procedure InitGrid(agrid : TTMSFNCGrid);
var Acol,Arow : integer;
begin with AGrid do begin
         ColumnCount := 3;
         columnWidths[0] := 80;
         columnWidths[1] := 60;
         columnWidths[2] := 170;
         cells[0,0] := stSymbole;
         cells[1,0] := stUnite;
         cells[2,0] := stSignif;
         for Acol := 0 to pred(columnCount) do
             for Arow := 1 to pred(rowCount) do
                 cells[Acol,Arow] := '';
end end;

begin
     InitGrid(GridVariab);
     InitGrid(GridConst);
end;

procedure TNewClavierDlg.FormShow(Sender: TObject);
begin
     inherited;
     gridVariab.focusedCell := makeCell(0,1);
     TriCB.IsChecked  := not DataTrieGlb;
     GridVariab.SetFocus;
end;

procedure TNewClavierDlg.GridConstExit(Sender: TObject);
begin
 //    (GridConst.ActiveEditControl as TTMSFMXEdit).
end;

procedure TNewClavierDlg.OKBtnClick(Sender: TObject);

Function Ajoute(i : integer;agrid : TTMSFNCgrid;genre : TgenreGrandeur) : boolean;
var u : Tunite;
    uniteOK : boolean;
    v : codeGrandeur;
    newNom : string;
begin
Result := false;
if agrid.cells[0,i]<>'' then begin
      NewNom := agrid.cells[0,i];
      trimComplet(NewNom);
      if NomCorrect(newNom,grandeurInconnue)
         then begin
              U := Tunite.create;
              U.nomUnite := agrid.cells[1,i];
              UniteOK := U.correct;
              U.free;
              if not UniteOK and not OKReg(OkUniteInconnue,HELP_Unites) then begin
                   agrid.FocusedCell := makeCell(1,i);
                   resetEnTete;
                   Agrid.setFocus;
                   exit;
               end;
               v := ajouteExperimentale(newNom,genre);
               grandeurs[v].fonct.expression := agrid.cells[2,i];
               grandeurs[v].NomUnite := agrid.cells[1,i];
               if '°'=Grandeurs[v].nomUnite then AngleEnDegre := true;
               if 'rad'=Grandeurs[v].nomUnite then AngleEnDegre := false;
         end
         else begin
              resetEnTete;
              afficheErreur(codeErreurC,0);
              agrid.FocusedCell := makeCell(0,i);
              Agrid.SetFocus;
              exit;
         end;
    end;
    Result := true;
end;

var i : integer;
begin
     FichierTrie := not TriCB.ischecked;
     NomFichierData := '';
     ModeAcquisition := AcqClavier;
     modalResult := mrNone;
     GridVariab.StopEdit;
     GridConst.StopEdit;
     for i := 1 to pred(GridVariab.RowCount) do
         if not Ajoute(i,gridVariab,variable) then exit;
     for i := 1 to pred(GridConst.RowCount) do
         if not Ajoute(i,gridConst,constante) then exit;
     modalResult := mrOK;
     FichierTrie := DataTrieGlb;
     AjoutePage;
     pages[pageCourante].AffecteVariableP(false);
     ModifFichier := true;
end;


procedure TNewClavierDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
