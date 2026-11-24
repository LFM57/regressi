unit grapheOptique;

interface

uses System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
     System.Math.vectors, System.UIConsts, System.IOUtils, System.iniFiles,
     FMX.Types, FMX.Objects, FMX.Layouts, FMX.Platform, FMX.Graphics, FMX.Utils, FMX.Controls,
     maths, regutil;

const
        MaxVecteurOptique = 4096;

type
        TstyleDragOptique = (bsNone,bsOrigine,bsDirection,bsEchelle1,bsEchelle2);
        TstyleDragX = (dxNone,dx1,dx2);
        TIndiceVecteurOptique = -MaxVecteurOptique..MaxVecteurOptique;
        TvecteurOptique = array[TindiceVecteurOptique] of single;
        TarrayPoint = array[TstyleDragOptique] of TpointF;

 Tmonde = class
    mini,maxi : single;
    a,b : single; // entier = réel*a+b
    Procedure ToScreen(xr : single;var xi : single);
    Procedure ToReal(xi : single;var xr : single);
    constructor create;
 end;

 type
 TgrapheOptique = class
      LimiteCourbe : TrectF;
      LPaintBox : TPaintBox;
      mondeX : Tmonde;
      mondeY : Tmonde;
      debutG,finG : integer;
      dimPix : single;
      valeurX,Intensite,rouge,vert,bleu : TvecteurOptique;
      wR,wG,wB,wL : boolean;
      e_PointX : array[TstyleDragX] of single;
      x1,x2 : single;
      Constructor Create;
      Procedure DrawG;
      Procedure WindowXY(xr,yr : single;var xi,yi : single);
      procedure EcranVersPB;
      destructor Destroy;override;
   end;

IMPLEMENTATION

const
   CouleurFond = claWhite;
   CouleurIntensite = claBlack;
   mondeX = 0;
   mondeY = 1;

constructor Tmonde.Create;
begin
    inherited create;
    A := 1;
    B := 0;
    Maxi := 1;
    Mini := 0;
end;

Procedure Tmonde.ToReal(xi : single;var xr : single);
begin
    xr := (xi-B)/A;
end;

Procedure Tmonde.ToScreen(xr : single;var xi : single);
begin
     xi := A*xr+B;
end;

Procedure TgrapheOptique.WindowXY(xr,yr : single;var xi,yi : single);
begin
     mondeX.ToScreen(xr,xi);
     mondeY.ToScreen(yr,yi);
end;

procedure TgrapheOptique.DrawG;
var LCanvas : TCanvas;

procedure ChercheMonde;
begin
     MondeX.mini := valeurX[debutG];
     MondeX.maxi := valeurX[finG];
     with LimiteCourbe do begin
         if mondeX.Maxi=mondeX.Mini then begin
            mondeX.A := 0;
            mondeX.B := left;
         end
         else begin
            mondeX.A := (right-left)/(mondeX.Maxi-mondeX.Mini);
            mondeX.B := left-mondeX.Mini*mondeX.A;
         end;
         if mondeY.Maxi=mondeY.Mini then begin
            mondeY.A := 0;
            mondeY.B := bottom;
         end
         else begin
            mondeY.A := (top-bottom)/(mondeY.Maxi-mondeY.Mini);
            mondeY.B := bottom-mondeY.Mini*mondeY.A;
         end;
     end;
end;// ChercheMonde

procedure TraceCouleur(vect : TvecteurOptique;couleur : TAlphaColor);
var x,y : single;
    i : integer;
    FPath : TPathData;
begin with LimiteCourbe,mondeY do begin
      if finG<=debutG then exit;
      windowXY(valeurX[debutG],vect[debutG],x,y);
      LCanvas.stroke.color := couleur;
      FPath := TPathData.Create;
      FPath.moveTo(TPointF.create(x,y));
      for i := debutG to finG do begin
           windowXY(valeurX[i],vect[i],x,y);
           if (x>0) and (y>0) then FPath.LineTo(TPointF.create(x,y))
      end;
      LCanvas.DrawPath(FPath, 1);
      FPath.free;
end end;// TraceCouleur

procedure TraceReticule(x : single);
begin
    LCanvas.DrawLine(TpointF.create(X, 0), TpointF.create(X, limiteCourbe.bottom),1);
end;

var margeX : single;
    j : TStyleDragX;
    x1,x2,y0 : single;
begin
     chercheMonde;
     Lcanvas := LpaintBox.canvas;
     with LCanvas do begin
        stroke.kind := TBrushKind.Solid;
        fill.kind := TBrushKind.Solid;
        stroke.thickness := 1;
        fill.color := couleurFond;
        FillRect(TrectF.Create(0,0,LpaintBox.Width,LpaintBox.Height),0,0,AllCorners,1);
     end;
     if wL then TraceCouleur(intensite,couleurIntensite);
     if wR then TraceCouleur(rouge,claRed);
     if wB then TraceCouleur(bleu,claBlue);
     if wG then TraceCouleur(vert,claGreen);
     margeX := (limiteCourbe.right-limiteCourbe.left)/20;
     for j := dx1 to dx2 do begin
        if e_PointX[j]<(limiteCourbe.left+margeX) then e_PointX[j] := limiteCourbe.left + margeX;
        if e_PointX[j]>(limiteCourbe.right-margeX) then e_PointX[j] := limiteCourbe.right - margeX;
     end;
     x1 := e_PointX[dx2];
     x2 := e_PointX[dx1];
     y0 := limiteCourbe.bottom;
     with Lcanvas do begin // Deux points de repères
        stroke.Color := claBlack;
        DrawLine(TpointF.create(X1, 0), TpointF.create(X1, y0),1);
        DrawLine(TpointF.create(X2, 0), TpointF.create(X2, y0),1);
     end;
end; // tgraphe.drawG

destructor TgrapheOptique.destroy;
begin
    mondeX.free;
    mondeY.free;
    inherited
end;

constructor TgrapheOptique.Create;
var j : integer;
begin
   inherited;
   mondeX := Tmonde.create;
   mondeY := Tmonde.create;
   MondeY.maxi := 1.05;
   MondeY.mini := -0.05;
   finG := 0;
   debutG := 0;
   e_pointX[dx1] := 100;
   e_pointX[dx2] := 200;
   for j := -maxVecteurOptique to maxVecteurOptique do
       valeurX[j] := j;
end;

procedure TGrapheOptique.EcranVersPB;
begin
   mondeX.ToReal(e_pointX[dx1],x1);
   mondeX.ToReal(e_pointX[dx2],x2);
end;

end.

