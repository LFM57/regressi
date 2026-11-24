// equival.pas = include graphker

procedure TgrapheReg.traceUneCourbe(xvecteur,yvecteur : vecteur;N,Neq : integer;AColor : TAlphaColor);
var i,j : integer;
     P : TPointF;
     pointOK : boolean;
     Fpath : TPathData;
begin
     createPen(TStrokeDash.Solid,penWidth,Acolor);
     FPath := TPathData.Create;
     i := 0;
     repeat
        windowXY(xvecteur[i],yvecteur[i],mondeY,P);
        pointOK := (P.x>0) and (P.y>0);
        if not pointOK then inc(i);
     until pointOK or (i=(N-1));
     FPath.MoveTo(P);
     for j := i+1 to pred(N) do begin
        windowXY(xvecteur[j],yvecteur[j],mondeY,P);
        if (P.x>0) and (P.y>0) then FPath.LineTo(P);
     end;
     Canvas.DrawPath(FPath, 1);
     FPath.free;
end;

Procedure Tequivalence.Paint;
var pointEq, point1, point2 : TPointF;
    FontSizeEquiv, oldFontSize : single;

Procedure TraceDroite(x, y, pente: double; xMin, yMin, xMax, Ymax: double);
const largeur = 8;
var
   x1,x2,K : double;
   dx,dy : Integer;
begin with agraphe do begin
    if pente=0
       then begin
          x1 := xMin;
          x2 := xMax;
       end
       else begin
          try
          if pente>0
             then begin
                x1 := ve+(yMin-pHe)/pente;
                x2 := ve+(yMax-pHe)/pente;
             end
             else begin
                x1 := ve+(yMax-pHe)/pente;
                x2 := ve+(yMin-pHe)/pente;
             end;
         if x1<xMin then x1 := xMin;
         if x2>xMax then x2 := xMax;
         except
             x1 := xMin;
             x2 := xMax;
         end;
    end;
    windowXY(x1,y+pente*(x1-x),agraphe.MondeDerivee,point1);
    windowXY(x2,y+pente*(x2-x),agraphe.MondeDerivee,point2);
    segment(point1,point2);
    try
    if abs(point2.x-point1.x)>abs(point2.y-point1.y)
      then begin
           K := (point2.y-point1.y)/(point2.x-point1.x);
           dy := round(largeur/sqrt(1+K*K));
           dx := -round(K*dy);
      end
      else begin
           K := (point2.x-point1.x)/(point2.y-point1.y);
           dx := round(largeur/sqrt(1+K*K));
           dy := -round(K*dx);
      end;
    windowXY(x,y,agraphe.MondeDerivee,point2);
    segmentXY(point2.x+dx,point2.y+dy,point2.x-dx,point2.y-dy);
    except
    end;
end end;

procedure ChercheEquivalence(veAp,pheAp : double);

function ChercheEqui(i : integer) : boolean;
var v3,pH3,penteCourbe : double;
// intersection droite (veeAp pHeAp penteTg) et (v3 ph3 penteCourbe)
begin
     penteCourbe :=
        (aGraphe.monde[MondeY].axe.valeur[succ(i)]-aGraphe.monde[mondeY].axe.valeur[i])/
        (aGraphe.monde[mondeX].axe.valeur[succ(i)]-aGraphe.monde[mondeX].axe.valeur[i]);
     v3 := aGraphe.monde[mondeX].axe.valeur[i];
     ph3 := agraphe.monde[mondeY].axe.valeur[i];
     ve := (pH3-penteCourbe*v3-pHeAp+pente*veAp)/(pente-penteCourbe);
     pHe := pH3+penteCourbe*(ve-v3);
     result := ((ve-agraphe.monde[mondeX].axe.valeur[succ(i)])*
               (ve-agraphe.monde[mondeX].axe.valeur[i])<=0) and
               ((phe-agraphe.monde[mondeY].axe.valeur[succ(i)])*
               (phe-agraphe.monde[mondeY].axe.valeur[i])<=0);
end; // ChercheEqui

var imax,i : integer;
    trouve : boolean;
begin  // ChercheEquivalence
     i := index1;
     imax := index2;
     if imax<i then swap(i,imax);
     repeat
        trouve := ChercheEqui(i);
// result si vee entre les deux points
        if not trouve then inc(i);
     until trouve or (i>iMax);
     if not trouve then begin
        ve := veAp;
        phe := pheAp;
     end;
end; // ChercheEquivalence

procedure AffineEquivalence;
var xvecteur1,yvecteur1,derivee1,xvecteur2,yvecteur2,derivee2 : vecteur;
    i,N2,N2Modele : integer;
    nbrePointDeriveeL : integer;
    ecart,ecartRef : double;
    ecartGrand : boolean;

function chercheInflexion : boolean;
var i : integer;
    ecart,ecartRef : double;
    indexInflexion : integer;
    Neq : integer;
begin
      ecartRef := abs(ve-agraphe.monde[mondeX].axe.valeur[index1]);
      indexInflexion := (index1+index2) div 2;
      for i := index1+1 to index2 do begin
          ecart := abs(ve-agraphe.monde[mondeX].axe.valeur[i]);
          if ecart<ecartRef then begin
             indexInflexion := i;
             ecartRef := ecart;
          end;
      end;
      result := modeleInflexion(agraphe.monde[mondepH].axe.valeur,
                 agraphe.monde[mondeX].axe.valeur,
                 indexInflexion,yvecteur2,xvecteur2,ve,phe,pente);
      if result then begin
         Neq := 0;
         ecartRef := abs(yvecteur2[0]-phe);
         for i := 1 to pred(NbrePointDeriveeLisse) do begin
            ecart := abs(yvecteur2[i]-phe);
            if ecart<ecartRef then begin
               ecartRef := ecart;
               Neq := i;
            end;
         end;
         agraphe.traceUneCourbe(xvecteur2,yvecteur2,NbrePointDeriveeLisse,Neq,claSilver);
      end;
end;

procedure chercheApres(ii : integer);
var i : integer;
    ecart,ecartRef : double;
begin
      DeriveeLisse(agraphe.monde[mondeX].axe.valeur,
                   agraphe.monde[mondepH].axe.valeur,
                   nbrePointDeriveeL,
                   ii,xvecteur2,yvecteur2,derivee2);
       N2 := 0;
       ecartRef := abs(derivee2[0]-pente);
       for i := 1 to pred(NbrePointDeriveeLisse) do begin
          ecart := abs(derivee2[i]-pente);
          if ecart<ecartRef then begin
             ecartRef := ecart;
             N2 := i;
          end;
       end;
       ecartGrand := (ecartRef/abs(pente))>0.1;
end;

function chercheApresModele(ii : integer;penteModele : double) : boolean;
var i : integer;
    ecart,ecartRef : double;
begin
       N2modele := 0;
       ecartRef := abs(modeleApres.yder[0]-penteModele);
       for i := 1 to pred(NbrePointDeriveeLisse) do begin
          ecart := abs(modeleApres.yder[i]-penteModele);
          if ecart<ecartRef then begin
             ecartRef := ecart;
             N2modele := i;
          end;
       end;
       result := (ecartRef/abs(pente))<0.1;
end;

function modeliseEquivalenceAvant(index : integer) : boolean;
begin with modeleAvant do begin
   debut := index-(nbrePointDeriveeL div 2);
   fin := index+(nbrePointDeriveeL div 2);
   if pente<0 then signe := -1 else signe := 1;
   valeurParam[2] := agraphe.monde[mondeX].axe.valeur[fin+1];
   valeurParam[1] := agraphe.monde[mondepH].axe.valeur[index];
   indexX := indexNom(agraphe.monde[mondeX].axe.nom);
   indexY := indexNom(agraphe.monde[mondepH].axe.nom);
   result := EffectueModeleNum;
end end;

function modeliseEquivalenceApres(index : integer) : boolean;
begin with modeleApres do begin
   debut := index-(nbrePointDeriveeL div 2);
   fin := index+(nbrePointDeriveeL div 2);
   if pente<0 then signe := -1 else signe := 1;
   valeurParam[2] := agraphe.monde[mondeX].axe.valeur[debut-1];
   valeurParam[1] := agraphe.monde[mondepH].axe.valeur[index];
   indexX := indexNom(agraphe.monde[mondeX].axe.nom);
   indexY := indexNom(agraphe.monde[mondepH].axe.nom);
   result := EffectueModeleNum;
end end;

begin
    NbrePointDeriveeL := 2*(index2 - index1) div 3;
    if not odd(NbrePointDeriveeL) then inc(NbrePointDeriveeL);
    if NbrePointDeriveeL<3 then NbrePointDeriveeL := 3;
    if NbrePointDeriveeL>7 then NbrePointDeriveeL := 7;
    DeriveeLisse(agraphe.monde[mondeX].axe.valeur,
                 agraphe.monde[mondepH].axe.valeur,
                 nbrePointDeriveeL,
                 index1,xvecteur1,yvecteur1,derivee1);
    DeriveeLisse(agraphe.monde[mondeX].axe.valeur,
                 agraphe.monde[mondepH].axe.valeur,
                 nbrePointDeriveeL,
                 index2,xvecteur2,yvecteur2,derivee2);
    pente := derivee1[NbrePointDeriveeLisse div 2];
    x1 := xvecteur1[NbrePointDeriveeLisse div 2];
    y1 := yvecteur1[NbrePointDeriveeLisse div 2];
    N2 := NbrePointDeriveeLisse div 2;
    ecartRef := 2*abs(pente);
    for i := 0 to pred(NbrePointDeriveeLisse) do begin
        ecart := abs(derivee2[i]-pente);
        if ecart<ecartRef then begin
           ecartRef := ecart;
           N2 := i;
        end;
    end;
    x2 := xvecteur2[N2];
    y2 := yvecteur2[N2];
    ve := (x1+x2)/2;
    pHe := (y1+y2)/2;
    ChercheEquivalence(ve,phe);
    agraphe.traceUneCourbe(xvecteur1,yvecteur1,NbrePointDeriveeLisse,N2Modele,claBlue);
    agraphe.traceUneCourbe(xvecteur2,yvecteur2,NbrePointDeriveeLisse,N2Modele,claBlue);
end;

procedure traceTexteX;
var L,H : single;
    P : TPointF;
begin with agraphe do begin
   L := Canvas.TextWidth(TexteX);
   H := Canvas.TextHeight(TexteX);
   P := TpointF.create(pointEq.x,limiteCourbe.bottom-3); // -3 pour ne pas écrire sur l'axe
   P.offset(-L/2,-H);
   MyFillText(P,TexteX,FondReticule);
end end;

procedure traceTexteY;
var H : single;
    P : TPointF;
begin with agraphe do begin
   H := Canvas.TextHeight(TexteY);
   P := TpointF.create(limiteCourbe.left+3,pointEq.y);
   P.Offset(0,-H/2);
   MyFillText(P,TexteY,FondReticule);
end end;

procedure traceTextePente;
var L,H : single;
    P : TPointF;
begin
   L := agraphe.Canvas.TextWidth(TextePente);
   H := agraphe.Canvas.TextHeight(TextePente);
   P := TpointF.create((point1.x+point2.x)/2,(point1.y+point2.y)/2);
   P.Offset(-L/2,-H/2);
   Agraphe.MyDrawText(P,TextePente);
end;

const dimEq = 3;
var ecart,x3,x4,y3,y4 : double;
    posTrait,deltax,deltay : single;
    signe : integer;
begin // equivalence.paint
with agraphe do begin
      point1 := TPointF.create(0,0);
      point2 := TPointF.create(0,0);
      pointeq := TPointF.create(0,0);
      oldFontSize := canvas.font.size;
      FontSizeEquiv := oldFontSize*3/2;
      canvas.font.size := FontSizeEquiv;
      layout.font.size := FontSizeEquiv;
      if lrEquivalence in LigneRappel then begin
             if not modelisee then affineEquivalence;
             createPen(styleTangente,1,couleurTangente);
             WindowRT(ve,pHe,mondepH,pointeq);
             windowXY(x1,y1,MondepH,point1);
             windowXY(x2,y2,MondepH,point2);
             x3 := ve-abs(x2-x1);
             x4 := ve+abs(x2-x1);
             y3 := pHe-abs(y2-y1);
             y4 := pHe+abs(y2-y1);
             agraphe.WindowRT(ve,pHe,MondepH,pointeq);
             segmentXY(pointeq.x,limiteCourbe.bottom,pointeq.x,pointeq.y);// ligne de rappel v eq
             segmentXY(limiteCourbe.left,pointeq.y,pointeq.x,pointeq.y); // ligne de rappel pH eq

             CreatePen(TStrokeDash.Dot,1,couleurTangente);
             traceDroite(x1,y1,pente,x3,y3,x4,y4);
             traceDroite(x2,y2,pente,x3,y3,x4,y4);
             CreatePen(TStrokeDash.Solid,1,couleurTangente);
             traceDroite(ve,pHe,pente,x3,y3,x4,y4);

             traceTexteX;
             traceTexteY;
      end;
      if lrTangente in LigneRappel then begin
             createPen(styleTangente,1,couleurTangente);
             ecart := (agraphe.monde[mondeX].maxi - monde[mondeX].mini)*LongueurTangente;
             x3 := ve+ecart;
             if x3>agraphe.monde[mondeX].maxi then x3 := monde[mondeX].maxi;
             x4 := ve-ecart;
             if x4<agraphe.monde[mondeX].mini then x4 := monde[mondeX].mini;
             ecart := (agraphe.monde[MondepH].maxi - monde[MondepH].mini)*LongueurTangente;
             y3 := pHe+ecart;
             if y3>agraphe.monde[mondepH].maxi then y3 := monde[mondepH].maxi;
             y4 := pHe-ecart;
             if y4<agraphe.monde[mondepH].mini then y4 := monde[mondepH].mini;
             traceDroite(ve,pHe,pente,x4,y4,x3,y3);
             traceTextePente;
      end;
      if [lrXdeY,lrReticule]*ligneRappel<>[] then begin
            createPen(styleTangente,1,couleurReticule);
            WindowRT(ve,pHe,mondepH,pointeq);
            segment(pointeq,TpointF.create(pointeq.x,limiteCourbe.bottom));
            case mondepH of
                 mondeY : segment(TpointF.create(limiteCourbe.left,pointeq.y),pointeq);
                 mondeDroit : segment(TpointF.create(limiteCourbe.right,pointeq.y),pointeq);
            end;
            traceTexteX;
            traceTexteY;
      end;
      if lrX in ligneRappel then begin
            createPen(styleTangente,1,couleurReticule);
            WindowRT(x1,y1,mondepH,point1);
            WindowRT(x2,y2,mondepH,point2);
            CreatePen(TStrokeDash.Solid,1,claBlue);
            posTrait := limiteCourbe.top + hautCarac/2;
            SegmentXY(point1.x,posTrait,point2.x,posTrait);
            // fléches
            if point1.x < point2.x
               then signe := 1
               else signe := -1;
            deltax := marge*signe*3;
            deltay := marge;
            SegmentXY(point1.x + deltax, posTrait + deltay,
                      point1.x, posTrait);
            SegmentXY(point1.x + deltax, posTrait - deltay,
                      point1.x, posTrait);
            signe := -signe;
            deltax := agraphe.marge*signe*3;
            SegmentXY(point2.x + deltax, posTrait + deltay,
                      point2.x, posTrait);
            SegmentXY(point2.x + deltax, posTrait - deltay,
                      point2.x, posTrait);
            agraphe.CreatePen(TStrokeDash.Dash,1,claBlue);
            SegmentXY(point1.x,limiteCourbe.bottom,
                      point1.x,posTrait);
            SegmentXY(point2.x,limiteCourbe.bottom,
                      point2.x,posTrait);
            traceTexteX;
       end;
       if lrY in ligneRappel then begin
            CreatePen(styleTangente,1,couleurReticule);
            WindowRT(x1,y1,mondepH,point1);
            WindowRT(x2,y2,mondepH,point2);
            CreatePen(TStrokeDash.Solid,1,claBlue);
            posTrait := limiteCourbe.right - 4*largCarac;
            SegmentXY(posTrait,point1.y,posTrait,point2.y);
            // fléches
            if point1.y < point2.y
               then signe := 1
               else signe := -1;
            deltay := marge*signe*3;
            deltax := marge;
            SegmentXY(posTrait - deltax, point1.y + deltay,
                      posTrait, point1.y);
            SegmentXY(posTrait + deltax, point1.y + deltay,
                      posTrait, point1.y);
            signe := -signe;
            deltay := agraphe.marge*signe*3;
            SegmentXY(posTrait - deltax, point2.y + deltay,
                      posTrait, point2.y);
            SegmentXY(posTrait + deltax, point2.y + deltay,
                      posTrait, point2.y);
            CreatePen(TstrokeDash.Dash,1,claBlue);
            SegmentXY(agraphe.limiteCourbe.left,point1.y,posTrait,point1.y);
            SegmentXY(agraphe.limiteCourbe.left,point2.y,posTrait,point2.y);
            traceTexteY;
       end;
       if lrPente in ligneRappel then begin
            CreatePen(styleTangente,1,couleurReticule);
            WindowRT(x1,y1,mondepH,point1);
            WindowRT(x2,y2,mondepH,point2);
            SegmentXY(point1.x, point1.y,point2.x, point2.y);
            traceTextePente;
       end;
       canvas.font.size := oldFontSize;
       layout.font.size := oldFontSize;
end end; // equivalence.paint

constructor Tequivalence.CreateEq(v1,ph1,v2,ph2,v,ph,p : double;c : integer;gr : TgrapheReg);
begin
     agraphe := gr;
     ve := v;
     phe := pH;
     pente := p;
     x2 := v2;
     y2 := ph2;
     x1 := v1;
     y1 := ph1;
     mondepH := mondeY;
     varY := nil;
     couleur := CouleurPages[c mod NbreCouleur];
     modelisee := false;
end;

constructor Tequivalence.Create(gr : TgrapheReg);
begin
     agraphe := gr;
end;

Procedure TgrapheReg.AjouteEquivalence(i : integer;effaceDouble : boolean);
var penteTg,v11,vee,phee,ph11,v22,ph22 : double;
    codeDerivee : integer;
    IsModelisee : boolean;
    i2 : integer;

Function ChercheVpHModele : boolean;
var veAp,pHeAp : double;

procedure ChercheEqui(i : integer);
var v3,pH3,penteCourbe : double;
// intersection droite (veeAp pHeAp pentetg) et (v3 ph3 pentecourbe)
begin with courbes[indexCourbeEquivalence] do begin
     penteCourbe :=
        (valY[succ(i)]-valY[i])/
        (valX[succ(i)]-valX[i]);
     v3 := valX[i];
     ph3 := valY[i];
     vee := (pH3-penteCourbe*v3-pHeAp+penteTg*veAp)/(penteTg-penteCourbe);
     pHee := pH3+penteCourbe*(vee-v3);
end end; // ChercheEqui

var i3,i3ap,iprec,isuiv : integer;
    derRef : double;
    k,kmax : integer;
    VcroissantSelonI,Croissant : boolean;
begin with courbes[indexCourbeEquivalence] do begin
     result := false;
     vee := monde[mondeX].Maxi;
     penteTg := valYder[i];
     derRef := abs(penteTg);
     i2 := i;
     croissant := true;
     iprec := i2-2;
     if iprec<0 then iprec := 0;
     isuiv := i2+2;
     if isuiv>finc then isuiv := finc;
     VcroissantSelonI := valX[isuiv]>valX[iprec];
     repeat inc(i2)
     until (i2>=finC) or
           (abs(valYder[i2])>(derRef*1.25)); // un peu d'hystérèsis
     if i2>=finC then begin
        croissant := false;
        i2 := i;
        repeat dec(i2)
        until (i2<0) or
              (abs(valYder[i2])>derRef);
        if i2<0 then exit;
        repeat dec(i2);
        until (i2<0) or
               (abs(valYder[i2])<derRef);
        if i2<0 then exit;
     end
     else begin
         repeat inc(i2);
         until (i2>finC) or
          (abs(valYder[i2])<derRef);
         if i2>=finC then exit;
     end;
     if not croissant then swap(i,i2);
// i2 : point après l'équivalence de même pente
     v11 := valX[i];
     ph11 := valY[i];
     v22 := valX[i2];
     ph22 := valY[i2];
{ valeur approchée de ve pHe }
     veAp := (v11+v22)/2;
     pHeAp := (pH11+pH22)/2;
{ cherche intersection avec courbe }
     i3 := i;
     repeat
       inc(i3)
     until (valX[i3]>veAp) or (i3>i2); // hypothèse VcroissantSelonI
     i3ap := i3;
     k := 0;
     kmax := (i2-i) div 2;
     if kmax>32 then kmax := 32;
     repeat
        inc(k);
        chercheEqui(i3);
        result := (vee-valX[succ(i3)])*
                  (vee-valX[i3])<=0;
{ result si vee entre les deux points }
        if not Result then begin
           if vee>valX[i3]
              then if VcroissantSelonI then inc(i3) else dec(i3)
              else if VcroissantSelonI then dec(i3) else inc(i3);
        end;
     until result or (k>kmax) or (i3>i2) or (i3<i);
     if not result then chercheEqui(i3Ap);
// on remet à la valeur approchée la plus raisonnable
     result := (vee<monde[mondeX].maxi) and (vee>monde[mondeX].mini);
end end; // ChercheVpHmodele

Function ChercheVpH : boolean;
var veAp,pHeAp : double;

procedure ChercheEqui(i : integer);
var v3,pH3,penteCourbe : double;
// intersection droite (veeAp pHeAp pentetg) et (v3 ph3 pentecourbe)
begin
     penteCourbe :=
        (monde[MondeY].axe.valeur[succ(i)]-monde[mondeY].axe.valeur[i])/
        (monde[mondeX].axe.valeur[succ(i)]-monde[mondeX].axe.valeur[i]);
     v3 := monde[mondeX].axe.valeur[i];
     ph3 := monde[mondeY].axe.valeur[i];
     vee := (pH3-penteCourbe*v3-pHeAp+penteTg*veAp)/(penteTg-penteCourbe);
     pHee := pH3+penteCourbe*(vee-v3);
end;// ChercheEqui

var i3,iprec,isuiv : integer;
    derRef : double;
    k,kmax : integer;
    VcroissantSelonI,Croissant : boolean;
begin
     result := false;
     vee := monde[mondeX].Maxi;
     penteTg := grandeurs[codeDerivee].valeur[i];
     derRef := abs(penteTg);
     i2 := i;
     croissant := true;
     iprec := i2-2;
     if iprec<0 then iprec := 0;
     isuiv := i2+2;
     if isuiv>=pages[pageCourante].nmes
        then isuiv := pred(pages[pageCourante].nmes);
     with monde[mondeX].axe do VcroissantSelonI :=
          valeur[isuiv]>valeur[iprec];
     repeat inc(i2)
     until (i2>=pages[pageCourante].nmes) or
           (abs(grandeurs[codeDerivee].valeur[i2])>derRef);
     if i2>=pages[pageCourante].nmes then begin
        croissant := false;
        i2 := i;
        repeat dec(i2)
        until (i2<0) or
              (abs(grandeurs[codeDerivee].valeur[i2])>derRef);
        if i2<0 then exit;
        repeat dec(i2);
        until (i2<0) or
               (abs(grandeurs[codeDerivee].valeur[i2])<derRef);
        if i2<0 then exit;
     end
     else begin
         repeat inc(i2);
         until (i2>=pages[pageCourante].nmes) or
          (abs(grandeurs[codeDerivee].valeur[i2])<derRef);
         if i2>=pages[pageCourante].nmes then exit;
     end;
     if not croissant then swap(i,i2);
// i2 : point après l'équivalence de même pente 
     v11 := monde[mondeX].axe.valeur[i];
     ph11 := monde[mondeY].axe.valeur[i];
     v22 := monde[mondeX].axe.valeur[i2]+(penteTg-grandeurs[codeDerivee].valeur[i2])*
        (monde[mondeX].axe.valeur[i2]-monde[mondeX].axe.valeur[pred(i2)])/
        (grandeurs[codeDerivee].valeur[i2]-grandeurs[codeDerivee].valeur[pred(i2)]);
     ph22 := monde[mondeY].axe.valeur[i2]+(v22-monde[mondeX].axe.valeur[i2])*
        (monde[mondeY].axe.valeur[i2]-monde[mondeY].axe.valeur[pred(i2)])/
        (monde[mondeX].axe.valeur[i2]-monde[mondeX].axe.valeur[pred(i2)]);
// valeur approchée de ve pHe
     veAp := (v11+v22)/2;
     pHeAp := (pH11+pH22)/2;
// cherche intersection avec courbe
     i3 := (i+i2) div 2;
     k := 0;
     kmax := abs(i3-i2);
     if kmax>16 then kmax := 16;
     repeat
        inc(k);
        chercheEqui(i3);
        result := (vee-monde[mondeX].axe.valeur[succ(i3)])*
                  (vee-monde[mondeX].axe.valeur[i3])<=0;
// result si vee entre les deux points
        if not Result then begin
           if vee>monde[mondeX].axe.valeur[i3]
               then if VcroissantSelonI then inc(i3) else dec(i3)
               else if VcroissantSelonI then dec(i3) else inc(i3);
        end;
     until result or (k>kmax) or (i3>i2) or (i3<i);
     if not result then chercheEqui((i+i2) div 2);
// on remet à la valeur approchée la plus raisonnable
     result := (vee<monde[mondeX].maxi) and (vee>monde[mondeX].mini);
end; // ChercheVpH

Procedure CherchePente;
begin
    if IsModelisee
        then begin
           vee := courbes[indexCourbeEquivalence].valX[i];
           pHee := courbes[indexCourbeEquivalence].valY[i];
           penteTg := courbes[indexCourbeEquivalence].valYder[i];
        end
        else begin
           vee := monde[mondeX].axe.valeur[i];
           pHee := monde[mondeDerivee].axe.valeur[i];
           penteTg := Grandeurs[codeDerivee].valeur[i];
        end;
     v11 := vee;
     v22 := vee;
     pH11 := pHee;
     pH22 := pHee;
end; // CherchePente

var t : integer;
    NewEquivalence : Tequivalence;
    dx,dy : double;
    NMax : integer;
begin // AjouteEquivalence
     codeDerivee := indexDerivee(monde[mondeDerivee].axe,monde[mondeX].axe,true,true);
     if codeDerivee=grandeurInconnue then exit;
     IsModelisee := not(courbes[indexCourbeEquivalence].courbeExp) and
                    ((courbes[indexCourbeEquivalence].indexModele=1) and
                     (courbes[indexCourbeEquivalence].valYder<>nil));
     case LigneRappelCourante of
          lrEquivalence : if IsModelisee
            then begin if not ChercheVpHModele then exit end
            else begin if not ChercheVpH then exit end;
          lrTangente : CherchePente;
     end;
     with monde[mondeX] do dx := (maxi-mini)/128; { +- 8 pixels sur 1024 }
     with monde[mondeDerivee] do dy := (maxi-mini)/128;
     for t := 0 to Pred(equivalences[pageCourante].count) do
         with equivalences[pageCourante].items[t] do begin
             if varY=nil then varY := monde[mondeY].axe;
             if (abs(x1-monde[mondeX].axe.valeur[i])<dx) and
                (abs(y1-varY.valeur[i])<dy) then begin
                  if effaceDouble then begin
                     Draw;
                     equivalences[pageCourante].Delete(t);
                  end;
                  exit;
            end;
        end;
      NewEquivalence := Tequivalence.CreateEq(v11,ph11,v22,ph22,vee,phee,penteTg,pageCourante,self);
      NewEquivalence.index1 := i;
      NewEquivalence.index2 := i2;
      NewEquivalence.modelisee := IsModelisee;
      NewEquivalence.mondepH := mondeDerivee;
      NewEquivalence.ligneRappel := [ligneRappelCourante];
      equivalences[pageCourante].Add(NewEquivalence);
      equivalenceCourante := newEquivalence;
      Nmax := (NewEquivalence.index2 - NewEquivalence.index1) div 2;
      if not odd(Nmax) then inc(Nmax);
      if Nmax<3 then Nmax := 3;
      if NbrePointDerivee>Nmax then NbrePointDerivee := Nmax;
      if NbrePointDerivee=3 then NbrePointDerivee := Nmax;
    (*
         if NbrePointDerivee=3
            then degreDerivee := 1
            else if NbrePointDerivee=5
                then degreDerivee := 2
                else degreDerivee := 3;
                *)
end; // AjouteEquivalence

Procedure Tequivalence.SetValeurEquivalence(i : integer);
var codeDerivee : integer;
begin with Agraphe do begin
     if modelisee
        then begin
           ve := courbes[indexCourbeEquivalence].valX[i];
           pHe := courbes[indexCourbeEquivalence].valY[i];
           try
           pente := courbes[indexCourbeEquivalence].valYder[i];
           except
           pente := 0;
           modelisee := false;
           end;
        end
        else begin
           if varY=nil then varY := monde[mondeY].axe;
           codeDerivee := indexDerivee(varY,monde[mondeX].axe,true,true);
           ve := monde[mondeX].axe.valeur[i];
           pHe := varY.valeur[i];
           if codeDerivee=grandeurInconnue
             then pente := 0
             else pente := Grandeurs[codeDerivee].valeur[i];
        end;   
end end; // SetValeurEquivalence

Procedure Tequivalence.Store;
begin
  ecritFloatRW3(pente); {1}
  ecritFloatRW3(ve);{2}
  ecritFloatRW3(pHe);{3}
  ecritIntegerRW3(0);{4}
  ecritIntegerRW3(0);{5}
  ecritIntegerRW3(mondepH);{6}
  ecritIntegerRW3(ord(lrXdeY));{7} // à voir
  ecritIntegerRW3(ord(modelisee));{8}
  ecritLigneRW3U(commentaire);{9}
  ecritColorRW3(couleur);{10}
end;

Procedure Tequivalence.StoreXML(ANode : IXMLNOde);
begin
  writeFloatXML(ANode,'Pente',pente);
  writeFloatXML(ANode,'Ve',ve);
  writeFloatXML(ANode,'Phe',pHe);
  writeIntegerXML(ANode,'Index1',index1);
  writeIntegerXML(ANode,'Monde',mondepH);
  writeIntegerXML(ANode,'isRappel',byte(LigneRappel));
  writeBoolXML(ANode,'isModele',modelisee);
  writeStringXML(ANode,'Comment',commentaire);
  writeColorXML(ANode,'Couleur',couleur);
end;

Procedure Tequivalence.Load;
var i,imax : integer;
    zI : integer;
    zLong : longWord;
    aligne : TligneRappel;
begin
  imax := NbreLigneWin(ligneWin);
  pente := litFloatRW3; {1}
  ve := litFloatRW3; {2}
  Phe := litFloatRW3; {3}
  litLigneWin; {4}
  litLigneWin;{5}
  mondepH := litIntegerRW3;{6}
  zI := litIntegerRW3;{7}
  aLigne := TligneRappel(zI);
  ligneRappel := [aLigne];
  modelisee := litBooleanWin;{8}
  commentaire := litligneWinU;{9}
  litligneWin;
  try
  zLong := strToInt(ligneWin);
  couleur := intToColor(zLong);
  except
     couleur := claBlack;
  end;
  for i := 11 to imax do litLigneWin;
end;

Procedure Tequivalence.LoadXML(ANode : IXMLNOde);

procedure litEnfant(ANode : IXMLNOde);
var z : byte;
begin
    if ANode.NodeName='Pente' then begin
        pente := getFloatXML(Anode);
        exit;
    end;
    if ANode.NodeName='Ve' then begin
        ve := getFloatXML(Anode);
        exit;
    end;
    if ANode.NodeName='Index1' then begin
        index1 := getIntegerXML(Anode);
        exit;
    end;
    if ANode.NodeName='Phe' then begin
        Phe := getFloatXML(Anode);
        exit;
    end;
    if ANode.NodeName='Monde' then begin
        mondepH := getIntegerXML(Anode);
        exit;
    end;
    if ANode.NodeName='isRappel' then begin
        z := getIntegerXML(Anode);
        ligneRappel := TsetLigneRappel(z);
        exit;
    end;
    if ANode.NodeName='isModele' then begin
        modelisee := getBoolXML(Anode);
        exit;
    end;
    if ANode.NodeName='Comment' then begin
        commentaire := ANode.text;
        exit;
    end;
    if ANode.NodeName='Couleur' then begin
        couleur := getColorXML(Anode);
        exit;
    end;
end;

var i : integer;
begin
 if ANode.HasChildNodes then
      for I := 0 to ANode.ChildNodes.Count - 1 do
          LitEnfant(ANode.ChildNodes.Nodes[I]);
end;


function Tequivalence.textePente : string;
var dY,dX: double;
begin
    result := '';
    if x2 <> x1 then  begin
            Agraphe.setUnitePente(mondeY);
            with Agraphe.monde[mondeY] do
              case Graduation of
                gLog: dY := log10(y2 / y1);
                gLin: dY := y2 - y1;
                gdB: dY  := 20 * log10(y2 / y1);
                else dY := 0;
              end;
            with Agraphe.monde[mondeX] do
              case Graduation of
                gLog: dX := log10(x2 / x1);
                gLin: dX := x2 - x1;
                else dX := 1;
              end;
            result := Agraphe.unitePente.formatPente(dY / dX);
          end;
end;

Procedure Tequivalence.modifDerivee(aGraphe : TgrapheReg);
var codeDerivee : integer;
    IsModelisee : boolean;
    aCourbe : TCourbe;

Function ChercheVpHModele : boolean;
var veAp,pHeAp : double;

procedure ChercheEqui(i : integer);
var v3,pH3,penteCourbe : double;
// intersection droite (veeAp pHeAp pentetg) et (v3 ph3 pentecourbe)
begin with acourbe do begin
     penteCourbe :=
        (valY[succ(i)]-valY[i])/
        (valX[succ(i)]-valX[i]);
     v3 := valX[i];
     ph3 := valY[i];
     ve := (pH3-penteCourbe*v3-pHeAp+pente*veAp)/(pente-penteCourbe);
     pHe := pH3+penteCourbe*(ve-v3);
end end; // ChercheEqui

var i2,i3,i3ap,iprec,isuiv : integer;
    derRef : double;
    k,kmax : integer;
    VcroissantSelonI,Croissant : boolean;
begin with acourbe do begin
     result := false;
     ve := agraphe.monde[mondeX].Maxi;
     pente := valYder[index1];
     derRef := abs(pente);
     i2 := index1;
     croissant := true;
     iprec := i2-2;
     if iprec<0 then iprec := 0;
     isuiv := i2+2;
     if isuiv>finc then isuiv := finc;
     VcroissantSelonI := valX[isuiv]>valX[iprec];
     repeat inc(i2)
     until (i2>=finC) or
           (abs(valYder[i2])>(derRef*1.25)); // un peu d'hystérèsis
     if i2>=finC then begin
        croissant := false;
        i2 := index1;
        repeat dec(i2)
        until (i2<0) or
              (abs(valYder[i2])>derRef);
        if i2<0 then exit;
        repeat dec(i2);
        until (i2<0) or
               (abs(valYder[i2])<derRef);
        if i2<0 then exit;
     end
     else begin
         repeat inc(i2);
         until (i2>finC) or
          (abs(valYder[i2])<derRef);
         if i2>=finC then exit;
     end;
     if not croissant then swap(index1,i2);
// i2 : point après l'équivalence de même pente
     x1 := valX[index1];
     y1 := valY[index1];
     x2 := valX[i2];
     y2 := valY[i2];
// valeur approchée de ve pHe
     veAp := (x1+x2)/2;
     pHeAp := (y1+y2)/2;
// cherche intersection avec courbe
     i3 := index1;
     repeat
       inc(i3)
     until (valX[i3]>veAp) or (i3>i2); // hypothèse VcroissantSelonI
     i3ap := i3;
     k := 0;
     kmax := (i2-index1) div 2;
     if kmax>32 then kmax := 32;
     repeat
        inc(k);
        chercheEqui(i3);
        result := (ve-valX[succ(i3)])*
                  (ve-valX[i3])<=0;
// result si vee entre les deux points
        if not Result then begin
           if ve>valX[i3]
              then if VcroissantSelonI then inc(i3) else dec(i3)
              else if VcroissantSelonI then dec(i3) else inc(i3);
        end;
     until result or (k>kmax) or (i3>i2) or (i3<index1);
     if not result then chercheEqui(i3Ap);
// on remet à la valeur approchée la plus raisonnable
     result := (ve<aGraphe.monde[mondeX].maxi) and
               (ve>aGraphe.monde[mondeX].mini);
end end; // ChercheVpHmodele

Function ChercheVpH : boolean;
var veAp,pHeAp : double;

procedure ChercheEqui(i : integer);
var v3,pH3,penteCourbe : double;
// intersection droite (veeAp pHeAp pentetg) et (v3 ph3 pentecourbe)
begin
     penteCourbe :=
        (aGraphe.monde[MondeY].axe.valeur[succ(i)]-aGraphe.monde[mondeY].axe.valeur[i])/
        (aGraphe.monde[mondeX].axe.valeur[succ(i)]-aGraphe.monde[mondeX].axe.valeur[i]);
     v3 := aGraphe.monde[mondeX].axe.valeur[i];
     ph3 := agraphe.monde[mondeY].axe.valeur[i];
     ve := (pH3-penteCourbe*v3-pHeAp+pente*veAp)/(pente-penteCourbe);
     pHe := pH3+penteCourbe*(ve-v3);
end; // ChercheEqui

var i2,i3,iprec,isuiv : integer;
    derRef : double;
    k,kmax : integer;
    VcroissantSelonI,Croissant : boolean;
begin with agraphe do begin
     result := false;
     ve := monde[mondeX].Maxi;
     pente := grandeurs[codeDerivee].valeur[index1];
     derRef := abs(pente);
     i2 := index1;
     croissant := true;
     iprec := i2-2;
     if iprec<0 then iprec := 0;
     isuiv := i2+2;
     if isuiv>=pages[pageCourante].nmes
        then isuiv := pred(pages[pageCourante].nmes);
     with monde[mondeX].axe do VcroissantSelonI :=
          valeur[isuiv]>valeur[iprec];
     repeat inc(i2)
     until (i2>=pages[pageCourante].nmes) or
           (abs(grandeurs[codeDerivee].valeur[i2])>derRef);
     if i2>=pages[pageCourante].nmes then begin
        croissant := false;
        i2 := index1;
        repeat dec(i2)
        until (i2<0) or
              (abs(grandeurs[codeDerivee].valeur[i2])>derRef);
        if i2<0 then exit;
        repeat dec(i2);
        until (i2<0) or
               (abs(grandeurs[codeDerivee].valeur[i2])<derRef);
        if i2<0 then exit;
     end
     else begin
         repeat inc(i2);
         until (i2>=pages[pageCourante].nmes) or
          (abs(grandeurs[codeDerivee].valeur[i2])<derRef);
         if i2>=pages[pageCourante].nmes then exit;
     end;
     if not croissant then swap(index1,i2);
// i2 : point après l'équivalence de même pente
     x1 := monde[mondeX].axe.valeur[index1];
     y1 := monde[mondeY].axe.valeur[index1];
     x2 := monde[mondeX].axe.valeur[i2]+(pente-grandeurs[codeDerivee].valeur[i2])*
        (monde[mondeX].axe.valeur[i2]-monde[mondeX].axe.valeur[pred(i2)])/
        (grandeurs[codeDerivee].valeur[i2]-grandeurs[codeDerivee].valeur[pred(i2)]);
     y2 := monde[mondeY].axe.valeur[i2]+(x2-monde[mondeX].axe.valeur[i2])*
        (monde[mondeY].axe.valeur[i2]-monde[mondeY].axe.valeur[pred(i2)])/
        (monde[mondeX].axe.valeur[i2]-monde[mondeX].axe.valeur[pred(i2)]);
// valeur approchée de ve pHe
     veAp := (x1+x2)/2;
     pHeAp := (y1+y2)/2;
// cherche intersection avec courbe
     i3 := (index1+i2) div 2;
     k := 0;
     kmax := abs(i3-i2);
     if kmax>16 then kmax := 16;
     repeat
        inc(k);
        chercheEqui(i3);
        result := (ve-monde[mondeX].axe.valeur[succ(i3)])*
                  (ve-monde[mondeX].axe.valeur[i3])<=0;
// result si vee entre les deux points
        if not Result then begin
           if ve>monde[mondeX].axe.valeur[i3]
               then if VcroissantSelonI then inc(i3) else dec(i3)
               else if VcroissantSelonI then dec(i3) else inc(i3);
        end;
     until result or (k>kmax) or (i3>i2) or (i3<index1);
     if not result then chercheEqui((index1+i2) div 2);
// on remet à la valeur approchée la plus raisonnable
     result := (ve<monde[mondeX].maxi) and (ve>monde[mondeX].mini);
end end; // ChercheVpH

var i : integer;
begin //equivalence.modifDerivee
     codeDerivee := indexDerivee(agraphe.monde[agraphe.mondeDerivee].axe,
                                 aGraphe.monde[mondeX].axe,true,true);
     aGraphe.indexCourbeEquivalence := -1;
     if varY=nil then varY := aGraphe.monde[mondepH].axe;
     for i  := 0 to pred(agraphe.courbes.count) do
         if agraphe.courbes[i].varY=varY then
              aGraphe.indexCourbeEquivalence := i;
     if codeDerivee=grandeurInconnue then exit;
     if aGraphe.indexCourbeEquivalence<0 then exit;
     aCourbe := aGraphe.Courbes[aGraphe.indexCourbeEquivalence];
     IsModelisee := not(acourbe.courbeExp) and
                    ((acourbe.indexModele=1) and
                     (acourbe.valYder<>nil));
     if  lrEquivalence in LigneRappel then begin
           if IsModelisee
              then begin if not ChercheVpHModele then exit end
              else begin if not ChercheVpH then exit end;
     end;
end;// Equivalence.ModifDerivee


