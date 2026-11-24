unit PrintPdfU;

interface

uses
  System.SysUtils, System.Types, System.UITypes,
  System.Classes, System.Variants,
  System.IniFiles,

  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,

  FMX.TMSFNCPDFIO,
  FMX.TMSFNCRichEditorPDFIO, 
  FMX.TMSFNCRichEditorBase, FMX.TMSFNCRichEditor,
  FMX.TMSFNCGrid,
  FMX.TMSFNCRichEditorToolBar,
  FMX.TMSFNCToolBar, FMX.TMSFNCTypes,
  FMX.TMSFNCUtils, FMX.TMSFNCGraphics, 
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomComponent,
  FMX.TMSFNCScrollControl;

type
  TPrintPdfForm = class(TForm)
    Editor: TTMSFNCRichEditor;
    TMSEditortoPDF: TTMSFNCRichEditorPDFIO;
    PdfBtn: TButton;
    Panel1: TPanel;
    GrandeursCB: TCheckBox;
    ModeleVariabCB: TCheckBox;
    GrapheVariabCB: TCheckBox;
    GrapheFourierCB: TCheckBox;
    TestBtn: TButton;
    DockPanel1: TTMSFNCDockPanel;
    FormatToolBar1: TTMSFNCRichEditorFormatToolBar;
    EditToolBar1: TTMSFNCRichEditorEditToolBar;
    GrapheStatCB: TCheckBox;
    SaveDialog: TSaveDialog;
    procedure PdfBtnClick(Sender: TObject);
    procedure GrandeursCBChange(Sender: TObject);
    procedure TestBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
  end;

var
  PrintPdfForm: TPrintPdfForm;

implementation

uses regmain, valeurs, graphfft, optStat, compile, regutil,
     graphker, grapheVariabU;

{$R *.fmx}

procedure TPrintPdfForm.FormCreate(Sender: TObject);
var  Rini : TIniFile;
begin
  Rini := TIniFile.create(registreReg);
  grandeursCB.isChecked := Rini.ReadBool('PDF','Expression',true);
  modeleVariabCB.isChecked := Rini.ReadBool('PDF','ModeleVar',true);
  grapheFourierCB.isChecked := Rini.ReadBool('PDF','GrapheFFT',true);
  grapheVariabCB.isChecked := Rini.ReadBool('PDF','GrapheVar',true);
  grapheStatCB.isChecked := Rini.ReadBool('PDF','GrapheStat',true);
  Rini.free;
end;

procedure TPrintPdfForm.FormDestroy(Sender: TObject);
var RIni : TMeminiFile;
begin
  Rini := TMemIniFile.create(registreReg);
  Rini.WriteBool('PDF','Expression',grandeursCB.isChecked);
  Rini.WriteBool('PDF','ModeleVar',modeleVariabCB.isChecked);
  Rini.WriteBool('PDF','GrapheFFT',grapheFourierCB.isChecked);
  Rini.WriteBool('PDF','GrapheVar',grapheVariabCB.isChecked);
  Rini.WriteBool('PDF','GrapheStat',grapheStatCB.isChecked);
  RIni.UpdateFile;
  Rini.free;
end;

procedure TPrintPdfForm.FormShow(Sender: TObject);
begin
    grapheStatCB.Visible := statOptDlg<>nil;
    grapheFourierCB.Visible := FgrapheFFT<>nil;
    ModeleVariabCB.Visible := FRegressiMain.panelModele.visible or
                             (ModeleDefini in graphe.etatModele);
    pdfBtn.visible := false;
end;

procedure TPrintPdfForm.GrandeursCBChange(Sender: TObject);
begin
    pdfBtn.visible := false;
end;

procedure TPrintPdfForm.PdfBtnClick(Sender: TObject);
begin
   SaveDialog.DefaultExt := 'pdf';
   SaveDialog.Filter := 'Fichiers PDF (*.pdf)|*.pdf';
   SaveDialog.Title := 'Sauvegarde au format PDF';
   if SaveDialog.Execute then begin
          TMSEditortoPDF.options.Footer := '';
          TMSEditortoPDF.options.Header := '';
          TMSEditortoPDF.Save(ChangeFileExt(SaveDialog.FileName,'.pdf'));
   end;
end;

procedure TPrintPdfForm.TestBtnClick(Sender: TObject);

procedure printGrid(const aGrid : TTMSFNCGrid);
var col,row,tab,Ntab : integer;
    texte : string;
    largeur : array of integer;
    L : integer;
begin
     setLength(largeur,aGrid.columnCount);
     for col := 0 to aGrid.ColumnCount-1 do begin
         largeur[col] := 0;
         for row := 0 to aGrid.RowCount-1 do begin
             L := length(aGrid.Cells[col,row]) div 5;
             if L>largeur[col] then largeur[col] := L;
         end;
         inc(largeur[col]);
     end;
     Editor.beginUpdate;
     for row := 0 to aGrid.RowCount-1 do begin
         texte := '';
         for col := 0 to aGrid.ColumnCount-1 do begin
             texte := texte+aGrid.Cells[col,row];
             Ntab := largeur[col]-(length(aGrid.Cells[col,row]) div 5);
             for tab := 1 to Ntab do
                 texte := texte+crTab;
         end;
         Editor.AddText(texte);
         Editor.AddLineBreak;
     end;
     Editor.endUpdate;
end;

procedure printLines(aline : TStrings);
var i : integer;
begin
  Editor.beginUpdate;
  for i := 0 to pred(aline.count) do begin
     Editor.AddText(aline[i]);
     Editor.AddLineBreak;
  end;
  Editor.endUpdate;
end;

procedure printTitre(aline : String);
var posC : integer;
begin
     posC := length(editor.plainText);
     Editor.beginUpdate;
     Editor.AddText(aLine);
     Editor.selectText(posC,length(aline));
     Editor.setSelectionBold(true);
     Editor.setSelectionFontSize(14);
     Editor.setSelectionAttribute(taCenter);
     Editor.AddLineBreak;
     Editor.endUpdate;
end;

procedure printImage(aGraphe : TGrapheReg);
const largeur = 500;
var coeff : double;
    aBitmap : Tbitmap;
begin
    aBitmap := agraphe.ZoneClipBoard.MakeScreenshot;
    aBitmap.SaveToFile(nomTamponPdf);
    coeff := aBitmap.Height/abitmap.Width;
    Editor.AddImage(nomTamponPDF,largeur,round(coeff*largeur));
    Editor.AddLineBreak;
    abitmap.free;
end;

var page : codePage;
    posC : integer;
begin
          Editor.clear;
          if GrandeursCB.IsChecked  then begin
             printTitre('Grandeurs');
             printLines(Fvaleurs.Memo.lines);
          end;
          if ModeleVariabCB.isVisible and ModeleVariabCB.IsChecked then begin
             printTitre('Modélisation');
             printLines(TexteModele);
             for page := 1 to NbrePages do
                 if pages[page].active then begin
                    Editor.AddText(pages[page].TitrePage);
                    Editor.AddLineBreak;
                    printLines(pages[page].TexteResultatModele);
                 end;
          end;
          if GrapheVariabCB.ischecked then begin
             printImage(graphe);
          end;
          if (FgrapheFFT<>nil) and GrapheFourierCB.IsChecked then begin
             printTitre('Fourier');
             printImage(FgrapheFFT.grapheFrequence);
          end;
          if (statOptDlg<>nil) and GrapheStatCB.IsChecked then begin
                printTitre('Statistique');
                printImage(FRegressiMain.grapheStat);
                PrintGrid(FRegressiMain.StatGrid);
                PrintGrid(FRegressiMain.DistGrid);
          end;
          pdfBtn.visible := true;
          posC := editor.Caret.charIndex;
          Editor.selectText(posC,0);
end;

end.
