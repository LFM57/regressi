unit MyShape;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  System.Classes,
  System.Generics.Collections,
  System.math,

  FMX.Types,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Graphics,
  FMX.TextLayout,
  FMX.Layouts,

  regutil;

type
 TgenreBorne  = (bsDebut, bsFin);
 TpositionX = (Xgauche,Xdroit,Xauto);
 TpositionY = (Yhaut,Ybas,Yauto);

 TBorneShape = class(TRectangle)
 private
 FisSelected : boolean;
 Fgenre : TgenreBorne;
 Fvert : boolean;
 protected
   procedure setSelected(value : boolean);
   procedure setCentre(value : TpointF);
   function getCentre : TpointF;
   procedure setGenre(value : TgenreBorne);
   procedure setVert(value : boolean);
   procedure setForme;
 public
   IndexModele, IndexCourbe: integer;
   haut,bas : single;
   property avecVert : boolean read Fvert write setVert;
   property genre : TgenreBorne read Fgenre write setGenre;
   property isSelected : boolean read FisSelected write setSelected;
   property centre : TpointF read getCentre write setCentre;
   constructor Create(AOwner: TComponent); override;
   procedure SetMoveDown(move : TMouseMoveEvent; down,up : TMouseEvent);
 end;

 TRectSelect = class(TRectangle)
 private
 protected
 public
   constructor Create(AOwner: TComponent); override;
   procedure SetMoveDown(move : TMouseMoveEvent; down,up : TMouseEvent);
   procedure InitNull(P : TpointF);
 end;

 TReticuleShape = class(TShape)
 private
 FisVert,FisHoriz : boolean;
 FComplet : boolean;
 Fcentre : TpointF;
 Flayout : TTextLayout;
 FTexteX,FTexteY : string;
 protected
    procedure Paint; override;
    procedure setVert(value : boolean);
    procedure setHoriz(value : boolean);
    procedure setComplet(value : boolean);
    procedure setCentre(value : TpointF);
 public
   IndexModele, IndexCourbe: integer;
   positionX : TpositionX;
   positionY : TpositionY;
   property isVert : boolean read FisVert write setVert;
   property isHoriz : boolean read FisHoriz write setHoriz;
   property complet : boolean read Fcomplet write setComplet;
   property centre : TpointF read Fcentre write setCentre;
   property texteX : string read FTexteX write FTexteX;
   property texteY : string read FTexteY write FTexteY;
   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
   procedure SetMoveDown(move : TMouseMoveEvent; down,up : TMouseEvent);
 end;

const
    dimBorne = 8;
    dimVert = 3;
    rayon = dimBorne;
    BrushCouleurSelect = TAlphaColor($FFD62728);
    BrushCouleurZoom = TAlphaColor($FFFEF3C7);
    BrushCouleurBadgeBg = TAlphaColor($EEFEF3C7);
    BrushCouleurBadgeBorder = TAlphaColor($FFD97706);
    BrushCouleurBadgeText = TAlphaColor($FF1E293B);

implementation

const DecaleLabel = 4;

// Bornes
constructor TBorneShape.Create(AOwner: TComponent);
begin
  inherited;
  Parent := TPaintBox(Aowner);
  Stroke.Kind := TBrushKind.Solid;
  Fill.Kind := TBrushKind.None;
  Fill.Color := BrushCouleurSelect;
  Stroke.Thickness := 3;
  Cursor := crHandPoint;
  width := 2*dimBorne;
  height := 2*dimBorne;
  xradius := rayon;
  yradius := rayon;
end;

procedure TBorneShape.setGenre(value : TgenreBorne);
begin
   Fgenre := value;
   setForme;
end;

procedure TBorneShape.setVert(value : boolean);
begin
   Fvert := value;
   setForme;
end;

procedure TBorneShape.setForme;
begin
   if Fvert
      then begin
           position.y := haut;
           height := bas-haut;
           width := 2*dimVert;
      end
      else begin
           width := 2*dimBorne;
           height := 2*dimBorne;
      end;
   if Fgenre=bsFin
   then if Fvert
      then corners := [Tcorner.TopLeft,Tcorner.BottomLeft]
      else corners := [Tcorner.TopLeft,Tcorner.TopRight,Tcorner.BottomLeft,Tcorner.BottomRight]
   else if Fvert
      then corners := [Tcorner.TopRight,Tcorner.BottomRight]
      else corners := [];
end;

procedure TBorneShape.setSelected(value : boolean);
begin
    FisSelected := value;
    if FisSelected
       then Fill.Kind := TBrushKind.Solid
       else Fill.Kind := TBrushKind.None
end;

procedure TBorneShape.SetMoveDown(move : TMouseMoveEvent; down,up : TMouseEvent);
begin
     OnMouseMove := move;
     OnMouseDown := down;
     OnMouseUp := up;
end;

procedure TBorneShape.setCentre(value : TpointF);
begin
    if Fvert
    then begin
        position.x := value.X-dimVert;
    end
    else begin
        value.Offset(-dimBorne,-dimBorne);
        position.point := value;
    end;
end;

function TBorneShape.getCentre : TpointF;
begin
    result := position.Point;
     if Fvert
        then result.Offset(dimVert,0)
        else result.Offset(dimBorne,dimBorne);
end;

// Reticule
procedure TReticuleShape.SetMoveDown(move : TMouseMoveEvent; down,up : TMouseEvent);
begin
     OnMouseMove := move;
     OnMouseDown := down;
     OnMouseUp := up;
end;

constructor TReticuleShape.Create(AOwner: TComponent);
begin
  inherited;
  Parent := TPaintBox(Aowner);
  stroke.Dash := TStrokeDash.DashDot;
  Stroke.Thickness := 1;
  Cursor := crHandPoint;
  Stroke.color := TAlphaColor($FF475569);
  FisVert := true;
  FisHoriz := true;
  Fcomplet := true;
  Fcentre := TpointF.Create(0,0);
  Flayout := TTextLayoutManager.DefaultTextLayout.Create;
  Flayout.layoutCanvas := canvas;
//  Flayout.Font.Family := FonteRegressi;
  Flayout.font.Size := 14;
  Flayout.verticalAlign := TTextAlign.Leading;  // Center Leading Trailing
  Flayout.horizontalAlign := TTextAlign.Leading;
  Flayout.Color := BrushCouleurBadgeText;
end;

destructor TReticuleShape.Destroy;
begin
  Flayout.Free;
  inherited;
end;

procedure TReticuleShape.Paint;

procedure traceFond(P : TpointF;L,H : single);
var
   R : TRectF;
   saveStrokeColor : TAlphaColor;
   saveStrokeDash : TStrokeDash;
   saveStrokeThickness : single;
   saveStrokeKind : TBrushKind;
begin
   R := TRectF.Create(P.X, P.Y, P.X + L, P.Y + H);
   saveStrokeColor := canvas.Stroke.Color;
   saveStrokeDash := canvas.Stroke.Dash;
   saveStrokeThickness := canvas.Stroke.Thickness;
   saveStrokeKind := canvas.Stroke.Kind;
   canvas.Fill.Kind := TBrushKind.Solid;
   canvas.Fill.Color := BrushCouleurBadgeBg;
   canvas.FillRect(R, 4, 4, AllCorners, 1);
   canvas.Stroke.Kind := TBrushKind.Solid;
   canvas.Stroke.Dash := TStrokeDash.Solid;
   canvas.Stroke.Thickness := 1;
   canvas.Stroke.Color := BrushCouleurBadgeBorder;
   canvas.DrawRect(R, 4, 4, AllCorners, 1);
   canvas.Fill.Kind := TBrushKind.None;
   canvas.Stroke.Color := saveStrokeColor;
   canvas.Stroke.Dash := saveStrokeDash;
   canvas.Stroke.Thickness := saveStrokeThickness;
   canvas.Stroke.Kind := saveStrokeKind;
end;

procedure traceTexte(P : TpointF;S : string);
var L,H : single;
begin
   if S = '' then Exit;
   Flayout.BeginUpdate;
   Flayout.WordWrap := False;
   Flayout.MaxSize := TPointF.Create(10000, 10000);
   Flayout.Color := BrushCouleurBadgeText;
   Flayout.Text := S;
   Flayout.EndUpdate;
   L := Flayout.TextWidth;
   H := Flayout.TextHeight;
   if L < Canvas.TextWidth(S) then L := Canvas.TextWidth(S);
   if H < Canvas.TextHeight(S) then H := Canvas.TextHeight(S);
   traceFond(P, L + 12, H + 4);
   Flayout.BeginUpdate;
   Flayout.TopLeft := TPointF.Create(P.X + 6, P.Y + 2);
   Flayout.MaxSize := TPointF.Create(L + 4, H + 2);
   Flayout.EndUpdate;
   Flayout.RenderLayout(Canvas);
end;

procedure traceTexteX;
var P : TPointF;
    ecart : single;
    ecartX : single;
begin
   P := TpointF.create(Fcentre.x,height);
   ecart := 2*Canvas.TextHeight('A');
   ecartX := decaleLabel;
   case positionX of
      Xauto : if (FCentre.x>width/2)
        then ecartX := -Canvas.TextWidth(FtexteX);
      Xdroit : ;
      Xgauche : ecartX := -Canvas.TextWidth(FtexteX);
   end;
   P.offset(ecartX,-ecart);
   traceTexte(P,FTexteX);
end;

procedure traceTexteY;
var P : TPointF;
    ecartY : single;
begin
   P := TpointF.create(0,FCentre.y);
   ecartY := decaleLabel;
   case positionY of
      Yauto : if (FCentre.y>height/2)
      then ecartY := -Canvas.TextHeight(FtexteY);
      Ybas : ;
      Yhaut : ecartY := -Canvas.TextHeight(FtexteY);
   end;
   P.Offset(decaleLabel,ecartY);
   traceTexte(P,FTexteY);
end;

begin
   inherited;
   if FisVert then begin
   if Fcomplet
      then canvas.DrawLine(TpointF.Create(Fcentre.X,0),TpointF.Create(Fcentre.X,height),1)
      else canvas.DrawLine(TpointF.Create(Fcentre.X,Fcentre.Y-dimBorne),TpointF.Create(Fcentre.X,Fcentre.Y+dimBorne),1);
      if FtexteY<>'' then traceTexteY;
   end;
   if FisHoriz then begin
   if Fcomplet
      then canvas.DrawLine(TpointF.Create(0,Fcentre.Y),TpointF.Create(width,Fcentre.Y),1)
      else canvas.DrawLine(TpointF.Create(Fcentre.X-dimBorne,Fcentre.Y),TpointF.Create(Fcentre.X+dimBorne,Fcentre.Y),1);
      if FtexteX<>'' then traceTexteX;
   end;
end;

procedure TReticuleShape.setVert(value : boolean);
begin
    FisVert := value
end;

procedure TReticuleShape.setComplet(value : boolean);
begin
    Fcomplet := value
end;

procedure TReticuleShape.setCentre(value : TpointF);
begin
    Fcentre := value;
    Repaint;
end;

procedure TReticuleShape.setHoriz(value : boolean);
begin
    FisHoriz := value
end;

// RectSelect
constructor TRectSelect.Create(AOwner: TComponent);
begin
  inherited;
  Parent := TpaintBox(Aowner);
  Stroke.Kind := TBrushKind.Solid;
  Fill.Kind := TBrushKind.Solid;
  Opacity := 0.3;
  Fill.Color := brushCouleurZoom;
  Stroke.Color := claBlack;
  Stroke.Thickness := 1;
  Cursor := crHandPoint;
end;

procedure TRectSelect.SetMoveDown(move : TMouseMoveEvent; down,up : TMouseEvent);
begin
     OnMouseMove := move;
     OnMouseDown := down;
     OnMouseUp := up;
end;

procedure TRectSelect.InitNull(P : TPointF);
begin
    position.point := P;
    width := 0;
    height := 0;
end;

end.


