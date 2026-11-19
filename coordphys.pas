unit coordphys;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Colors,
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
  FMX.Graphics,
  FMX.Spinbox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  aidekey,
  compile,
  Constreg,
  graphker,
  regutil,
  selpage,
  uniteKer,
  maths,
  images, 
  
  FMX.TMSFNCTypes,
  FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomPicker,
  FMX.TMSFNCColorPicker;

type
TFcoordonneesPhys = class(TForm)
    Panel1: TPanel;
    GroupBoxOptions: TGroupBox;
    OrthonormeCB: TCheckBox;
    MemeZeroCB: TCheckBox;
    MemeXCB: TCheckBox;
    AnalyseurCB: TCheckBox;
    MemeEchelleCB: TCheckBox;
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    PolaireCB: TCheckBox;
    Panel3: TPanel;
    AbscisseGB: TGroupBox;
    LabelGradX: TLabel;
    ListeX: TComboBox;
    ZeroXCB: TCheckBox;
    GraduationX: TComboBox;
    OrdonneeGB: TGroupBox;
    labelZeroY: TLabel;
    LabelAxeY: TLabel;
    LabelGradY: TLabel;
    ListeY: TComboBox;
    ZeroYCB: TCheckBox;
    MondeCB: TComboBox;
    GraduationY: TComboBox;
    OptionsGB: TGroupBox;
    LigneCB: TCheckBox;
    PointCB: TCheckBox;
    AddBtn: TButton;
    DeleteBtn: TButton;
    GraduationZeroCB: TCheckBox;
    OrdreLissageSE: TSpinBox;
    GrilleCB: TCheckBox;
    DimPointSE: TSpinBox;
    LigneRG: TComboBox;
    PasPointSE: TSpinBox;
    PointCombo: TComboBox;
    LigneCombo: TComboBox;
    MinidBEdit: TSpinBox;
    LabelDimPoint: TLabel;
    Label5: TLabel;
    pagesGB: TGroupBox;
    PagesBtn: TButton;
    LabelWidth: TLabel;
    WidthEcranSE: TSpinBox;
    SuperPagesCB: TCheckBox;
    PagePrecBtn: TButton;
    CommentaireEdit: TEdit;
    PageSuivBtn: TButton;
    FinModeleBtn: TButton;
    ReperePageGB: TGroupBox;
    TraitRB: TRadioButton;
    MotifRB: TRadioButton;
    CouleurRB: TRadioButton;
    VariableLB: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    TabItem5: TTabItem;
    TabItem6: TTabItem;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ModeleItem: TListBoxItem;
    SplineItem: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    ListBoxItem13: TListBoxItem;
    ListBoxItem14: TListBoxItem;
    ListBoxItem15: TListBoxItem;
    ListBoxItem16: TListBoxItem;
    ListBoxItem17: TListBoxItem;
    ListBoxItem18: TListBoxItem;
    ListBoxItem19: TListBoxItem;
    ListBoxItem20: TListBoxItem;
    ListBoxItem21: TListBoxItem;
    ListBoxItem22: TListBoxItem;
    ListBoxItem23: TListBoxItem;
    ListBoxItem24: TListBoxItem;
    ListBoxItem25: TListBoxItem;
    ListBoxItem26: TListBoxItem;
    GroupBox1: TGroupBox;
    VitesseCB: TCheckBox;
    AccelerationCB: TCheckBox;
    OptionsVitesseBtn: TButton;
    LabelVitesse: TLabel;
    Shannon: TListBoxItem;
    CouleurCombo: TTMSFNCColorPicker;
    procedure MemeXCBClick(Sender: TObject);
    procedure PolaireCBClick(Sender: TObject);
    procedure PagesBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListeXChange(Sender: TObject);
    procedure ListeYChange(Sender: TObject);
    procedure GraduationXChange(Sender: TObject);
    procedure GraduationYChange(Sender: TObject);
    procedure MondeCBChange(Sender: TObject);
    procedure CouleurComboChange(Sender: TObject);
    procedure PointComboChange(Sender: TObject);
    procedure OptionsVitesseBtnClick(Sender: TObject);
    procedure ZoomAutoBtnClick(Sender: TObject);
    procedure LigneComboChange(Sender: TObject);
    procedure MinidBEditChange(Sender: TObject);
    procedure PagePrecBtnClick(Sender: TObject);
    procedure PageSuivBtnClick(Sender: TObject);
    procedure FinModeleBtnClick(Sender: TObject);
    procedure PointCBChange(Sender: TObject);
    procedure LigneCBChange(Sender: TObject);
    procedure VitesseCBChange(Sender: TObject);
    procedure AccelerationCBChange(Sender: TObject);
    procedure SuperPagesCBChange(Sender: TObject);
    procedure AnalyseurCBChange(Sender: TObject);
    procedure OrthonormeCBChange(Sender: TObject);
    procedure MemeEchelleCBChange(Sender: TObject);
    procedure ZeroXCBChange(Sender: TObject);
    procedure ZeroYCBChange(Sender: TObject);
    procedure VariableLBChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CouleurComboColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure LigneRGChange(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    ListeVar : TstrListe;
    CourbeCourante : indiceOrdonnee;
    activation : boolean;
    pageActive : integer;
    Procedure Maj;
    Procedure majOptions;
    Procedure setNom;
    Procedure MajPages;
  public
     Transfert : TtransfertGraphe;
     modeleEnCours,modelePermis : boolean;
     Agraphe : TgrapheReg;
  end;

var
  FcoordonneesPhys: TFcoordonneesPhys;

implementation

uses Valeurs, optionsVitesse, options, AideU;

{$R *.FMX}

const
   hMotif : array[boolean] of string = ('Motif du point','Ellipse d''incertitude');

procedure TFcoordonneesPhys.MemeXCBClick(Sender: TObject);
var courbe : integer;
begin
     if MemeXCB.IsChecked  then
        for courbe := 2 to maxOrdonnee do with transfert do begin
            nomX[courbe] := nomX[1];
            VariableLB.tabs[courbe-1].text := nomY[courbe]+'=f('+nomX[1]+')';
        end;
end;

procedure TFcoordonneesPhys.MemeEchelleCBChange(Sender: TObject);
begin
     if MemeEchelleCB.isChecked
        then include(Transfert.OptionGr,OgMemeEchelle)
        else exclude(Transfert.OptionGr,OgMemeEchelle);
end;

procedure TFcoordonneesPhys.OrthonormeCBChange(Sender: TObject);
begin
    if OrthonormeCB.isChecked
         then include(Transfert.OptionGr,OgOrthonorme)
         else exclude(Transfert.OptionGr,OgOrthonorme);
end;

procedure TFcoordonneesPhys.AnalyseurCBChange(Sender: TObject);
begin
  Maj
end;

procedure TFcoordonneesPhys.PolaireCBClick(Sender: TObject);
begin
with Transfert do if PolaireCB.isChecked
        then begin
             include(OptionGr,OgPolaire);
             OrthonormeCB.IsChecked  := true;
             OrthonormeCB.enabled := false;
             MemeZeroCB.visible := false;
             labelAxeY.visible := false;
             labelGradX.visible := false;
             labelGradY.visible := false;
             labelZeroY.visible := false;
             GraduationX.visible := false;
             AnalyseurCB.visible := false;
             AnalyseurCB.IsChecked  := false;
        end
        else begin
             exclude(OptionGr,OgPolaire);
             OrthonormeCB.enabled := true;
             MemeZeroCB.visible := true;
             labelAxeY.visible := true;
             labelGradX.visible := true;
             labelGradY.visible := true;
             labelZeroY.visible := true;
             GraduationX.visible := true;
             AnalyseurCB.visible := true;
        end;
     if sender<>nil then Maj;
end;

procedure TFcoordonneesPhys.SuperPagesCBChange(Sender: TObject);
begin
     majPages;
end;

procedure TFcoordonneesPhys.PagesBtnClick(Sender: TObject);
begin
     selectPageDlg := TselectPageDlg.Create(self);
     SelectPageDlg.caption := 'Choix des pages affichées sur le graphe';
     SelectPageDlg.appelPrint := false;
     CentreForm(SelectPageDlg);
     SelectPageDlg.showModal;
     selectPageDlg.Free;
end;

procedure TFcoordonneesPhys.PageSuivBtnClick(Sender: TObject);
begin
  if pageActive<NbrePages
     then inc(PageActive)
     else pageActive := 1;
  MajPages;
end;

procedure TFcoordonneesPhys.OKBtnClick(Sender: TObject);

procedure verifVitesse(c : integer);
var indexX,indexY,indexVX,indexVY,indexAx,indexAy : integer;
    recalcul : boolean;
    suffixe : string;
    nomVX,nomVY : string;

Procedure CalcVitesse;
var k : integer;

Function AddVitesse(y,x : tgrandeur) : string;
begin
    inc(k);
    Fvaleurs.memo.lines.add('v'+y.nom+'=Diff('+y.nom+','+x.nom+')');
    recalcul := true;
    result := 'v'+y.nom;
end;

begin with transfert do begin
      k := 1;
      suffixe := grandeurs[indexX].nom;
      delete(suffixe,1,1);
      if indexVX=GrandeurInconnue
         then nomVX := AddVitesse(grandeurs[indexX],grandeurs[0])
         else nomVX := grandeurs[indexVX].nom;
      if indexVY=GrandeurInconnue
         then nomVY := AddVitesse(grandeurs[indexY],grandeurs[0])
         else nomVY := grandeurs[indexVY].nom;
      if k=3 then Fvaleurs.memo.lines.add('v'+suffixe+'=sqrt('+
            nomVX+'^2+'+nomVY+'^2)');
end end;

Procedure CalcAcceleration;
var k : integer;
    nomAX,nomAY : string;

Function AddAcceleration(y,v,t : string) : string;
begin
    inc(k);
    Fvaleurs.memo.lines.add('a'+y+'=Diff('+v+','+t+')');
    recalcul := true;
    result := 'a'+y;
end;

begin with transfert do begin
           k := 1;
           suffixe := grandeurs[indexX].nom;
           delete(suffixe,1,1);
           if indexaX=GrandeurInconnue
                 then nomAX := AddAcceleration(grandeurs[indexX].nom,
                                               nomVX,
                                               grandeurs[0].nom)
                 else nomAX := grandeurs[indexaX].nom;
           if indexaY=GrandeurInconnue
                 then nomAY := AddAcceleration(grandeurs[indexY].nom,
                                               nomVY,
                                               grandeurs[0].nom)
                 else nomAY := grandeurs[indexaY].nom;
           if k=3 then Fvaleurs.memo.lines.add('a'+suffixe+'=sqrt('+
                 nomAX+'^2+'+nomAY+'^2)');
end end;

begin with transfert do begin
      indexX := indexNom(nomX[c]);
      if indexX=grandeurInconnue then exit;
      indexY := indexNom(nomY[c]);
      if indexY=grandeurInconnue then exit;
      recalcul := false;
      if (trVitesse in trace[c]) or (trAcceleration in trace[c]) then begin
          indexVX := IndexVitesse(grandeurs[indexX].nom);
          indexVY := IndexVitesse(grandeurs[indexY].nom);
          if (indexVX=grandeurInconnue) or
             (indexVY=grandeurInconnue) then calcVitesse;
      end;
      if (trAcceleration in trace[c]) then begin
           indexAX := IndexAcceleration(grandeurs[indexX].nom);
           indexAY := IndexAcceleration(grandeurs[indexY].nom);
           if (indexAX=grandeurInconnue) or
              (indexAY=grandeurInconnue) then calcAcceleration;
      end;
      if recalcul then Fvaleurs.recalculer;
      if (trVitesse in trace[c]) or (trAcceleration in trace[c]) then
         if pages[pageCourante].nmes>256
              then include(trace[c],trLigne) // sinon illisible
              else include(trace[c],trPoint); // points entrés à la main
end end; // verifVitesse

var i,mondeLoc : integer;
begin with transfert do begin
     if  MemeZeroCB.visible then if MemeZeroCB.isChecked
        then include(OptionGr,OgMemeZero)
        else exclude(OptionGr,OgMemeZero);
     if GrilleCB.isChecked
        then include(OptionGr,OgQuadrillage)
        else exclude(OptionGr,OgQuadrillage);
     OrdreLissage := round(OrdreLissageSE.Value);
     penWidthEcran := widthEcranSE.value;
     DimPointVGA := round(DimPointSE.value);
     if not OrthonormeCB.visible then exclude(optionGr,OgOrthonorme);
     if pasPointSE.visible
        then pasPoint := round(PasPointSE.value)
        else pasPoint := 1;
     if couleurRB.ischecked then reperePage := spcouleur;
     if motifRB.ischecked then reperePage := spmotif;
     if traitRB.ischecked then reperePage := spstyle;
     superPage := SuperPagesCB.isChecked;
     if GraduationZeroCB.isChecked
        then include(optionGr,OgZeroGradue)
        else exclude(optionGr,OgZeroGradue);
     if AnalyseurCB.isChecked
         then include(OptionGr,OgAnalyseurLogique)
         else exclude(OptionGr,OgAnalyseurLogique);
     for i := 1 to maxOrdonnee do verifVitesse(i);
     if OgAnalyseurLogique in OptionGr
        then begin
           if not SuperPagesCB.IsChecked  then
              for i := 1 to maxOrdonnee do
                  iMonde[i] := mondeY+i-1;
           exclude(optionGr,OgMemeZero);
        end
        else begin
           mondeLoc := mondeSans;
           if (NbreCourbes=1) and
              (iMonde[1]=mondeDroit) then iMonde[1] := mondeY;
           for i := 1 to maxOrdonnee do
               if iMonde[i]=mondeSans then begin
                  iMonde[i] := mondeLoc;
                  inc(MondeLoc);
               end;
        end;
end;
Transfert.AssignSortie;
end;

procedure TFcoordonneesPhys.Maj;
var m : indiceMonde;
    modifiable,NonAnalyseur : boolean;
    code : integer;
    i : integer;
begin
     courbeCourante := succ(variableLB.tabIndex);
     if activation then exit;
     MajOptions;
with transfert do begin
     NonAnalyseur := not(AnalyseurCB.IsChecked);
     if AnalyseurCB.IsChecked  then begin
          memeXCB.IsChecked  := true;
          polaireCB.IsChecked  := false;
     end;
     labelAxeY.visible := NonAnalyseur;
     memeZeroCB.visible := NonAnalyseur;
     memeEchelleCB.visible := not NonAnalyseur;
     memeXCB.visible := NonAnalyseur;
     polaireCB.visible := NonAnalyseur;
     GraduationX.itemIndex := ord(grad[mondeX]);
     zeroXCB.IsChecked  := zero[mondeX];
     zeroXCB.visible := not(PolaireCB.IsChecked) and (grad[mondeX]<>gLog);
     OrthonormeCB.enabled := true;
     if (grad[mondeX]<>gLin) then begin
          OrthonormeCB.enabled := false;
          OrthonormeCB.IsChecked  := false;
     end;
     m := iMonde[courbeCourante];
     if m>mondeSans then m := mondeSans;
     modifiable := not(PolaireCB.IsChecked) and
                      (nomY[courbeCourante]<>'');
     mondeCB.itemIndex := m-mondeY;
     minidbEdit.Visible := grad[m]=gdB;
     minidbEdit.value := round(minidb[m]);
     mondeCB.visible := NonAnalyseur;
     zeroYCB.IsChecked  := zero[m];
     zeroYCB.visible := modifiable and not(PolaireCB.IsChecked) and (grad[m]<>gLog);
     graduationY.itemIndex := ord(grad[m]);
     graduationY.visible := modifiable;
     mondeCB.visible := modifiable;
     if (nomY[courbeCourante]<>'') and (grad[m]<>gLin) then begin
           OrthonormeCB.enabled := false;
           OrthonormeCB.IsChecked  := false;
     end;
     nbreCourbes := 0;
     for i := 1 to maxOrdonnee do begin
         if (nomx[i]<>'') and (nomY[i]<>'')
          then begin
               variableLB.Tabs[i-1].visible := true;
               inc(NbreCourbes);
          end
          else variableLB.Tabs[i-1].visible := false;
     end;
     AddBtn.visible := nbreCourbes<MaxOrdonnee;
     DeleteBtn.visible := nbreCourbes>1;
     code := ListeVar.MyIndexOf(nomY[courbeCourante]);
     listeY.itemIndex := code;
     code := listeVar.MyIndexOf(nomX[courbeCourante]);
     listeX.itemIndex := code;
     LigneRG.Visible := LigneCB.isChecked;
     LigneRG.itemIndex := ord(Ligne[CourbeCourante]);
     if (LigneRG.itemIndex=1) and not ModelePermis then LigneRG.itemIndex := 0;
     ModeleItem.Enabled := ModelePermis;
     if (LigneRG.itemIndex=2) and (pages[pageCourante].nmes>maxVecteurDefaut) then LigneRG.itemIndex := 0;
     splineItem.Enabled := pages[pageCourante].nmes>maxVecteurDefaut;
     finModeleBtn.visible := modeleEnCours;
     if modeleEnCours then begin
          ligneCB.IsChecked := true;
          ligneRG.ItemIndex := 1;
          PointCB.IsChecked := true;
     end;
     PointCB.enabled := not(LigneCB.IsChecked) or (LigneRG.itemIndex<>1);
     ligneCB.Enabled := not modeleEnCours;
     ligneRG.Enabled := not modeleEnCours;
     OrdreLissageSE.visible := LigneRG.Visible and (LigneRG.itemIndex=2);
     SetNom;
     if PolaireCB.isChecked
        then begin
             AbscisseGB.Text  := stAngle;
             OrdonneeGB.Text  := stRayon;
        end
        else begin
             AbscisseGB.Text  := stAbscisse;
             OrdonneeGB.Text  := stOrdonnee;
        end;
     LigneCombo.itemIndex := ord(style[courbeCourante]);
     CouleurCombo.selectedColor := Couleur[CourbeCourante];
     if traceEllipse then motif[courbeCourante] := mIncert;
     PointCombo.itemIndex := ord(motif[courbeCourante]);
end end; // MaJ

procedure TFcoordonneesPhys.FinModeleBtnClick(Sender: TObject);
begin
     finModeleBtn.visible := false;
     modeleEnCours := false;
     modelePermis := false;
     ligneCB.Enabled := true;
     ligneRG.Enabled := true;
end;

procedure TFcoordonneesPhys.MajOptions;
var indexX,indexY : integer;
begin with transfert do begin
      indexX := indexNom(nomX[CourbeCourante]);
      if indexX=grandeurInconnue then begin
         indexX := 1;
         nomX[CourbeCourante] := getNomCoord(listeVar[indexX]);
      end;
      indexY := indexNom(nomY[CourbeCourante]);
      if indexY=grandeurInconnue then begin
         indexY := 2;
         nomY[CourbeCourante] := getNomCoord(listeVar[indexY]);
      end;
      OptionsGB.Text  := 'Options de représentation de '+
         nomY[CourbeCourante]+'('+
         nomX[CourbeCourante]+')';
      LigneRG.itemIndex := ord(transfert.ligne[courbeCourante]);
      LigneCB.IsChecked  := trLigne in trace[CourbeCourante];
      LigneRG.Visible := LigneCB.isChecked;
      PointCB.IsChecked  := trPoint in trace[CourbeCourante];
      VitesseCB.enabled := (indexX<>0) and (indexY<>0) and
                           (grandeurs[indexX].genreG=variable) and
                           (grandeurs[indexY].genreG=variable);
      labelVitesse.Visible := not VitesseCB.enabled;
      VitesseCB.IsChecked  := (trVitesse in trace[CourbeCourante]) and
                            VitesseCB.enabled;
      if not VitesseCB.IsChecked  then
         exclude(trace[courbeCourante],trVitesse);
      AccelerationCB.enabled := VitesseCB.enabled;
      AccelerationCB.IsChecked := (trAcceleration in trace[CourbeCourante]) and
                                 AccelerationCB.enabled;
      if not AccelerationCB.IsChecked  then
           exclude(trace[courbeCourante],trAcceleration);
      if VitesseCB.IsChecked  or AccelerationCB.IsChecked  then
      if trace[CourbeCourante]=[] then begin
         if pages[pageCourante].nmes>256
              then trace[CourbeCourante] := [trLigne] // sinon illisible
              else trace[CourbeCourante] := [trPoint]; // points entrés à la main
         PointCB.IsChecked  := trPoint in trace[CourbeCourante];
         LigneCB.IsChecked  := trLigne in trace[CourbeCourante];
      end;
      OrthonormeCB.Visible := grandeurs[indexX].nomUnite=grandeurs[indexY].nomUnite;
end end; // MajOptions

procedure TFcoordonneesPhys.AddBtnClick(Sender: TObject);
var code : integer;
    i,k,c : integer;
    Yok : boolean;
    nomC : string;
    grandeurRef : Tgrandeur;
    mondeYInterdit,mondeDroitInterdit : boolean;
begin with transfert do begin
     i := 0;
     while VariableLB.Tabs[i].visible do inc(i);
     CourbeCourante := i+1;
     nomX[courbeCourante] := nomX[1];
     k := 1;
     for i := 0 to pred(ListeVar.count) do begin
         nomC := ListeVar[i];
         code := indexNom(nomC);
         Yok := (code<>grandeurInconnue) and
                (grandeurs[code].genreG=variable);
         for c := 1 to pred(courbeCourante) do
             if (nomC=nomY[c]) or
                (nomC=nomX[c])  then
                 begin Yok := false;break end;
         if Yok then begin k := i;break end;
     end;
     nomY[courbeCourante] := getNomCoord(listeVar[k]);
     if pos(RepereConst,nomY[courbeCourante])>0 then
           system.delete(nomY[courbeCourante],1,length(RepereConst));
     code := indexNom(nomY[courbeCourante]);
     grandeurRef := grandeurs[code];
     iMonde[courbeCourante] := mondeX;
     mondeYInterdit := false;
     mondeDroitInterdit := false;
     for i := 1 to pred(courbeCourante) do begin
         code := indexNom(nomY[i]);
         if code<>grandeurInconnue then
            if grandeurs[code].uniteEgale(grandeurRef)
                then begin
                   iMonde[courbeCourante] := iMonde[i];
                   break;
                end
                else begin
                   if iMonde[i]=mondeY then mondeYinterdit := true;
                   if iMonde[i]=mondeDroit then mondeDroitinterdit := true;
                end;
     end;  // for i
     if iMonde[courbeCourante]=mondeX then
        if mondeYInterdit
           then if mondeDroitInterdit
                then iMonde[courbeCourante] := mondeSans
                else iMonde[courbeCourante] := mondeDroit
           else iMonde[courbeCourante] := mondeY;
     inc(nbreCourbes);
     Maj;
end end;

procedure TFcoordonneesPhys.DeleteBtnClick(Sender: TObject);
var i : indiceOrdonnee;
begin with transfert do  begin
     i := succ(variableLB.tabIndex);
     nomY[i] := '';
     nomX[i] := '';
     iMonde[i] := mondeY;
     trace[i] := [];
     dec(nbreCourbes);
     VariableLB.tabIndex := 0;
     Maj;
end end;

Procedure TFcoordonneesPhys.setNom;
var i : indiceOrdonnee;
begin
    with transfert do
        for i := 1 to variableLB.tabCount do
            VariableLB.tabs[i-1].text := nomY[i]+'=f('+nomX[i]+')';
end;

procedure TFcoordonneesPhys.LigneCBChange(Sender: TObject);
begin
      if LigneCB.isChecked
         then include(transfert.trace[courbeCourante],trLigne)
         else exclude(transfert.trace[courbeCourante],trLigne);
      LigneRG.Visible := LigneCB.isChecked;
      if LigneCB.IsChecked  and (LigneRG.itemIndex<>0) then PointCB.IsChecked  := true;
      PointCB.enabled := not(LigneCB.IsChecked) or (LigneRG.itemIndex<>1);
end;

procedure TFcoordonneesPhys.PointCBChange(Sender: TObject);
begin
if PointCB.isChecked
        then include(transfert.trace[courbeCourante],trPoint)
        else exclude(transfert.trace[courbeCourante],trPoint);
     PointCombo.visible := PointCB.isChecked;
     DimPointSE.Visible := PointCB.IsChecked  and not traceEllipse;
     LabelDimPoint.visible := DimPointSE.visible;
     PasPointSE.visible := PointCB.IsChecked;
end;

procedure TFcoordonneesPhys.VitesseCBChange(Sender: TObject);
begin
      if vitesseCB.isChecked
         then include(transfert.trace[courbeCourante],trVitesse)
         else exclude(transfert.trace[courbeCourante],trVitesse)
end;

procedure TFcoordonneesPhys.AccelerationCBChange(Sender: TObject);
begin
      if AccelerationCB.isChecked
         then include(transfert.trace[courbeCourante],trAcceleration)
         else exclude(transfert.trace[courbeCourante],trAcceleration)
end;

procedure TFcoordonneesPhys.FormCreate(Sender: TObject);
begin
    ListeVar := TstrListe.create;
    Transfert := TtransfertGraphe.Create;
end;

procedure TFcoordonneesPhys.FormDestroy(Sender: TObject);
begin
     ListeVar.free;
     Transfert.free;
     inherited
end;

procedure TFcoordonneesPhys.FormShow(Sender: TObject);
var i : integer;
    cx,cy : integer;
    memeX : boolean;
begin
Transfert.agraphe := aGraphe;
Transfert.AssignEntree;
with transfert do begin
    activation := true;
    pageActive := pageCourante;
    traitRB.ischecked := reperepage=spstyle;
    motifRB.ischecked := reperepage=spmotif;
    couleurRB.ischecked := reperepage=spcouleur;
    widthEcranSE.value := penWidthEcran;
    DimPointSE.Value := DimPointVGA;
    PasPointSE.Value := PasPoint;
    ListeVar.Clear;
    for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
          if genreG=variable then ListeVar.add(nom);
    if (NbreConstGlb+NbreConst)>0 then ListeVar.add(SeparateurConst);
    for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
          if genreG=constante then ListeVar.add(RepereConst+nom);
    for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
          if genreG=constanteGlb then ListeVar.add(RepereConst+nom);
    ListeX.items := listeVar;
    ListeY.items := listeVar;
    memeX := true;
    for i := 0 to pred(variableLB.tabCount) do
        variableLB.Tabs[i].visible := false;
    for i := 1 to maxOrdonnee do begin
        cY := ListeVar.MyIndexOf(nomY[i]);
        cX := listeVar.MyIndexOf(nomX[i]);
        if cX<0 then if i=1
           then begin
              nomX[1] := getNomCoord(listeVar[0]);
              cX := 0;
           end
           else nomX[i] := '';
        if cY<0 then if i=1
           then begin
               nomY[1] := getNomCoord(listeVar[1]);
               cY := 1;
           end
           else nomY[i] := '';
        memeX := memeX and ((nomX[i]=nomX[1]) or (nomX[i]=''));
        if (cY>=0) and (cX<0) and memeX then begin
           nomX[i] := nomX[1];
           cX := 0;
        end;
        if (cX>=0) and (cY>=0) then
            variableLB.Tabs[i-1].visible := true;
    end;
    VariableLB.tabIndex := 0;
    GrilleCB.IsChecked  := OgQuadrillage in optionGr;
    OrdreLissageSE.Value := OrdreLissage;
    PagesBtn.visible := (NbrePages>1) and SuperPage;
    ReperePageGB.visible := (NbrePages>1) and SuperPage;
    MemeZeroCB.IsChecked  := OgMemeZero in OptionGr;
    MemeEchelleCB.IsChecked  := OgMemeEchelle in OptionGr;
    AnalyseurCB.IsChecked  := OgAnalyseurLogique in OptionGr;
    PolaireCB.IsChecked  := OgPolaire in OptionGr;
    OrthonormeCB.IsChecked  := OgOrthonorme in OptionGr;
    PolaireCBclick(nil);
    memeXCB.IsChecked  := memeX;
    memeXCBClick(nil);
    SuperPagesCB.visible := (NbrePages>1);
    SuperPagesCB.IsChecked  := (NbrePages>1) and superPage;
    courbeCourante := 1;
    variableLB.tabIndex := 0;
    activation := false;
    GraduationZeroCB.IsChecked  := OgZeroGradue in optionGr;
    superPagesCB.visible := (nbrePages>0);
    superPagesCB.IsChecked  :=  superPagesCB.visible and superPage;
    pagesGB.visible := superPagesCB.isChecked;
    Maj;
    SetNom;
end end;

procedure TFcoordonneesPhys.ListeXChange(Sender: TObject);
var i : integer;
begin
      if activation then exit;
      if listeX.items[listeX.itemIndex]=SeparateurConst then
         listeX.ItemIndex := pred(listeX.ItemIndex);
      if memeXCB.IsChecked  then
         for i := 1 to transfert.NbreCourbes do
             transfert.nomX[i] := getNomCoord(listeX.items[listeX.itemIndex])
         else transfert.nomX[courbeCourante] := getNomCoord(listeX.items[listeX.itemIndex]);
      MajOptions;
      setNom;
end;

procedure TFcoordonneesPhys.ListeYChange(Sender: TObject);
var i,code,codeR : integer;
begin
if activation then exit;
with transfert do begin
      if listeY.items[listeY.itemIndex]=SeparateurConst then
         listeY.ItemIndex := pred(listeY.ItemIndex);
      nomY[courbeCourante] := getNomCoord(listeY.items[listeY.itemIndex]);
      codeR := indexNom(nomY[courbeCourante]);
      for i := 1 to nbreCourbes do
         if (i<>courbeCourante) then begin
         code := indexNom(nomY[i]);
         if (code<>grandeurInconnue) and
            (grandeurs[code].uniteEgale(grandeurs[codeR]))
                then begin
                   iMonde[courbeCourante] := iMonde[i];
                   mondeCB.itemIndex := iMonde[courbeCourante]-mondeY;
                   break;
                end
     end; // for i
     MajOptions;
     setNom;
end end;

procedure TFcoordonneesPhys.GraduationXChange(Sender: TObject);
begin
     transfert.grad[mondeX] := Tgraduation(GraduationX.itemIndex);
     OrthonormeCB.enabled := (transfert.grad[mondeX]=gLin) and
                             (OgPolaire in transfert.OptionGr);
     zeroXCB.visible := not(PolaireCB.IsChecked) and
                        (transfert.grad[mondeX]=gLin);
     ZoomAutoBtnClick(sender);
     transfert.useDefautX := false;                      
end;

procedure TFcoordonneesPhys.GraduationYChange(Sender: TObject);
var m : indiceMonde;
begin
     m := transfert.iMonde[courbeCourante];
     if m>mondeSans then m := mondeSans;
     transfert.grad[m] := Tgraduation(GraduationY.itemIndex);
     OrthonormeCB.enabled := (transfert.grad[m]=gLin) and
                  (OgPolaire in transfert.OptionGr);
     zeroYCB.visible := not(PolaireCB.IsChecked) and
                           (transfert.grad[m]=gLin);
     minidBEdit.Visible := transfert.grad[m]=gdB;
     minidBEdit.value := round(transfert.minidb[m]);
     ZoomAutoBtnClick(sender);
end;

procedure TFcoordonneesPhys.MondeCBChange(Sender: TObject);
var m : indiceMonde;
begin
     m := mondeY+mondeCB.itemIndex;
     transfert.iMonde[courbeCourante] := m;
     transfert.grad[m] := Tgraduation(GraduationY.itemIndex);
end;

procedure TFcoordonneesPhys.VariableLBChange(Sender: TObject);
begin
    Maj
end;

procedure TFcoordonneesPhys.CouleurComboChange(Sender: TObject);
begin
     if pagesGB.visible and (couleurRB.ischecked)
        then couleurPages[PageActive] := CouleurCombo.selectedColor
        else begin
            couleurInit[CourbeCourante] := CouleurCombo.selectedColor;
            Transfert.couleur[CourbeCourante] := CouleurCombo.selectedColor;
       end;
     setNom;
end;

procedure TFcoordonneesPhys.CouleurComboColorSelected(Sender: TObject;
  AColor: TAlphaColor);
begin
     if pagesGB.visible and (couleurRB.ischecked)
        then couleurPages[PageActive] := CouleurCombo.selectedColor
        else begin
            couleurInit[CourbeCourante] := CouleurCombo.selectedColor;
            Transfert.couleur[CourbeCourante] := CouleurCombo.selectedColor;
        end;
     setNom;
end;

procedure TFcoordonneesPhys.PointComboChange(Sender: TObject);
begin
if pagesGB.visible and (motifRB.isChecked)
     then motifPages[pageActive] := Tmotif(PointCombo.itemIndex)
     else begin
        motifInit[CourbeCourante] := Tmotif(PointCombo.itemIndex);
        Transfert.Motif[CourbeCourante] := Tmotif(PointCombo.itemIndex);
     end;
     if Transfert.Motif[CourbeCourante]=mIncert then begin
         traceEllipse := true;
//         PointCombo.hint := hMotif[true];
     end;    
end;

procedure TFcoordonneesPhys.ZeroXCBChange(Sender: TObject);
begin
    Transfert.zero[mondeX] := zeroXCB.isChecked;
    Maj;
end;

procedure TFcoordonneesPhys.ZeroYCBChange(Sender: TObject);
var m : indiceMonde;
begin
     m := transfert.iMonde[courbeCourante];
     Transfert.zero[m] := zeroYCB.isChecked;
     Maj;
end;

procedure TFcoordonneesPhys.LigneRGChange(Sender: TObject);
begin
    PointCB.enabled := not(LigneCB.IsChecked) or (LigneRG.itemIndex<>1);
    if LigneCB.IsChecked  and (LigneRG.itemIndex<>0) then PointCB.IsChecked  := true;
    transfert.ligne[courbeCourante] := Tligne(LigneRG.itemIndex);
    OrdreLissageSE.visible := LigneRG.itemIndex=2;
end;


procedure TFcoordonneesPhys.PagePrecBtnClick(Sender: TObject);
begin
    if pageActive>1
       then dec(pageActive)
       else pageActive := NbrePages;
    MajPages;
end;

procedure TFcoordonneesPhys.OptionsVitesseBtnClick(Sender: TObject);
var code : integer;
begin
     OptionsVitesseDlg := TOptionsVitesseDlg.create(self);
     code := indexNom(listeX.items[listeX.itemIndex]);
     OptionsVitesseDlg.grandeurX := grandeurs[code];
     code := indexNom(listeY.items[listeY.itemIndex]);
     OptionsVitesseDlg.grandeurY := grandeurs[code];
     CentreForm(OptionsVitesseDlg);
     if OptionsVitesseDlg.showModal=mrOK then majOptions;
     OptionsVitesseDlg.free;
end;

procedure TFcoordonneesPhys.ZoomAutoBtnClick(Sender: TObject);
begin
     Transfert.useDefaut := false;
     Transfert.autoTick := true;
end;

procedure TFcoordonneesPhys.LigneComboChange(Sender: TObject);
begin
 if pagesGB.visible and (traitRB.ischecked)
     then PstylePages[PageActive] := TStrokeDash(LigneCombo.itemIndex)
     else begin
        PstyleInit[CourbeCourante] := TStrokeDash(LigneCombo.itemIndex);
        Transfert.style[CourbeCourante] := TStrokeDash(LigneCombo.itemIndex);
     end;
end;

procedure TFcoordonneesPhys.MinidBEditChange(Sender: TObject);
var m : indiceMonde;
begin
     m := transfert.iMonde[courbeCourante];
     transfert.minidb[m] := minidBEdit.value;
end;

Procedure TFcoordonneesPhys.majPages;
begin
    CommentaireEdit.FontColor:= couleurPages[pageActive];
    if pages[pageActive].commentaireP=''
       then CommentaireEdit.text := IntToStr(PageActive)+'/'+IntToStr(NbrePages)
       else CommentaireEdit.text := pages[pageActive].commentaireP;
    if traitRB.ischecked then LigneCombo.itemIndex := ord(PstylePages[PageActive]);
    if motifRB.ischecked then PointCombo.itemIndex := ord(motifPages[PageActive]);
    if couleurRB.ischecked then CouleurCombo.selectedColor := couleurPages[PageActive];
end;


procedure TFcoordonneesPhys.HelpBtnClick(Sender: TObject);
begin
  ShowAide((Sender as TControl).HelpContext, True);
end;

end.



