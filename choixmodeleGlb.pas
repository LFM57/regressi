unit choixmodeleGlb;

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
  FMX.Controls.Presentation,

  aidekey,
  compile,
  constreg,
  graphker,
  maths,
  modelegr,
  regutil,
  uniteKer;


type
  TChoixModeleGlbDlg = class(TForm)
    AjouteBtn: TButton;
    CancelBtn: TButton;
    PageControl: TTabControl;
    ModManuel: TTabItem;
    yEdit: TEdit;
    CalculetteBtn: TButton;
    ModMagnum: TTabItem;
    DroiteBtn: TButton;
    SpeedButton2: TButton;
    SpeedButton5: TButton;
    SpeedButton7: TButton;
    SpeedButton1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    Label6: TLabel;
    NouveauBtn: TButton;
    HelpManuelBtn: TButton;
    helpMagnumBtn: TButton;
    Label4: TLabel;
    SpeedButton6: TButton;
    SpeedButton10: TButton;
    SpeedButton11: TButton;
    SpeedButton12: TButton;
    Label7: TLabel;
    Label8: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    DecibelCB: TCheckBox;
    procedure GenreModeleRGClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AjouteBtnClick(Sender: TObject);
    procedure ModeleBtnClick(Sender: TObject);
    procedure NouveauBtnClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure ModeleBtnDblClick(Sender: TObject);
  private
    Procedure MajTexte;
  public
    ModeleChoisi : TgenreModeleGr;
    EffaceModele : boolean;
    AppelMagnum : boolean;
  end;

var
    ChoixModeleGlbDlg: TChoixModeleGlbDlg;

implementation

{$R *.FMX}

procedure TChoixModeleGlbDlg.GenreModeleRGClick(Sender: TObject);
begin
      MajTexte;
      PageControlChange(sender);
end;

Procedure TChoixModeleGlbDlg.MajTexte;
begin
   with fonctionTheoriqueGlb[succ(nbreModeleGlb)] do begin
      enTete := grandeurs[indexY].nom+'('+grandeurs[indexX].nom+')';
      yedit.text := enTete+'='+expression;
      if pageControl.ActiveTab=ModManuel then begin
         yedit.setFocus;
         yedit.selStart := length(yedit.text);
         yedit.selLength := 0;
      end;
end end;

procedure TChoixModeleGlbDlg.AjouteBtnClick(Sender: TObject);
var posErreur,longErreur : integer;

Procedure SetErreur;
begin
   modalResult := mrNone;
   with fonctionTheoriqueGlb[succ(NbreModeleGlb)] do begin
        afficheErreur(codeErreurC,0);
        with yedit do begin
             setFocus;
             selStart := pred(posErreur);
             selLength := longErreur;
        end;
   end;
end;

begin
    EffaceModele := false;
    if pageControl.ActiveTab=modManuel then begin
        ModeleChoisi := mgManuel;
        posErreur := 0;
        longErreur := 0;
        codeErreurC := '';
        EffaceModele := false;
        if fonctionTheoriqueGlb[succ(NbreModeleGlb)].compileM(yedit.text,posErreur,longErreur)
           then inc(NbreModeleGlb)
           else setErreur
    end
    else inc(NbreModeleGlb);
end;

procedure TChoixModeleGlbDlg.FormActivate(Sender: TObject);
begin
     inherited;
     if NbreModeleGlb>0
        then with fonctionTheoriqueGlb[1] do begin
           if AppelMagnum
             then begin
                 AjouteBtn.Text  := '&Ajouter modèle';
                 NouveauBtn.Text  := '&Remplacer modèle';
                 NouveauBtn.visible := true;
                 AjouteBtn.Visible := NbreModeleGlb<4;
             end
             else begin
                 AjouteBtn.Text  := '&OK';
                 AjouteBtn.Visible := true;
                 NouveauBtn.Visible := false;
             end;
        end
        else begin
            AjouteBtn.Visible := false;
            NouveauBtn.Text  := '&OK';
            NouveauBtn.Visible := true;
        end;
     MajTexte;
end;

procedure TChoixModeleGlbDlg.ModeleBtnClick(Sender: TObject);
begin
     ModeleChoisi := TgenreModeleGr((sender as Tcomponent).tag)
end;

procedure TChoixModeleGlbDlg.NouveauBtnClick(Sender: TObject);
var posErreur,longErreur : integer;

Procedure SetErreur;
begin
   modalResult := mrNone;
   with fonctionTheoriqueGlb[succ(NbreModeleGlb)] do begin
        afficheErreur(codeErreurC,0);
        with yedit do begin
             setFocus;
             selStart := pred(posErreur);
             selLength := longErreur;
        end;
   end;
end;

begin
    EffaceModele := true;
    if pageControl.ActiveTab=ModManuel then begin
        ModeleChoisi := mgManuel;
        posErreur := 0;
        longErreur := 0;
        codeErreurC := '';
        if fonctionTheoriqueGlb[1].compileM(yedit.text,posErreur,longErreur)
           then NbreModeleGlb := 1
           else setErreur
    end
    else begin
       NbreModeleGlb := 1;
       if decibelCB.IsChecked  and
            (ord(ModeleChoisi)>=ord(mgPasseBas1)) and
            (ord(ModeleChoisi)<=ord(mgPasseHaut2)) then
            ModeleChoisi := TgenreModeleGr(ord(ModeleChoisi)+4);
    end;
end;

procedure TChoixModeleGlbDlg.PageControlChange(Sender: TObject);
begin
      with fonctionTheoriqueGlb[1] do
      AjouteBtn.Visible := (NbreModeleGlb>0) and
                           (NbreModeleGlb<maxIntervalles) and
          ((genreC=g_fonction) and (pageControl.activeTab=modMagnum))
end;

procedure TChoixModeleGlbDlg.ModeleBtnDblClick(Sender: TObject);
begin
     ModeleChoisi := TgenreModeleGr((sender as Tcomponent).tag);
     NouveauBtnClick(sender);
     modalResult := mrOK;
end;

end.
