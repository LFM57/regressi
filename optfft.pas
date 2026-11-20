unit optfft;

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
  FMX.TreeView,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Spinbox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  aidekey,
  compile,
  fft,
  graphker,
  maths,
  regutil,
  selpage,
  images;

type
  TOptionsFFTDlg = class(TForm)
    PanelBoutons: TPanel;
    BtnOK: TButton;
    BtnCancel: TButton;
    BtnHelp: TButton;
    PanelOptions: TPanel;
    PageControl: TTabControl;
    AbscisseTS: TTabItem;
    LabelNomTemps: TLabel;
    Label4: TLabel;
    EditNomFrequence: TEdit;
    OptimiseNbreHarmCB: TCheckBox;
    HarmMinSE: TSpinBox;
    OrdonneeTS: TTabItem;
    LabeldB: TLabel;
    LabelWidth: TLabel;
    ListeVariableBox: TListBox;
    DecibelCB: TCheckBox;
    EnveloppeCB: TCheckBox;
    WidthEcranSE: TSpinBox;
    SpinMindb: TSpinBox;
    SuperpositionTS: TTabItem;
    PagesBtn: TButton;
    SuperPagesCB: TCheckBox;
    AnalyseurCB: TCheckBox;
    SonagrammeTS: TTabItem;
    LabeldBsur: TLabel;
    DecadeSE: TSpinBox;
    DecadeLabel: TLabel;
    FaussesCouleursCB: TCheckBox;
    Label2: TLabel;
    DecalageSE: TSpinBox;
    procedure BtnOKClick(Sender: TObject);
    procedure dBCheckBoxClick(Sender: TObject);
    procedure PagesBtnClick(Sender: TObject);
    procedure SuperPagesCBClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
    MiniDecibel : double;
    procedure Init;
  end;

var
  OptionsFFTDlg : TOptionsFFTDlg;

implementation

uses Graphfft, AideU;

{$R *.FMX}

procedure TOptionsFFTDlg.Init;
begin
     HarmMinSE.value := round(PrecisionFFT*100);
     DecalageSE.value := decalageFFT;
     OptimiseNbreHarmCB.IsChecked  := NbreHarmoniqueOptimise;
     SpinMindB.value := MiniDecibel;
     LabelNomTemps.Text := 'Nom de la grandeur inverse de '+grandeurs[indexTri].nom;
     EditNomFrequence.text := grandeurs[cFrequence].nom;
     LabeldB.visible := DecibelCB.isChecked;
     SpinMindB.Visible := LabeldB.isVisible;
     widthEcranSE.value := penWidthEcran;
     AnalyseurCB.IsChecked  := OgAnalyseurLogique in FgrapheFFT.GrapheFrequence.OptionGraphe;
     ListeVariableBox.repaint;
     FaussesCouleursCB.isChecked := UseFaussesCouleurs;
     superPagesCB.IsChecked  := FgrapheFFT.grapheFrequence.SuperposePage;
     MiniDecibel := FgrapheFFT.grapheFrequence.monde[mondeY].MinidB;
     height := 175;
     width := 520;
end;

procedure TOptionsFFTDlg.BtnOKClick(Sender: TObject);
begin
    NbreHarmoniqueOptimise := OptimiseNbreHarmCB.isChecked;
    PrecisionFFT := HarmMinSE.value/100;
    Grandeurs[cFrequence].nom := editNomFrequence.text;
    DecalageFFT := round(decalageSE.value);
    penWidthEcran := round(widthEcranSE.value);
    MiniDecibel := spinMindB.value;
    UseFaussesCouleurs := FaussesCouleursCB.isChecked;
    FgrapheFFT.grapheFrequence.monde[mondeY].MinidB := MiniDecibel;
    FgrapheFFT.grapheFrequence.SuperposePage := superPagesCB.isChecked;
    FgrapheFFT.grapheTemps.SuperposePage := FgrapheFFT.grapheFrequence.SuperposePage;
    if AnalyseurCB.isChecked
         then begin
            include(FgrapheFFT.grapheFrequence.OptionGraphe,OgAnalyseurLogique);
            include(FgrapheFFT.grapheTemps.OptionGraphe,OgAnalyseurLogique)
         end
         else begin
            exclude(FgrapheFFT.grapheFrequence.OptionGraphe,OgAnalyseurLogique);
            exclude(FgrapheFFT.grapheTemps.OptionGraphe,OgAnalyseurLogique);
         end;
end;

procedure TOptionsFFTDlg.dBCheckBoxClick(Sender: TObject);
begin
     LabeldB.Visible := decibelCB.ischecked;
     SpinMindB.Visible := LabeldB.isVisible;
end;

procedure TOptionsFFTDlg.PagesBtnClick(Sender: TObject);
begin
     selectPageDlg := TselectPageDlg.Create(self);
     SelectPageDlg.appelPrint := false;
     SelectPageDlg.caption := 'Choix des pages affichées sur le graphe';
     CentreForm(SelectPageDlg);
     SelectPageDlg.showModal;
     selectPageDlg.Free;
end;

procedure TOptionsFFTDlg.SuperPagesCBClick(Sender: TObject);
begin
   PagesBtn.Visible := SuperPagesCB.isChecked
end;


procedure TOptionsFFTDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
