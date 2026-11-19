unit choixmodele;

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
  FMX.StdCtrls,
  FMX.ExtCtrls,
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
  maths,
  modelegr,
  regutil,
  uniteKer,
  images;

type
  TChoixModeleDlg = class(TForm)
    AjouteBtn: TButton;
    CancelBtn: TButton;
    PageControl: TTabControl;
    ModManuel: TTabItem;
    DeriveeLabel: TLabel;
    yEdit: TEdit;
    ModMagnum: TTabItem;
    DroiteBtn: TButton;
    SpeedButton2: TButton;
    SpeedButton5: TButton;
    SpeedButton7: TButton;
    SpeedButton1: TButton;
    NouveauBtn: TButton;
    SpeedButton13: TButton;
    helpMagnumBtn: TButton;
    ModFiltres: TTabItem;
    DecibelCB: TCheckBox;
    SpeedButton6: TButton;
    SpeedButton10: TButton;
    PasseBandeBtn: TButton;
    SpeedButton12: TButton;
    SpeedButton14: TButton;
    SpeedButton15: TButton;
    ModSinus: TTabItem;
    SinusBtn: TButton;
    SpeedButton9: TButton;
    SpeedButton8: TButton;
    SpeedButton3: TButton;
    SpeedButton4: TButton;
    SpeedButton11: TButton;
    SpeedButton16: TButton;
    cosinusCB: TCheckBox;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    qualiterb: TRadioButton;
    GroupBox3: TGroupBox;
    equadiff1RB: TRadioButton;
    fonctionRB: TRadioButton;
    equadiff2RB: TRadioButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Image18: TImage;
    Image19: TImage;
    procedure GenreModeleRGClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AjouteBtnClick(Sender: TObject);
    procedure ModeleBtnClick(Sender: TObject);
    procedure NouveauBtnClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure ModeleBtnDblClick(Sender: TObject);
    procedure Image1Paint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure ModMagnumPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
  private
    Procedure MajTexte;
  public
    ModeleChoisi : TgenreModeleGr;
    EffaceModele : boolean;
    AppelMagnum,appelRGS : boolean;
    coordonnee : TlisteY;
  end;

var
    ChoixModeleDlg: TChoixModeleDlg;

const
    iFonction = 0;
    iEquaDiff1 = 1;
    iEquaDiff2 = 2;

implementation

{$R *.FMX}

procedure TChoixModeleDlg.GenreModeleRGClick(Sender: TObject);
begin
      MajTexte;
      PageControlChange(sender);
end;

procedure TChoixModeleDlg.Image1Paint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
    ModeleGraphique[1].ImagePaint(canvas,arect,(sender as Timage).tag);
end;

Procedure TChoixModeleDlg.MajTexte;
begin
   with fonctionTheorique[succ(nbreModele)] do begin
      deriveeLabel.visible := equadiff2RB.ischecked;
      enTete := grandeurs[indexY].nom;
      if EquaDiff2RB.isChecked then begin
                enTete:=enTete+'''''';
                indexYp := indexDerivee(grandeurs[indexY],grandeurs[0],false,true);
                deriveeLabel.Text  := stDerivee+'='+grandeurs[indexYp].nom;
      end;
      if EquaDiff1RB.isChecked then enTete:=enTete+'''';
      if FonctionRB.ischecked then enTete:=enTete+'('+grandeurs[indexX].nom+')';
      yedit.text := enTete+'='+expression;
      if pageControl.ActiveTab=ModManuel then begin
         yedit.setFocus;
         yedit.selStart := length(yedit.text);
         yedit.selLength := 0;
      end;
end end;

procedure TChoixModeleDlg.AjouteBtnClick(Sender: TObject);
var posErreur,longErreur : integer;

Procedure SetErreur;
begin
   modalResult := mrNone;
   with fonctionTheorique[succ(NbreModele)] do begin
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
    ModeleFacteurQualite := QualiteRB.ischecked;
    modeleCosinus := cosinusCB.isChecked;
    if pageControl.ActiveTab=modManuel then begin
        ModeleChoisi := mgManuel;
        posErreur := 0;
        longErreur := 0;
        codeErreurC := '';
        EffaceModele := false;
        if fonctionTheorique[succ(NbreModele)].compileM(yedit.text,posErreur,longErreur)
           then inc(NbreModele)
           else setErreur;
    end
    else begin
       inc(NbreModele);
       modeleDecibel := decibelCB.isChecked;
    end;
end;

procedure TChoixModeleDlg.FormActivate(Sender: TObject);

function Verif(Apage : TtabItem) : boolean;
var i : integer;
begin
     verif := false;
     for i := 0 to pred(Apage.ControlsCount) do
            if (Apage.Controls[i] is TButton) and
               ((Apage.Controls[i] as TButton).tag=ord(modeleChoisi))
                   then begin
                        (Apage.Controls[i] as TButton).isPressed := true;
                        verif := true;
                        break;
                    end;
end;

procedure VerifCoordonnee;
var i,nbre : integer;
begin
    for i := 1 to maxOrdonnee do with coordonnee[i] do begin
        codeY := indexNom(nomY);
        if (codeY<>grandeurInconnue) and
           (grandeurs[codeY].genreG<>variable)
           then codeY := grandeurInconnue;
        codeX := indexNom(nomX);
        if (codeX<>grandeurInconnue) and
           (grandeurs[codeX].genreG<>variable)
           then codeX := grandeurInconnue;
    end;
    nbre := 0;
    for i := 1 to maxOrdonnee do with coordonnee[i] do
        if (codeX<>grandeurInconnue) and
           (codeY<>grandeurInconnue)
           then begin
              inc(nbre);
              coordonnee[nbre] := coordonnee[i];
           end;
    for i := succ(Nbre) to maxOrdonnee do with coordonnee[i] do begin
         codeX := grandeurInconnue;
         nomX := '';
         codeY := grandeurInconnue;
         nomY := '';
    end;
    if nbre=0 then with coordonnee[1] do begin
          codeX := indexVariab[0];
          nomY := grandeurs[0].nom;
          codeY := indexVariab[1];
          nomY := grandeurs[1].nom;
//          nbre := 1;
    end; // nbre=0
end;

begin
     inherited;
     if NbreModele>0 then with fonctionTheorique[1] do begin
           fonctionRB.ischecked := genreC=g_fonction;
           equadiff1rb.ischecked := genreC=g_diff1;
           equadiff2rb.ischecked := genreC=g_diff2;
     end;
     if appelRGS then begin
           AjouteBtn.visible := false;
           NouveauBtn.Text  := '&OK';
           NouveauBtn.visible := true;
     end
     else if NbreModele>0
        then if AppelMagnum
             then begin
                 AjouteBtn.Text  := stAjouteMod;
                 NouveauBtn.Text  := stRemplaceMod;
                 NouveauBtn.visible := true;
                 AjouteBtn.visible := NbreModele<4;
             end
             else begin
                 AjouteBtn.Text  := '&OK';
                 AjouteBtn.visible := true;
                 NouveauBtn.visible := false;
             end
        else begin
            fonctionRB.ischecked := true;
            AjouteBtn.visible := false;
            NouveauBtn.Text  := '&OK';
            NouveauBtn.visible := true;
        end;
     QualiteRb.ischecked := ModeleFacteurQualite;
     cosinusCB.IsChecked  := modeleCosinus;
     decibelCB.IsChecked  := modeleDecibel;
     if appelMagnum then if verif(ModMagnum)
           then PageControl.ActiveTab := ModMagnum
           else if verif(ModSinus)
           then PageControl.ActiveTab := ModSinus
           else if verif(ModFiltres)
           then PageControl.ActiveTab := ModFiltres
           else if PageControl.ActiveTab=ModManuel
           then PageControl.ActiveTab := ModMagnum;
     VerifCoordonnee;
     MajTexte;
end;

procedure TChoixModeleDlg.ModeleBtnClick(Sender: TObject);
var i,t : integer;
    tab : TTabItem;
begin
     ModeleChoisi := TgenreModeleGr((sender as Tcomponent).tag);
     for t := 0 to pred(PageControl.TabCount) do begin
        tab := PageControl.Tabs[t];
        if tab <> ModManuel then
           for i := 0 to pred(tab.ControlsCount) do
              if tab.Controls[i] is TButton then
                 (tab.Controls[i] as TButton).IsPressed := (tab.Controls[i] = Sender);
     end;
end;

procedure TChoixModeleDlg.NouveauBtnClick(Sender: TObject);
var posErreur,longErreur : integer;

Procedure SetErreur;
begin
   modalResult := mrNone;
   with fonctionTheorique[succ(NbreModele)] do begin
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
    ModeleFacteurQualite := QualiteRb.isChecked;
    modeleCosinus := cosinusCB.isChecked;
    if pageControl.ActiveTab=ModManuel
       then begin
          ModeleChoisi := mgManuel;
          posErreur := 0;
          longErreur := 0;
          fonctionTheorique[1].indexY := fonctionTheorique[succ(NbreModele)].indexY;
          fonctionTheorique[1].indexX := fonctionTheorique[succ(NbreModele)].indexX;           
          if fonctionTheorique[1].compileM(yedit.text,posErreur,longErreur)
             then NbreModele := 1
             else setErreur
      end
      else begin
         NbreModele := 1;
         modeleDecibel := decibelCB.isChecked;
      end;
end;

procedure TChoixModeleDlg.PageControlChange(Sender: TObject);
var i : integer;
    trouve : boolean;
begin
      with fonctionTheorique[1] do
      AjouteBtn.visible := (NbreModele>0) and
                           (NbreModele<maxIntervalles) and
          ((genreC=g_fonction) and
           ((pageControl.activeTab<>modManuel) or (fonctionrb.ischecked)) or
           ((genreC=g_diff1) and
            (pageControl.activeTab=modManuel) and
            (equadiff1rb.ischecked)) or
           ((genreC=g_diff2) and
            (pageControl.activeTab=modManuel) and
            (equadiff2rb.ischecked)));
     if pageControl.ActiveTab<>ModManuel then begin
        trouve := false;
        for i := 0 to pred(pageControl.ActiveTab.ControlsCount) do
            if (pageControl.ActiveTab.Controls[i] is TButton) and
               ((pageControl.ActiveTab.Controls[i] as TButton).tag=ord(modeleChoisi))
                   then begin
                        (pageControl.ActiveTab.Controls[i] as TButton).isPressed := true;
                        trouve := true;
                        break;
                    end;
         if not trouve then
            for i := 0 to pred(pageControl.ActiveTab.ControlsCount) do
            if (pageControl.ActiveTab.Controls[i] is TButton) and
               (pageControl.ActiveTab.Controls[i] as TButton).isPressed
                   then begin
                        ModeleChoisi := TgenreModeleGr((pageControl.ActiveTab.Controls[i] as TButton).tag);
                        break;
                    end;
     end;
end;

procedure TChoixModeleDlg.ModeleBtnDblClick(Sender: TObject);
begin
     ModeleChoisi := TgenreModeleGr((sender as Tcomponent).tag);
     NouveauBtnClick(sender);
     modalResult := mrOK;
end;

procedure TChoixModeleDlg.ModMagnumPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  I,J: Integer;
  Abutton : TButton;
begin
    exit;
    for I := 0 to (sender as TTabItem).controlsCount-1 do
        if (sender as TTabItem).Controls[i] is TButton then begin
            Abutton := (sender as TTabItem).Controls[i] as Tbutton;
            for J := 0 to Abutton.controlsCount-1 do
                if Abutton.Controls[i] is TImage then

        end;
end;

end.
