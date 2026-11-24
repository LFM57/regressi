// Axes.pas : fichier inclus de graphker.pas pour tracé des axes

procedure TGrapheReg.TraceTitreAxeY(g : tgrandeur;m : indiceMonde;
      indexCourbe : integer);
var
  item : TTitreAxeY;
begin
     if g=nil then exit;
     if g.fonct.genreC=g_Texte then exit;
     if Monde[m].TitreAxe.IndexOf(g.nom)>=0 then exit;
     item.Couleur := courbes[indexCourbe].couleur;
     item.Texte := g.axe((m=mondeY) and
                (courbes[0].trace=[trResidus]),
                 monde[m].graduation=gdB,monde[m].exposant);
     item.Monde := m;
     item.Largeur := canvas.textWidth(item.Texte)+marge;
     item.Hauteur := canvas.textHeight(item.Texte)+marge;
     monde[m].TitreAxe.Add(g.nom);
     TitresY.Add(item);
end; // traceTitreAxeY

procedure TGrapheReg.DrawTitresAxeY;
var
  m : indiceMonde;
  i, n : integer;
  gap, totalLen, px, py, bandCenter, bandBottom : single;
  saveMat, rotMat : TMatrix;
  saveAlignH, saveAlignV : TTextAlign;
  item : TTitreAxeY;
begin
  if TitresY.Count = 0 then exit;
  gap := canvas.TextWidth('  ');
  saveMat := canvas.Matrix;
  saveAlignH := layout.HorizontalAlign;
  saveAlignV := layout.VerticalAlign;
  try
    layout.HorizontalAlign := TTextAlign.Leading;
    layout.VerticalAlign := TTextAlign.Leading;
    for m := mondeY to high(indiceMonde) do begin
      n := 0;
      totalLen := 0;
      for i := 0 to TitresY.Count - 1 do
        if TitresY[i].Monde = m then begin
          totalLen := totalLen + TitresY[i].Largeur;
          inc(n);
        end;
      if n = 0 then continue;
      totalLen := totalLen + (n - 1) * gap;
      px := monde[m].PTitre.x;
      if OgPolaire in OptionGraphe then begin
        py := monde[m].PTitre.y + totalLen / 2;
        if py > limiteFenetre.Bottom then py := limiteFenetre.Bottom;
      end
      else if (OgAnalyseurLogique in OptionGraphe) and not superposePage then begin
        bandCenter := (monde[m].CourbeTop + monde[m].CourbeBottom) / 2;
        bandBottom := monde[m].CourbeBottom;
        py := bandCenter + totalLen / 2;
        if py > bandBottom then py := bandBottom;
      end
      else begin
        bandCenter := (limiteFenetre.Top + limiteFenetre.Bottom) / 2;
        py := bandCenter + totalLen / 2;
        if py > limiteFenetre.Bottom then py := limiteFenetre.Bottom;
      end;
      for i := 0 to TitresY.Count - 1 do
        if TitresY[i].Monde = m then begin
          item := TitresY[i];
          rotMat := TMatrix.CreateRotation(-Pi / 2) *
                    TMatrix.CreateTranslation(px, py) *
                    saveMat;
          canvas.SetMatrix(rotMat);
          layout.BeginUpdate;
          layout.TopLeft := TPointF.Create(0, 0);
          layout.MaxSize := TPointF.Create(item.Largeur + 6, item.Hauteur + 4);
          layout.Color := item.Couleur;
          layout.Text := item.Texte;
          layout.EndUpdate;
          layout.RenderLayout(canvas);
          py := py - item.Largeur - gap;
        end;
    end;
  finally
    canvas.SetMatrix(saveMat);
    layout.HorizontalAlign := saveAlignH;
    layout.VerticalAlign := saveAlignV;
  end;
end; // DrawTitresAxeY

procedure TGrapheReg.TraceTitreAxeX(g : tgrandeur;indexCourbe : integer);
var S : string;
    mondeBis : indiceMonde;
begin
    if g=nil then exit;
    if g.fonct.genreC=g_Texte then exit;
    if Monde[mondeX].TitreAxe.IndexOf(g.nom)>=0 then exit;
    canvas.stroke.kind := TBrushKind.None;
    if UnAxeX
       then couleurTexte := couleurAxeX
       else couleurTexte := courbes[indexCourbe].couleur;
    mondeBis := mondeX;
    SetTextAlign(TTextAlign.trailing,TTextAlign.leading);
    if monde[mondeY].defini
       then mondeBis := mondeY
       else if monde[mondeDroit].defini
            then mondeBis := mondeDroit
            else if monde[mondeSans].defini
                 then mondeBis := mondeSans;
    with monde[mondeX] do begin
        S := g.axe(monde[mondeBis].axe.nom=hHistoResidu,graduation=gdB,exposant);
        MyDrawText(PTitre,S);
        PTitre.offset(canvas.textWidth(S+' '),0);
        TitreAxe.Add(g.nom);
    end; // monde[mondeX]
    canvas.stroke.kind := TBrushKind.Solid;
end; // traceTitreAxeX

procedure TGrapheReg.DrawAxis(initialisation : boolean);
const MinTickLabelGap = 8;
var xNombreMax,xNombreMin,signeMargeX : single;
    PointCourant : double;
    yAxeX,xAxeY : single;
    couleurAxeY : TAlphaColor;
    SigneAligneY : integer;
    GraduationYtrace : boolean;
    mondeYseul : boolean;
    penWidthGrad,penWidthAxe : single;
    couleurGrillePale : TAlphaColor;

Function YcorrectNombre(y : single;m : indiceMonde) : boolean;
begin with monde[m] do
        YcorrectNombre := (y>(CourbeTop+marge*3)) and (y<=CourbeBottom)
end;

Function YcorrectGrad(y : single;m : indiceMonde) : boolean;
begin with monde[m] do
        result := (y>(CourbeTop+marge*3)) and
                  (y<=CourbeBottom) and
                  (y<>yAxeX)
end;

Function XcorrectNombre(x : single) : boolean;
begin
     XcorrectNombre := (x>xNombreMin) and (x<xNombreMax)
end;

Function XcorrectGrad(x : single) : boolean;
begin
     XcorrectGrad := (x>=limiteCourbe.left) and
                     (x<limiteCourbe.right) and
                     (x<>xAxeY)
end;

function TickRectsOverlap(const A, B : TRectF; MinGap : single) : boolean;
begin
     Result := (A.Left < B.Right + MinGap) and
               (A.Right + MinGap > B.Left) and
               (A.Top < B.Bottom + MinGap) and
               (A.Bottom + MinGap > B.Top);
end;

Procedure graduationX(P : TpointF;quadrillage,grande : boolean);
begin
  if quadrillage
       then begin
    // pSSolid psDot psDash psDashDot psDashDotDot psClear
          if grande
             then CreatePen(TstrokeDash.Solid,penWidthGrad,couleurGrille)
             else CreatePen(TstrokeDash.Dot,1,couleurGrillePale);
          segmentXY(P.x,limiteCourbe.top,P.x,limiteCourbe.bottom);
       end
       else begin
          CreatePen(TstrokeDash.Solid,penWidthGrad,couleurAxeX);
          if grande
             then segmentXY(P.x,P.y,P.x,P.y+2*marge)
             else segmentXY(P.x,P.y,P.x,P.y+marge/2)
       end;
end;

Procedure graduationY(y : single;quadrillage,grande : boolean);
begin
   if quadrillage
       then begin
          if grande
             then CreatePen(TstrokeDash.Solid,penWidthGrad,couleurGrille)
             else CreatePen(TstrokeDash.Dot,1,couleurGrillePale);
          segmentXY(limiteCourbe.left,y,limiteCourbe.right,y)
       end
       else begin
          canvas.stroke.Dash := TstrokeDash.Solid;
          canvas.stroke.color := couleurAxeY;
          if grande
             then segmentXY(xAxeY,y,xAxeY+signeMargeX*2*marge,y)
             else segmentXY(xAxeY,y,xAxeY+signeMargeX*marge/2,y);
       end
end;

  procedure initAxeX;
  var P1 : TpointF;
  begin with monde[mondeX] do begin
    PointCourant := PointDebut;
    CreatePen(TstrokeDash.Solid,penWidthAxe,CouleurAxeX);
    if (Graduation=gLin) and
        not(GraduationZeroY) then begin
            WindowXY(0,0,mondeY,P1);
            if (P1.x>limiteCourbe.left) and (P1.x<limiteCourbe.right) then
            with limiteCourbe do segmentXY(P1.x,bottom,P1.x,top);
    end;
    xNombreMax := limiteFenetre.right-largCarac*NbreChiffres/2;
    xNombreMin := limiteFenetre.left+largCarac*NbreChiffres/2;
    if monde[mondeX].axe<>nil then TraceTitreAxeX(Axe,0);
    with limiteFenetre do begin
          segmentXY(left,yAxeX,right,yAxeX);
          // fléche X
          segmentXY(right-marge*3,yAxeX+marge,right,yAxeX);
          segmentXY(right-marge*3,yAxeX-marge,right,yAxeX);
    end;
    SetTextAlign(TtextAlign.center,TTextAlign.leading);
    SigneAligneY := +1;
    canvas.stroke.color := couleurGrille;
  end end;// initAxeX

  procedure traceAxeX;
  var Ps : TpointF;
      NombreAff, DrawText : string;
      Ticks : integer;
      grandeGraduation,Q,hasLast : boolean;
      Xmax : double;
      lastRect, curRect : TRectF;
      lblW, lblH, drawX, drawY : single;
  begin with monde[mondeX] do begin
       Q := (OgQuadrillage in OptionGraphe) and initialisation;
       Ticks := TickDebut;
       hasLast := False;
       if orthonorme
          then Xmax := maxiOrtho
          else Xmax := maxi;
       repeat
          windowXY(PointCourant,monde[mondeY].Mini,mondeY,Ps);
          if XcorrectGrad(Ps.x) then begin
               Ps.y := yAxeX;
               grandeGraduation := (Ticks mod NTicks)=0;
               graduationX(Ps,Q,grandeGraduation);
               if XcorrectNombre(Ps.x) and (grandeGraduation or not autoTick) then begin
                  if abs(PointCourant) < 0.5 * deltaAxe then pointCourant := 0;
                  if GraduationPiActive
                     then NombreAff := formatRadian(pointCourant)
                     else NombreAff := formatMonde(pointCourant);
                  if Ps.x<>xAxeY then begin
                     DrawText := NombreAff;
                     drawX := Ps.x;
                  end
                  else if PointCourant=0 then begin
                     DrawText := '0';
                     drawX := Ps.x+marge;
                  end
                  else DrawText := '';
                  if DrawText<>'' then begin
                     drawY := Ps.y+2*marge;
                     lblW := Canvas.TextWidth(DrawText)+6;
                     lblH := Canvas.TextHeight(DrawText)+4;
                     curRect := TRectF.Create(drawX-lblW/2, drawY, drawX+lblW/2, drawY+lblH);
                     if (not hasLast) or (not TickRectsOverlap(curRect, lastRect, MinTickLabelGap)) then begin
                        MyDrawText(TPointF.create(drawX,drawY),DrawText);
                        lastRect := curRect;
                        hasLast := True;
                     end;
                  end;
               end;
          end;
          PointCourant := PointCourant+deltaAxe;
          inc(Ticks);
      until ( PointCourant>=Xmax );
      CreatePen(TStrokeDash.Solid,penWidthAxe,CouleurAxeX);
      with limiteFenetre do segmentXY(left,yAxeX,right,yAxeX);
 end end; // traceAxeX

  procedure tracePolaire;
  var Ps,P0 : TpointF;
      NombreAff : string;
      NU : string;
      m : indiceMonde;
      ticks : integer;
      grandeGraduation : boolean;
      minix,miniy,maxix,maxiy : double;
      maxiXY : double;
  begin with limiteFenetre do begin
      if monde[mondeX].maxi>monde[mondeY].maxi
          then m := mondeX
          else m := mondeY;
      MondeXY(TPointF.create(left,bottom),mondeY,miniX,miniY);
      MondeXY(TPointF.create(right,top),mondeY,maxiX,maxiY);
      if maxiX>maxiY
          then maxiXY := maxiX
          else maxiXY := maxiY;
      WindowXY(0,0,mondeY,P0);
      NU := monde[mondeY].Axe.nom+monde[mondeY].Axe.UniteAxe(monde[m].exposant);
      xNombreMax := right-(length(NU)+monde[m].NbreChiffres)*largCarac;
      windowXY(0,0,mondeY,P0);
      SigneAligneY := +1;
      Ticks := monde[m].TickDebut;
      if (OgQuadrillage in OptionGraphe) and initialisation
         then begin
            SetTextAlign(TTextAlign.leading,TTextAlign.leading);
            SigneAligneY := +1;
            PointCourant := monde[m].pointDebut;
            repeat
               windowXY(PointCourant,0,mondeY,Ps);
               grandeGraduation := (Ticks mod monde[m].NTicks)=0;
               if grandeGraduation
                  then CreatePen(TStrokeDash.Solid,penWidthGrad,couleurGrille)
                  else CreatePen(TstrokeDash.Dot,1,couleurGrillePale);
               MyDrawEllipse(2*P0.X-Ps.x,Ps.y,Ps.x,2*P0.y-Ps.y);
               PointCourant := PointCourant+monde[m].deltaAxe;
               inc(Ticks);
            until PointCourant>=maxiXY;
         end
         else begin
             SetTextAlign(TTextALign.center,TTextAlign.leading);
             SigneAligneY := +1;              
         end;
      PointCourant := monde[m].pointDebut;
      CreatePen(TstrokeDash.Solid,penWidthGrad,CouleurAxeX);
      Ticks := monde[m].TickDebut;
      repeat
        windowXY(PointCourant,PointCourant,mondeY,Ps);
        grandeGraduation := ((Ticks mod monde[m].NTicks)=0) and
                              (Ps.x<=xNombreMax);
        if grandeGraduation then begin
             with Monde[m] do NombreAff := formatMonde(pointCourant);
             MyDrawText(TPointF.create(Ps.x,P0.y+marge),NombreAff);
        end;
        segmentXY(Ps.x,P0.y+marge,Ps.x,P0.y-marge);
        if Ps.y>=top then segmentXY(P0.x-marge,Ps.y,P0.x+marge,Ps.y);
        PointCourant := -PointCourant;
        windowXY(PointCourant,PointCourant,mondeY,Ps);
        PointCourant := -PointCourant;
        if Ps.x>=left then segmentXY(Ps.x,P0.y+marge,Ps.x,P0.y-marge);
          if Ps.y<=bottom then segmentXY(P0.x-marge,Ps.y,P0.x+marge,Ps.y);
        PointCourant := PointCourant+monde[m].deltaAxe;
        inc(Ticks);
      until PointCourant>=maxiXY;
      CreatePen(TStrokeDash.DashDot,penWidthAxe,CouleurAxeX);
      segmentXY(P0.x,bottom,P0.x,top); // axe y
      segmentXY(left,P0.y,right,P0.y); // axe x
      TraceTitreAxeY(monde[mondeY].axe,mondeY,0);
      couleurTexte := CouleurAxeX;
 end end; // tracePolaire

 procedure initAxeY(m : indiceMonde;indexCourbe : integer);
 var P1 : TpointF;
 begin with monde[m] do begin
        Axe := courbes[indexCourbe].varY;
        if courbes[indexCourbe].varY.fonct.genreC=g_Texte then exit;
        if mondeYseul
           then couleurAxeY := couleurAxeX
           else couleurAxeY := courbes[indexCourbe].couleur;
        if not empilePage then TraceTitreAxeY(Axe,m,indexCourbe);
        if mondeYseul then couleurTexte := CouleurAxeX;
        PointCourant := PointDebut;
        CreatePen(TstrokeDash.Solid,penWidthAxe,CouleurAxeY);
        if (Graduation=gLin) and
           not(GraduationZeroX) then begin
              WindowXY(0,0,m,P1);
              if yCorrectGrad(P1.y,m) then
                 with limiteCourbe do segmentXY(left,P1.y,right,P1.y);
        end;
        if (m=mondeDroit) and not(OgAnalyseurLogique in OptionGraphe)
           then setTextAlign(TTextAlign.leading,TTextALign.center)
           else setTextAlign(TTextAlign.trailing,TTextAlign.center);
        SigneAligneY := -1;
        Canvas.stroke.color := couleurAxeX;
 end end; // initAxeY

 procedure traceAxeY(m : indiceMonde);
 var ticks : Integer;
     nombreAff, DrawText : string;
     grandeGraduation,Q,hasLast,isRightAxis : boolean;
     Ymax : double;
     Ps : TpointF;
     lastRect, curRect : TRectF;
     lblW, lblH, drawX : single;
 begin with monde[m] do begin
      if axe.fonct.genreC=g_Texte then exit;
      Q := (OgQuadrillage in OptionGraphe) and
           ( not(GraduationYtrace) or
            (OgAnalyseurLogique in OptionGraphe)) and
           initialisation;
      GraduationYTrace := true;
      Ticks := TickDebut;
      hasLast := False;
      isRightAxis := (m=mondeDroit) and not(OgAnalyseurLogique in OptionGraphe);
      drawX := xAxeY+2.5*signeMargeX*marge;
      if Orthonorme
         then Ymax := maxiOrtho
         else Ymax := maxi;
      repeat
           windowXY(monde[mondeX].Mini,PointCourant,m,Ps);
             // coordonnée écran de la marque
           if YcorrectGrad(Ps.y,m) then begin
                 grandeGraduation := (Ticks mod NTicks)=0;
                 if YcorrectNombre(Ps.y,m) and (grandeGraduation or not autoTick) then begin
                    if abs(pointCourant) < 0.5 * deltaAxe then pointCourant := 0;
                    if graduationPiActive
                       then NombreAff := formatRadian(pointCourant)
                       else NombreAff := formatMonde(pointCourant);
                    if Ps.y<>yAxeX
                       then DrawText := NombreAff
                       else if PointCourant=0
                          then DrawText := '0'
                          else DrawText := '';
                    if DrawText<>'' then begin
                       lblW := Canvas.TextWidth(DrawText)+6;
                       lblH := Canvas.TextHeight(DrawText)+4;
                       if isRightAxis
                          then curRect := TRectF.Create(drawX, Ps.y-lblH/2, drawX+lblW, Ps.y+lblH/2)
                          else curRect := TRectF.Create(drawX-lblW, Ps.y-lblH/2, drawX, Ps.y+lblH/2);
                       if (not hasLast) or (not TickRectsOverlap(curRect, lastRect, MinTickLabelGap)) then begin
                          MyDrawText(TpointF.create(drawX,Ps.y),DrawText);
                          lastRect := curRect;
                          hasLast := True;
                       end;
                    end;
                 end;
                 graduationY(Ps.y,Q,grandeGraduation);
           end;
           pointCourant := pointCourant+deltaAxe;
           inc(Ticks);
      until ( pointCourant>=Ymax );
      CreatePen(TStrokeDash.Solid,penWidthAxe,CouleurAxeY);
      segmentXY(xAxeY,CourbeBottom,xAxeY,CourbeTop);
      if avecAxeY then begin // flèche Y
          segmentXY(xAxeY-marge,courbeTop+3*marge,xAxeY,courbeTop);
          segmentXY(xAxeY+marge,courbeTop+3*marge,xAxeY,courbeTop);
      end;
end end; // traceAxeY

procedure traceAxeLogx;
var i,j : integer;
    Ps : TpointF;
    intermediaire,intermediaire25,Q,hasLast,hasNextMajor : boolean;
    lastRect, curRect, nextMajorRect : TRectF;
    lblW, lblH, drawY : single;
    lblText, nextText : string;
begin with Monde[mondeX] do begin
   try
   Q := (OgQuadrillage in OptionGraphe) and initialisation;
   Intermediaire := (Maxi-Mini) < 6;
   Intermediaire25 := (Maxi-Mini) < 9;
   hasLast := False;
   drawY := yAxeX+2*marge;
   for i := floor(Mini) to ceil(Maxi) do begin
       windowXY(i,monde[mondeY].Mini,mondeY,Ps);
       Ps.y := yAxeX;
       if XcorrectGrad(Ps.x) then begin
           graduationX(Ps,Q,true);
           if XcorrectNombre(Ps.x) then begin
              lblText := formatMonde(dix(i));
              lblW := Canvas.TextWidth(lblText)+6;
              lblH := Canvas.TextHeight(lblText)+4;
              curRect := TRectF.Create(Ps.x-lblW/2, drawY, Ps.x+lblW/2, drawY+lblH);
              if (not hasLast) or (not TickRectsOverlap(curRect, lastRect, MinTickLabelGap)) then begin
                 MyDrawText(TpointF.create(Ps.x,drawY),lblText);
                 lastRect := curRect;
                 hasLast := True;
              end;
           end;
       end;
       windowXY(succ(i),monde[mondeY].Mini,mondeY,Ps);
       hasNextMajor := XcorrectGrad(Ps.x) and XcorrectNombre(Ps.x);
       if hasNextMajor then begin
          nextText := formatMonde(dix(succ(i)));
          lblW := Canvas.TextWidth(nextText)+6;
          lblH := Canvas.TextHeight(nextText)+4;
          nextMajorRect := TRectF.Create(Ps.x-lblW/2, drawY, Ps.x+lblW/2, drawY+lblH);
       end;
       for j := 2 to 9 do begin
           windowXY(i+log10(j),monde[mondeY].Mini,mondeY,Ps);
           Ps.y := yAxeX;
           if XcorrectGrad(Ps.x) then
              if intermediaire or (intermediaire25 and ((j=2) or (j=4) or (j=8)))
                     then begin
                        graduationX(Ps,Q,false);
                        if XcorrectNombre(Ps.x) then begin
                           lblText := formatMonde(j*dix(i));
                           lblW := Canvas.TextWidth(lblText)+6;
                           lblH := Canvas.TextHeight(lblText)+4;
                           curRect := TRectF.Create(Ps.x-lblW/2, drawY, Ps.x+lblW/2, drawY+lblH);
                           if ((not hasLast) or (not TickRectsOverlap(curRect, lastRect, MinTickLabelGap))) and
                              ((not hasNextMajor) or (not TickRectsOverlap(curRect, nextMajorRect, MinTickLabelGap))) then begin
                              MyDrawText(TpointF.create(Ps.x,drawY),lblText);
                              lastRect := curRect;
                              hasLast := True;
                           end;
                        end;
                     end // intermediaire
              else graduationX(Ps,false,false);
       end;{for j}
   end; {for i}
   CreatePen(TStrokeDash.Solid,penWidthAxe,CouleurAxeX);
   with limiteFenetre do segmentXY(left,yAxeX,right,yAxeX);
   except
       verifierLog := true;
   end;
end end;// TraceAxeLogx

procedure traceAxeLogY(m : indiceMonde);
var i,j : integer;
    ysuc,drawX,lblW,lblH : single;
    Ps : TpointF;
    intermediaire,intermediaire25,Q,hasLast,hasNextMajor,isRightAxis : boolean;
    lastRect, curRect, nextMajorRect : TRectF;
    lblText, nextText : string;
begin with monde[m] do begin
   try
   Q := (OgQuadrillage in OptionGraphe) and (m=mondeY) and initialisation;
   Intermediaire := (Maxi-Mini) <= 4;
   Intermediaire25 := (Maxi-Mini) <= 6;
   hasLast := False;
   isRightAxis := (m=mondeDroit) and not(OgAnalyseurLogique in OptionGraphe);
   drawX := xAxeY+2.5*signeMargeX*marge;
   for i := floor(Mini) to ceil(Maxi) do begin
       windowXY(monde[mondeX].Mini,i,m,Ps);
       if YcorrectGrad(Ps.y,m) then begin
            graduationY(Ps.y,Q,true);
            if YcorrectNombre(Ps.y,m) then begin
               lblText := formatMonde(dix(i));
               lblW := Canvas.TextWidth(lblText)+6;
               lblH := Canvas.TextHeight(lblText)+4;
               if isRightAxis
                  then curRect := TRectF.Create(drawX, Ps.y-lblH/2, drawX+lblW, Ps.y+lblH/2)
                  else curRect := TRectF.Create(drawX-lblW, Ps.y-lblH/2, drawX, Ps.y+lblH/2);
               if (not hasLast) or (not TickRectsOverlap(curRect, lastRect, MinTickLabelGap)) then begin
                  MyDrawText(TpointF.create(drawX,Ps.y),lblText);
                  lastRect := curRect;
                  hasLast := True;
               end;
            end;
       end;
       windowXY(monde[mondeX].Mini,succ(i),m,Ps);
       ysuc := Ps.y;
       hasNextMajor := YcorrectGrad(ysuc,m) and YcorrectNombre(ysuc,m);
       if hasNextMajor then begin
          nextText := formatMonde(dix(succ(i)));
          lblW := Canvas.TextWidth(nextText)+6;
          lblH := Canvas.TextHeight(nextText)+4;
          if isRightAxis
             then nextMajorRect := TRectF.Create(drawX, ysuc-lblH/2, drawX+lblW, ysuc+lblH/2)
             else nextMajorRect := TRectF.Create(drawX-lblW, ysuc-lblH/2, drawX, ysuc+lblH/2);
       end;
       for j := 2 to 9 do begin
            windowXY(monde[mondeX].Mini,i+log10(j),m,Ps);
            if YcorrectGrad(Ps.y,m) then
              if intermediaire or (intermediaire25 and ((j=2) or (j=4) or (j=8)))
                then begin
                    graduationY(Ps.y,Q,false);
                    if YcorrectNombre(Ps.y,m) then begin
                       lblText := formatMonde(j*dix(i));
                       lblW := Canvas.TextWidth(lblText)+6;
                       lblH := Canvas.TextHeight(lblText)+4;
                       if isRightAxis
                          then curRect := TRectF.Create(drawX, Ps.y-lblH/2, drawX+lblW, Ps.y+lblH/2)
                          else curRect := TRectF.Create(drawX-lblW, Ps.y-lblH/2, drawX, Ps.y+lblH/2);
                       if ((not hasLast) or (not TickRectsOverlap(curRect, lastRect, MinTickLabelGap))) and
                          ((not hasNextMajor) or (not TickRectsOverlap(curRect, nextMajorRect, MinTickLabelGap))) then begin
                          MyDrawText(TpointF.create(drawX,Ps.y),lblText);
                          lastRect := curRect;
                          hasLast := True;
                       end;
                    end;
                end
                else graduationY(Ps.y,false,false);
       end;{for j}
   end; {for i}
   CreatePen(TStrokeDash.Solid,penWidthAxe,CouleurAxeY);
   segmentXY(xAxeY,CourbeBottom,xAxeY,CourbeTop);
   if avecAxeY then begin // flèche Y
       segmentXY(xAxeY-marge,courbeTop+3*marge,xAxeY,courbeTop);
       segmentXY(xAxeY+marge,courbeTop+3*marge,xAxeY,courbeTop);
   end;
   except
   verifierLog := true;
   end;
end end; // traceAxeLogY

  procedure zeroPolaire;
  var P0 : TPointF;
  begin with limiteFenetre do begin
      WindowXY(0,0,mondeY,P0);
      CreatePen(TstrokeDash.Solid,penWidthAxe,CouleurAxeX);
      segmentXY(P0.x,bottom,P0.x,top); // axe y
      segmentXY(left,P0.y,right,P0.y); // axe x
  end end; // zeroPolaire

  procedure zeroX;
  var P1 : TpointF;
  begin with monde[mondeX] do if graduation=gLin then begin
	  WindowXY(0,0,mondeY,P1);
	  if (P1.x>limiteCourbe.left) and (P1.x<limiteCourbe.right) then begin
	      CreatePen(TstrokeDash.Solid,penWidthAxe,CouleurAxeX);
              with limiteCourbe do begin
      	           segmentXY(P1.x,bottom,P1.x,top);
                        { fléche Y }
                   segmentXY(P1.x-marge,top+3*marge,P1.x,top);
                   segmentXY(P1.x+marge,top+3*marge,P1.x,top);
              end;
	  end;
  end end; // zeroX

 procedure zeroY(m : indiceMonde;avecFleche : boolean);
 var P1 : Tpointf;
     couleur : TAlphaColor;
 begin
     with monde[m] do if Graduation=gLin then begin
          windowXY(0,0,m,P1);
          if yCorrectGrad(P1.y,m) then begin
             if m=mondeY
                then couleur := CouleurAxeX
                else couleur := CouleurAxeY;
             CreatePen(TstrokeDash.Solid,penWidthAxe,Couleur);
             with limiteCourbe do begin
    	          segmentXY(left,P1.y,right,P1.y);
                if avecFleche then begin // fléche X
                   segmentXY(right-marge*3,P1.y+marge,right,P1.y);
                   segmentXY(right-marge*3,P1.y-marge,right,P1.y);
                end;   
            end;
         end
     end
end;// zeroY

var i : integer;
    m : indiceMonde;
    decalage : single;
    P0 : TpointF;
begin // DrawAxis
     penWidthAxe := 1.5;
     penWidthGrad := 1;
     if couleurGrille = TAlphaColor($FFE5E7EB)
        then couleurGrillePale := TAlphaColor($FFF3F4F6)
        else couleurGrillePale := getCouleurPale(couleurGrille);
     if courbes.count>0 then monde[mondeX].Axe := courbes[0].varX;
     mondeYseul := true;
     for i := 0 to pred(courbes.count) do with courbes[i] do begin
           if monde[iMondeC].Axe=nil then monde[iMondeC].Axe := varY;
           if iMondeC<>mondeY then begin
               mondeYseul := false;
               continue;
           end;
     end;
     mondeYseul := mondeYseul or (OgAnalyseurLogique in OptionGraphe);
     signeMargeX := -1;
     couleurAxeY := CouleurAxeX;
     GraduationYTrace := false;
     couleurTexte := CouleurAxeY;
     WindowXY(0,0,mondeY,P0);
     xAxeY := P0.x;
     yAxeX := P0.y;
     if not GraduationZeroX then xAxeY := limiteCourbe.left;
     if not GraduationZeroY then yAxeX := limiteCourbe.bottom;
     monde[mondeX].Ptitre.x := (limiteFenetre.right+limiteFenetre.left)/2;
     monde[mondeX].Ptitre.y := yAxeX+hautCarac+marge;
     for m := mondeY to high(indiceMonde) do begin
         monde[m].PTitre.x := limiteFenetre.left;
         monde[m].Ptitre.y := (limiteFenetre.Top+limiteFenetre.bottom)/2;
     end;
     if not (OgAnalyseurLogique in OptionGraphe) then
         monde[mondeDroit].Ptitre.x := limiteFenetre.right-hautCarac-marge;
     if (OgAnalyseurLogique in OptionGraphe) and
        not superposePage then
        for m := mondeY to high(indiceMonde) do
            monde[m].PTitre.y := (monde[m].CourbeTop+monde[m].CourbeBottom)/2;
     if (OgPolaire in OptionGraphe) then begin
        monde[mondeY].Ptitre.x := limiteCourbe.right;
        WindowXY(0,0,mondeY,P0);
        monde[mondeY].Ptitre.y := P0.y;
        if avecAxeX then tracePolaire else zeroPolaire;
        exit;
     end;
     CreatePen(TStrokeDash.Solid, 1, CouleurCadre);
     if OgAnalyseurLogique in OptionGraphe then begin
        for m := mondeY to high(indiceMonde) do
           if monde[m].defini then
              MyDrawRectXY(limiteCourbe.Left, monde[m].CourbeTop,
                           limiteCourbe.Right, monde[m].CourbeBottom);
     end
     else
        MyDrawRect(limiteCourbe);
     initAxeX;
     if avecAxeX then begin
        if monde[mondeX].Graduation=gLog
           then traceAxeLogX
           else traceAxeX;
        if monde[mondeX].axe=nil then zeroX;
     end;
     if monde[mondeY].defini then begin
        i := 0;
        while (i<courbes.count) and
              (courbes[i].iMondeC<>mondeY) do inc(i);
        if i=courbes.count
           then monde[mondeY].defini := false
           else begin
             initAxeY(mondeY,i);
             if avecAxeY then begin
                case monde[mondeY].Graduation of
                   gLog : traceAxeLogY(mondeY);
                   else traceAxeY(mondeY);
                end;
                zeroY(mondeY,false);
             end
             else zeroY(mondeY,true);
           end;
     end;
     if (OgPseudo3D in OptionGraphe) then begin
          WindowXY(0,0,MondeY,P0);
          decalage := decalageFFT*(courbes.count-1);
          segmentXY(P0.x,P0.y,P0.x+decalage,P0.y-decalage); // ligne de base
     end;
     if monde[mondeDroit].defini then begin
           if not(OgAnalyseurLogique in OptionGraphe) then begin
              xAxeY := limiteCourbe.right;
              signeMargeX := +1;
           end;
           i := 0;
           while (i<courbes.count) and
                 (courbes[i].iMondeC<>mondeDroit) do inc(i);
           if i=courbes.count
              then monde[mondeDroit].defini := false
              else begin
                 initAxeY(mondeDroit,i);
                 if avecAxeY
                    then begin
                      if monde[mondeDroit].Graduation=gLog
                         then traceAxeLogY(mondeDroit)
                         else traceAxeY(mondeDroit);
                      zeroY(mondeDroit,false);
                    end
                    else zeroY(mondeDroit,true);
              end;
     end;
     if OgAnalyseurLogique in OptionGraphe then
        for m := mondeSans to high(indiceMonde) do with monde[m] do
            if monde[m].defini then begin
                   i := 0;
                   while (i<courbes.count) and
                         (courbes[i].iMondeC<>m) do inc(i);
                   if i=courbes.count
                      then monde[m].defini := false
                      else begin
                   initAxeY(m,i);
                   if avecAxeY
                      then begin
                        case monde[m].Graduation of
                          gLog : traceAxeLogY(m);
                          else traceAxeY(m);
                        end;
                        segmentXY(limiteCourbe.left,courbeBottom,limiteCourbe.right,courbeBottom);
                     end
                     else zeroY(m,true);
                   end;
           end;
     SetTextAlign(TTextAlign.leading,TTextAlign.leading);
end; // DrawAxis

