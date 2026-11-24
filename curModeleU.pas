unit curModeleU;

interface

uses
  System.SysUtils, System.Types,
  System.UITypes, System.Classes,
  System.Variants,

  FMX.Types, FMX.Controls,
  FMX.Forms, FMX.Graphics,
  FMX.Dialogs,
  FMX.ListBox, 
  FMX.StdCtrls,

  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomScrollControl, FMX.TMSFNCGridData, FMX.TMSFNCCustomGrid,
  FMX.TMSFNCGrid, FMX.TMSFNCGridCell, FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes, FMX.TMSFNCGridOptions,

  FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation,
  FMX.Printer,
  FMX.Platform,
  FMX.Memo.Types,

  compile,
  graphker,
  regutil,
  grapheVariabU,
  constreg;

type
  TCurseurModeleDlg = class(TForm)
    GroupBox1: TGroupBox;
    Memo: TMemo;
    tableau: TTMSFNCGrid;
    OKBtn: TButton;
    HelpBtn: TButton;
    PrintBtn: TButton;
    RazBtn: TButton;
    CopyBtn: TButton;
    ImprimanteGB: TGroupBox;
    PrinterBtn: TButton;
    PrinterSetupDialog: TPrinterSetupDialog;
    PrintCB : TComboBox;
    procedure OKBtnClick(Sender: TObject);
    procedure RazBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure tableauCellEditSetData(Sender: TObject; ACol, ARow: Integer;
      CellEditor: TControl; var CellString: string);
    procedure PrinterBtnClick(Sender: TObject);
    procedure PrintCBChange(Sender: TObject);
    procedure YdeXRBChange(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
     ligne,colonne : integer;
  end;

var
  CurseurModeleDlg: TCurseurModeleDlg;

implementation

uses AideU;

{$R *.fmx}

procedure TCurseurModeleDlg.CopyBtnClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
  ct, cliptext: string;
  row,col: Integer;
begin
    if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc) then begin
       try
       cliptext := '';
       for row := 0 to tableau.RowCount-2 do begin
           for col := 0 to tableau.ColumnCount-1 do begin
              ct := tableau.Cells[col,row];
              if col < tableau.ColumnCount-1
                  then cliptext := cliptext + ct + crTab
                  else cliptext := cliptext + ct;
           end;
           if row < tableau.RowCount-2 then
              cliptext := cliptext + crCR + crLF;
       end;
       for row := 0 to Memo.Lines.Count-1 do begin
           cliptext := cliptext + Memo.Lines[row] + crCR + crLF;
       end;
       Svc.SetClipboard(clipText);
       finally
       end;
    end;
end;

procedure TCurseurModeleDlg.FormActivate(Sender: TObject);
var i : integer;
begin
     inherited;
     tableau.hint := hValeurModele;
     caption := stValeurModele;
     with printer() do begin
       printCB.visible := Count>1;
       printCB.Items.Clear;
       for i := 0 to count-1 do
           printCB.items.add(printers[i].title);
     end;
   {$IFDEF MACOS}
     printerBtn.visible := false;
   {$ENDIF}
end;

procedure TCurseurModeleDlg.tableauCellEditSetData(Sender: TObject; ACol,
  ARow: Integer; CellEditor: TControl; var CellString: string);
begin
     if Acol<2 then begin
         colonne := Acol;
         ligne := Arow;
         graphe.calculCurseurModele(cellString);
         if Arow<(tableau.rowCount-1)
            then tableau.focusedCell := makecell(Acol,Arow+1)
            else tableau.focusedCell := makecell(2,Arow); // commentaire
     end;
     if (Acol=2) and
        ((Arow-2)<graphe.equivalences[pageCourante].count) then begin
         graphe.equivalences[pageCourante].items[Arow-2].commentaire := cellString;
     end;
end;

procedure TCurseurModeleDlg.YdeXRBChange(Sender: TObject);
var i : integer;
begin
         for i := 0 to pred(graphe.equivalences[pageCourante].count) do
             graphe.equivalences[pageCourante][i].ligneRappel := ligneRappelCourante;
         graphe.paintBox.repaint;
end;

procedure TCurseurModeleDlg.OKBtnClick(Sender: TObject);
begin
      Close
end;

procedure TCurseurModeleDlg.PrintBtnClick(Sender: TObject);
var bas : single;
    i : integer;
begin
          try
          Printer.title := 'Regressi '+NomFichierData;
          Printer.ActivePrinter;
          Printer.BeginDoc;
          bas := 0;
          BeginPrintTxt(bas);
          PrintList(Memo.Lines,'',bas);
          PrintLine(Caption,bas);
          PrintList(TexteModele,'',bas);
          for i := 0 to pred(graphe.equivalences[pageCourante].count) do
          with graphe.equivalences[pageCourante][i] do begin
               PrintLine(Commentaire+' : '+
                         graphe.monde[mondeX].axe.formatNomEtUnite(ve)+' ; '+
                         graphe.monde[mondepH].axe.formatNomEtUnite(phe),bas);
          end;
          graphe.ImprimerGraphe(bas);
          Printer.EndDoc;
          except
            on E: Exception do begin
                showMessage(E.message);
                try
                Printer.Abort;
                except
                end;
          end;
          end;
end;

procedure TCurseurModeleDlg.PrintCBChange(Sender: TObject);
begin
     printer.activePrinter := printer.printers[printCB.ItemIndex]
end;

procedure TCurseurModeleDlg.PrinterBtnClick(Sender: TObject);
begin
    printerSetUpDialog.execute
end;

procedure TCurseurModeleDlg.RazBtnClick(Sender: TObject);
var p : codePage;
    i : integer;
begin
     for p := 1 to maxPages do begin
         Graphe.equivalences[p].clear;
         graphe.PaintBox.repaint;
     end;
     with tableau do begin
         rowCount := 3;
         for i := 0 to 2 do cells[i,2] := '';
     end;
     invalidate;
end;

procedure TCurseurModeleDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
