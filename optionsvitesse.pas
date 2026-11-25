unit optionsVitesse;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Colors,
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
  FMX.Spinbox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomComponent, FMX.TMSFNCBitmapContainer,
  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomPicker,
  FMX.TMSFNCStrokeKindPicker,
  FMX.TMSFNCFillKindPicker,
  FMX.TMSFNCStrokeKindSelector,
  FMX.TMSFNCFillKindSelector,
  FMX.TMSFNCAnalogTimePicker, FMX.TMSFNCCustomSelector,
  FMX.TMSFNCPanel,
  FMX.TMSFNCColorSelector,
  FMX.TMSFNCColorPicker, FMX.TMSFNCColorWheel,

  aidekey,
  compile,
  graphker,
  regutil,
  images;


type
  TOptionsVitesseDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Panel1: TPanel;
    GroupBox3: TGroupBox;
    LabelX: TLabel;
    LabelY: TLabel;
    Label4: TLabel;
    NbreLabel: TLabel;
    EchelleVecteurSE: TSpinBox;
    NbreSE: TSpinBox;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Label5: TLabel;
    AccelerationX: TComboBox;
    AccelerationY: TComboBox;
    ProlongeCB: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    VitesseX: TComboBox;
    VitesseY: TComboBox;
    UseSelectCB: TCheckBox;
    CouleurPointCB: TCheckBox;
    ProjeteCB: TCheckBox;
    CouleurVitesse: TTMSFNCColorPicker;
    CouleurAcceleration: TTMSFNCColorPicker;
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CouleurVitesseClick(Sender: TObject);
    procedure CouleurAccelerationClick(Sender: TObject);
    procedure CouleurVitesseColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure CouleurAccelerationColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    ListeVar : TstrListe;
    FVitesseColor: TAlphaColor;
    FAccColor: TAlphaColor;
    FPickerInitVitesse: TAlphaColor;
    FPickerInitAcc: TAlphaColor;
    FVitesseChanged: Boolean;
    FAccChanged: Boolean;
    procedure SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
  public
    grandeurX,grandeurY : Tgrandeur;
  end;

var
  OptionsVitesseDlg: TOptionsVitesseDlg;

implementation

uses AideU;

{$R *.FMX}

procedure TOptionsVitesseDlg.SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
var
  i, bestIdx: Integer;
  targetRec, itemRec: TAlphaColorRec;
  dist, bestDist, dr, dg, db: Integer;
begin
  APicker.SelectedColor := AColor;
  if (APicker.SelectedColor and $FF000000) <> 0 then
    Exit;
  if APicker.Items.Count = 0 then
    Exit;
  targetRec := TAlphaColorRec(AColor);
  bestIdx := 0;
  bestDist := MaxInt;
  for i := 0 to APicker.Items.Count - 1 do begin
    itemRec := TAlphaColorRec(APicker.Items[i].Color);
    dr := Integer(targetRec.R) - Integer(itemRec.R);
    dg := Integer(targetRec.G) - Integer(itemRec.G);
    db := Integer(targetRec.B) - Integer(itemRec.B);
    dist := dr * dr + dg * dg + db * db;
    if dist < bestDist then begin
      bestDist := dist;
      bestIdx := i;
    end;
  end;
  APicker.SelectedItemIndex := bestIdx;
end;

procedure TOptionsVitesseDlg.CouleurVitesseColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FVitesseColor := AColor;
    FVitesseChanged := True;
    couleurMecanique[mondeVitesse] := AColor;
  end;
end;

procedure TOptionsVitesseDlg.CouleurAccelerationColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FAccColor := AColor;
    FAccChanged := True;
    couleurMecanique[mondeAcc] := AColor;
  end;
end;

procedure TOptionsVitesseDlg.OKBtnClick(Sender: TObject);

Procedure Ajoute(Avariable : Tgrandeur;Acombo : TcomboBox;Agenre : TgenreMecanique);
var code,i : integer;
begin
    code := Acombo.itemIndex;
    if code<0 then exit;
    code := indexNom(Acombo.items[code]);
    if code<>grandeurInconnue then begin
       with grandeurs[code] do begin
          GenreMecanique := Agenre;
          nomVarPosition := Avariable.nom;
       end;
       for i := 1 to pred(NbreGrandeurs) do with grandeurs[i] do
          if (i<>code) and
             (genreMecanique=Agenre) and
             (nomVarPosition=Avariable.nom) then
               genreMecanique := gm_position;
    end;
end;

begin
    echelleVecteur := EchelleVecteurSE.value/100;
    NbreVecteurVitesseMax := round(NbreSE.value);
    couleurVitesseImposee := not CouleurPointCB.ischecked;
    ProlongeVecteur := ProlongeCB.isChecked;
    ProjeteVecteur := ProjeteCB.isChecked;
    UseSelect := UseSelectCB.isChecked;
    if FVitesseChanged then
      couleurMecanique[mondeVitesse] := FVitesseColor
    else if ((CouleurVitesse.selectedColor and $FF000000) <> 0) and
            (CouleurVitesse.selectedColor <> FPickerInitVitesse) then
      couleurMecanique[mondeVitesse] := CouleurVitesse.selectedColor
    else if (FVitesseColor and $FF000000) <> 0 then
      couleurMecanique[mondeVitesse] := FVitesseColor
    else if (CouleurVitesse.selectedColor and $FF000000) <> 0 then
      couleurMecanique[mondeVitesse] := CouleurVitesse.selectedColor
    else
      couleurMecanique[mondeVitesse] := claBlue;
    if FAccChanged then
      couleurMecanique[mondeAcc] := FAccColor
    else if ((CouleurAcceleration.selectedColor and $FF000000) <> 0) and
            (CouleurAcceleration.selectedColor <> FPickerInitAcc) then
      couleurMecanique[mondeAcc] := CouleurAcceleration.selectedColor
    else if (FAccColor and $FF000000) <> 0 then
      couleurMecanique[mondeAcc] := FAccColor
    else if (CouleurAcceleration.selectedColor and $FF000000) <> 0 then
      couleurMecanique[mondeAcc] := CouleurAcceleration.selectedColor
    else
      couleurMecanique[mondeAcc] := claRed;
    Ajoute(grandeurX,vitesseX,gm_Vitesse);
    Ajoute(grandeurY,vitesseY,gm_Vitesse);
    Ajoute(grandeurX,accelerationX,gm_Acceleration);
    Ajoute(grandeurY,accelerationY,gm_Acceleration);
end;

procedure TOptionsVitesseDlg.FormCreate(Sender: TObject);
begin
    ListeVar := TstrListe.create
end;

procedure TOptionsVitesseDlg.FormDestroy(Sender: TObject);
begin
    ListeVar.free;
    inherited
end;

procedure TOptionsVitesseDlg.FormShow(Sender: TObject);

procedure Ajoute(Avariable : Tgrandeur;Acombo : TcomboBox;Agenre : TgenreMecanique);
var code,index : integer;
begin
     Acombo.items := listeVar;
     Case Agenre of
        gm_Vitesse : index := IndexVitesse(Avariable.nom);
        gm_acceleration : index := IndexAcceleration(Avariable.nom)
        else exit;
     end;
     if index=grandeurInconnue then exit;
     code := ListeVar.MyIndexOf(grandeurs[index].nom);
     Acombo.itemIndex := code;
end;

var i : integer;
begin
     inherited;
     EchelleVecteurSE.value := round(echelleVecteur*100);
     ProlongeCB.IsChecked  := ProlongeVecteur;
     ProjeteCB.IsChecked  := ProjeteVecteur;
     NbreSE.value := NbreVecteurVitesseMax;
     FVitesseColor := couleurMecanique[mondeVitesse];
     if (FVitesseColor and $FF000000) = 0 then FVitesseColor := claBlue;
     FAccColor := couleurMecanique[mondeAcc];
     if (FAccColor and $FF000000) = 0 then FAccColor := claRed;
     FVitesseChanged := False;
     FAccChanged := False;
     SetPickerNearestColor(CouleurVitesse, FVitesseColor);
     FPickerInitVitesse := CouleurVitesse.selectedColor;
     SetPickerNearestColor(CouleurAcceleration, FAccColor);
     FPickerInitAcc := CouleurAcceleration.selectedColor;
     UseSelectCB.IsChecked  := UseSelect;
     CouleurPointCB.IsChecked  := not couleurVitesseImposee;
     ListeVar.Clear;
     for i := 1 to pred(NbreGrandeurs) do with grandeurs[i] do
         if genreG=variable then ListeVar.add(nom);
     labelX.Text  := 'Abscisse = '+grandeurX.nom;
     labelY.Text  := 'Ordonnée = '+grandeurY.nom;
     Ajoute(grandeurX,vitesseX,gm_Vitesse);
     Ajoute(grandeurY,vitesseY,gm_Vitesse);
     Ajoute(grandeurX,accelerationX,gm_Acceleration);
     Ajoute(grandeurY,accelerationY,gm_Acceleration);
end;

procedure TOptionsVitesseDlg.CouleurVitesseClick(Sender: TObject);
begin
    if (CouleurVitesse.selectedColor and $FF000000) <> 0 then begin
      FVitesseColor := CouleurVitesse.selectedColor;
      FVitesseChanged := True;
      couleurMecanique[mondeVitesse] := FVitesseColor;
    end;
end;

procedure TOptionsVitesseDlg.CouleurAccelerationClick(Sender: TObject);
begin
    if (CouleurAcceleration.selectedColor and $FF000000) <> 0 then begin
      FAccColor := CouleurAcceleration.selectedColor;
      FAccChanged := True;
      couleurMecanique[mondeAcc] := FAccColor;
    end;
end;


procedure TOptionsVitesseDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
