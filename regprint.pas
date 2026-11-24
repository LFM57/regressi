unit regPrint;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.Printer,
  FMX.ExtCtrls,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Graphics,
  FMX.Controls.Presentation,

  aidekey,
  compile,
  constreg,
  graphker,
  regutil,
  valeurs,
  images,
  grapheVariabU;

type
  TPrintDlg = class(TForm)
    PanelOption: TPanel;
    PrintBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Panel1: TPanel;
    GrandeursCB: TCheckBox;
    ModeleVariabCB: TCheckBox;
    GrapheVariabCB: TCheckBox;
    GrapheFourierCB: TCheckBox;
    GrapheStatCB: TCheckBox;
    GroupBox2: TGroupBox;
    EnteteEdit: TEdit;
    PrintCB: TComboBox;
    ImprimanteGB: TGroupBox;
    PrinterBtn: TButton;
    PrinterSetupDialog: TPrinterSetupDialog;
    procedure PrintBtnClick(Sender: TObject);
    procedure PrinterBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PrintCBChange(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
  end;

var
  PrintDlg: TPrintDlg;

implementation

uses Options, graphFft, optStat, regmain, AideU;

{$R *.FMX}

procedure TPrintDlg.PrintBtnClick(Sender: TObject);
var
  debutImp : single;
  page : codePage;
begin
     try
          Printer.title := 'Regressi '+NomFichierData;
          Printer.ActivePrinter;
          Printer.BeginDoc;
          debutImp := 0;
          BeginPrintTxt(debutImp);
          PrintLine(enTeteEdit.text,debutImp);
          if GrandeursCB.IsChecked  then
             PrintList(Fvaleurs.Memo.lines,'',debutImp);
// Modélisation
          if ModeleVariabCB.isVisible and ModeleVariabCB.IsChecked then begin
             PrintList(TexteModele,stModelisation,debutImp);
             for page := 1 to NbrePages do
                 if pages[page].active then
                    PrintList(pages[page].TexteResultatModele,
                              pages[page].TitrePage,debutImp);
          end;
// Graphe
          if GrapheVariabCB.ischecked then
             graphe.ImprimerGraphe(debutImp);
          if (FgrapheFFT<>nil) and
             GrapheFourierCB.IsChecked then
             FgrapheFFT.ImprimerGraphe(debutImp);
          if (statOptDlg<>nil) and
             GrapheStatCB.IsChecked then statOptDlg.Imprimer;
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

procedure TPrintDlg.PrintCBChange(Sender: TObject);
begin
     printer.activePrinter := printer.printers[printCB.ItemIndex];
end;

procedure TPrintDlg.FormActivate(Sender: TObject);
var i : integer;
begin
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

procedure TPrintDlg.PrinterBtnClick(Sender: TObject);
begin
    printerSetUpDialog.execute
end;

procedure TPrintDlg.FormShow(Sender: TObject);
begin
    inherited;
    grapheFourierCB.Visible := FgrapheFFT<>nil;
    grapheStatCB.Visible := statOptDlg<>nil;
    ModeleVariabCB.Visible := FRegressiMain.panelModele.visible or
            (ModeleDefini in graphe.etatModele);
end;


procedure TPrintDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.

