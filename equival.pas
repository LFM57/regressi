// equival.pas = include graphker

function Tequivalence.GetVarY : Tgrandeur;
var idx : integer;
begin
     result := nil;
     if nomVarY <> '' then begin
        idx := indexNom(nomVarY);
        if idx <> grandeurInconnue then
           result := grandeurs[idx];
     end;
     if (result = nil) and (aGraphe <> nil) then begin
        result := aGraphe.monde[mondepH].axe;
        if result = nil then
           result := aGraphe.monde[mondeY].axe;
     end;
end;

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

Procedure Tequivalence.DrawLatex(var latexStr : TstringList);
var exposantX,exposantY : double;

Procedure TraceDroiteLatex(x,y,pente : double;
   xMin,yMin,xMax,Ymax : double);
var x1d,x2d : double;
    y1d,y2d : double;
begin
    if pente=0
       then begin
          x1d := xMin;
          x2d := xMax;
       end
       else begin
          try
          if pente>0
             then begin
                x1d := x+(yMin-y)/pente;
                x2d := x+(yMax-y)/pente;
             end
             else begin
                x1d := x+(yMax-y)/pente;
                x2d := x+(yMin-y)/pente;
             end;
         if x1d<xMin then x1d := xMin;
         if x2d>xMax then x2d := xMax;
         except
             x1d := xMin;
             x2d := xMax;
         end;
    end;
    y1d := y+pente*(x1d-x);
    y2d := y+pente*(x2d-x);
    latexStr.add('\draw[dashed,'+couleurLatex(couleur)+',thick] '+
     '(axis cs:'+floatToStrLatex(x1d/exposantX)+','+floatToStrLatex(y1d/exposantY)+')'+
     ' -- '+
     '(axis cs:'+floatToStrLatex(x2d/exposantX)+','+floatToStrLatex(y2d/exposantY)+');');
end;

var ecart,x3,x4,y3,y4,xAxe : double;
    strX,strY : string;
begin with aGraphe do begin
     latexStr.clear;
     if monde[mondepH].axe = nil
        then strY := formatReg(pHe / monde[mondepH].exposant) + ' '
        else strY := monde[mondepH].axe.formatNombre(pHe / monde[mondepH].exposant,1) + ' ';
     if monde[mondeX].axe = nil
        then strX := formatReg(ve / monde[mondeX].exposant) + ' '
        else strX := monde[mondeX].axe.formatNombre(ve / monde[mondeX].exposant,1) + ' ';
     case mondepH of
          mondeY : xAxe := monde[mondeX].mini;
          mondeDroit : xAxe := monde[mondeX].maxi;
          else xAxe := monde[mondeX].mini;
     end;
     exposantX := monde[mondeX].exposant;
     exposantY := monde[mondepH].exposant;
     if lrEquivalence in LigneRappel then begin
         x3 := x1-(x2-x1)/2;
         x4 := x2+(x2-x1)/2;
         y3 := (y1+y2)/2-abs(y2-y1);
         y4 := (y2+y1)/2+abs(y2-y1);
         latexStr.add('\draw[dotted,thick] '+
         '(axis cs:'+floatToStrLatex(xAxe/exposantX)+','+floatToStrLatex(phe/exposantY)+') node[above right] {'+strY+'} '+
         '-- (axis cs:'+floatToStrLatex(ve/exposantX)+','+floatToStrLatex(phe/exposantY)+') '+
         '-- (axis cs:'+floatToStrLatex(ve/exposantX)+','+floatToStrLatex(monde[mondepH].mini/exposantY)+') node[above right] {'+strX+'} ;');
         traceDroiteLatex(x1,y1,pente,x3,y3,x4,y4);
         traceDroiteLatex(x2,y2,pente,x3,y3,x4,y4);
         traceDroiteLatex(ve,pHe,pente,x3,y3,x4,y4);
     end;
     if lrTangente in LigneRappel then begin
         ecart := (monde[mondeX].maxi - monde[mondeX].mini)*LongueurTangente;
         x3 := ve+ecart;
         if x3>monde[mondeX].maxi then x3 := monde[mondeX].maxi;
         x4 := ve-ecart;
         if x4<monde[mondeX].mini then x4 := monde[mondeX].mini;
         ecart := (monde[MondepH].maxi - monde[MondepH].mini)*LongueurTangente;
         y3 := pHe+ecart;
         if y3>monde[mondepH].maxi then y3 := monde[mondepH].maxi;
         y4 := pHe-ecart;
         if y4<monde[mondepH].mini then y4 := monde[mondepH].mini;
         traceDroiteLatex(ve,pHe,pente,x4,y4,x3,y3);
         setUnitePente(mondepH);
         strX := unitePente.formatPenteUnite(pente);
         latexStr.add('\draw '+
                '(axis cs:'+floatToStrLatex(ve/exposantX)+','+
                            floatToStrLatex(phe/exposantY)+') node[above right] {'+
                            translateNomTexte(strX)+'} ;');
     end;
     if [lrXdeY,lrReticule]*ligneRappel<>[] then begin
          latexStr.add('\draw[dash dot,thick] '+
            '(axis cs:'+floatToStrLatex(xAxe/exposantX)+','+floatToStrLatex(phe/exposantY)+') node[above right] {'+strY+'} '+
            '-- (axis cs:'+floatToStrLatex(ve/exposantX)+','+floatToStrLatex(phe/exposantY)+') '+
            '-- (axis cs:'+floatToStrLatex(ve/exposantX)+','+floatToStrLatex(monde[mondepH].mini/exposantY)+') node[above right] {'+strX+'} ;');
     end;
end end; // equivalence.drawLatex

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
                x1 := x+(yMin-y)/pente;
                x2 := x+(yMax-y)/pente;
             end
             else begin
                x1 := x+(yMax-y)/pente;
                x2 := x+(yMin-y)/pente;
             end;
         if x1<xMin then x1 := xMin;
         if x2>xMax then x2 := xMax;
         except
             x1 := xMin;
             x2 := xMax;
         end;
    end;
    windowXY(x1,y+pente*(x1-x),mondepH,point1);
    windowXY(x2,y+pente*(x2-x),mondepH,point2);
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
    windowXY(x,y,mondepH,point2);
    segmentXY(point2.x+dx,point2.y+dy,point2.x-dx,point2.y-dy);
    except
    end;
end end;

procedure ChercheEquivalence(veAp,pheAp : double);

function ChercheEqui(i : integer) : boolean;
var v3,pH3,penteCourbe,dx : double;
// intersection droite (veeAp pHeAp penteTg) et (v3 ph3 penteCourbe)
begin
     result := false;
     if (i < 0) or (succ(i) >= pages[pageCourante].nmes) then exit;
     dx := aGraphe.monde[mondeX].axe.valeur[succ(i)]-aGraphe.monde[mondeX].axe.valeur[i];
     if dx = 0 then exit;
     penteCourbe :=
        (aGraphe.monde[mondepH].axe.valeur[succ(i)]-aGraphe.monde[mondepH].axe.valeur[i])/dx;
     if pente = penteCourbe then exit;
     v3 := aGraphe.monde[mondeX].axe.valeur[i];
     ph3 := agraphe.monde[mondepH].axe.valeur[i];
     ve := (pH3-penteCourbe*v3-pHeAp+pente*veAp)/(pente-penteCourbe);
     pHe := pH3+penteCourbe*(ve-v3);
     result := ((ve-agraphe.monde[mondeX].axe.valeur[succ(i)])*
               (ve-agraphe.monde[mondeX].axe.valeur[i])<=0) and
               ((phe-agraphe.monde[mondepH].axe.valeur[succ(i)])*
               (phe-agraphe.monde[mondepH].axe.valeur[i])<=0);
end; // ChercheEqui

var imax,i,nLim : integer;
    trouve : boolean;
begin  // ChercheEquivalence
     nLim := pages[pageCourante].nmes - 2;
     if nLim < 0 then begin
        ve := veAp;
        phe := pheAp;
        exit;
     end;
     i := index1;
     imax := index2;
     if imax<i then swap(i,imax);
     if i < 0 then i := 0;
     if imax > nLim then imax := nLim;
     trouve := false;
     while (not trouve) and (i <= imax) do begin
        trouve := ChercheEqui(i);
        if not trouve then inc(i);
     end;
     if not trouve then begin
        ve := veAp;
        phe := pheAp;
     end;
end; // ChercheEquivalence

procedure AffineEquivalence;
var xvecteur1,yvecteur1,derivee1,xvecteur2,yvecteur2,derivee2 : vecteur;
    i,N2,N2Modele : integer;
    nbrePointDeriveeL, nmesLoc, maxEcart : integer;
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
    if (agraphe.monde[mondeX].axe = nil) or (agraphe.monde[mondepH].axe = nil) then exit;
    nmesLoc := pages[pageCourante].nmes;
    if Length(agraphe.monde[mondeX].axe.valeur) < nmesLoc then
       nmesLoc := Length(agraphe.monde[mondeX].axe.valeur);
    if Length(agraphe.monde[mondepH].axe.valeur) < nmesLoc then
       nmesLoc := Length(agraphe.monde[mondepH].axe.valeur);
    if (nmesLoc < 3) or (index1 < 0) or (index1 >= nmesLoc) or
       (index2 < 0) or (index2 >= nmesLoc) then exit;
    maxEcart := Min(Min(index1, nmesLoc - 1 - index1), Min(index2, nmesLoc - 1 - index2));
    if maxEcart < 1 then exit;
    NbrePointDeriveeL := 2*abs(index2 - index1) div 3;
    if not odd(NbrePointDeriveeL) then inc(NbrePointDeriveeL);
    if NbrePointDeriveeL<3 then NbrePointDeriveeL := 3;
    if NbrePointDeriveeL>7 then NbrePointDeriveeL := 7;
    if (NbrePointDeriveeL div 2) > maxEcart then
       NbrePointDeriveeL := 2 * maxEcart + 1;
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
     nomVarY := '';
     isIntersection := false;
     couleur := GetCouleurPages(c);
     modelisee := false;
end;

constructor Tequivalence.CreateEq(v,ph,p : double;gr : TgrapheReg);
begin
     agraphe := gr;
     ve := v;
     phe := pH;
     pente := p;
     x2 := 0;  y2 := 0;
     x1 := 0;  y1 := 0;
     mondepH := mondeY;
     nomVarY := '';
     isIntersection := false;
     couleur := GetCouleurPages(pageCourante);
     modelisee := false;
end;

constructor Tequivalence.Create(gr : TgrapheReg);
begin
     agraphe := gr;
     nomVarY := '';
     isIntersection := false;
     modelisee := false;
     mondepH := mondeY;
end;

Procedure TgrapheReg.AjouteEquivalence(i : integer;effaceDouble : boolean);
var penteTg,v11,vee,phee,ph11,v22,ph22 : double;
    codeDerivee : integer;
    IsModelisee : boolean;
    i2 : integer;

Function ChercheVpHModele : boolean;
var veAp,pHeAp : double;

procedure ChercheEqui(i : integer);
var v3,pH3,penteCourbe,dx : double;
// intersection droite (veeAp pHeAp pentetg) et (v3 ph3 pentecourbe)
begin with courbes[indexCourbeEquivalence] do begin
     if (i < 0) or (succ(i) > finC) then exit;
     dx := valX[succ(i)]-valX[i];
     if dx = 0 then exit;
     penteCourbe := (valY[succ(i)]-valY[i])/dx;
     if penteTg = penteCourbe then exit;
     v3 := valX[i];
     ph3 := valY[i];
     vee := (pH3-penteCourbe*v3-pHeAp+penteTg*veAp)/(penteTg-penteCourbe);
     pHee := pH3+penteCourbe*(vee-v3);
end end; // ChercheEqui

var i3,i3ap,iprec,isuiv,iPeak,kLeft,kRight : integer;
    derRef,derMax,minL,minR,refLevel : double;
    k,kmax : integer;
    VcroissantSelonI,Croissant,trouvePaire : boolean;
begin with courbes[indexCourbeEquivalence] do begin
     result := false;
     if (finC < 2) or (i < 0) or (i > finC) then exit;
     vee := monde[mondeX].Maxi;
     penteTg := valYder[i];
     if IsNan(penteTg) then exit;
     derRef := abs(penteTg);
     i2 := i;
     croissant := true;
     trouvePaire := false;
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
        if i2>=0 then begin
          repeat dec(i2);
          until (i2<0) or
                 (abs(valYder[i2])<derRef);
          if i2>=0 then trouvePaire := true;
        end;
     end
     else begin
         repeat inc(i2);
         until (i2>finC) or
          (abs(valYder[i2])<derRef);
         if i2<finC then trouvePaire := true;
     end;
     if not trouvePaire then begin
        // Utilisateur a cliqué près/sur le point d'inflexion : chercher deux flancs de même pente
        iPeak := i;
        while (iPeak + 1 <= finC) and (abs(valYder[iPeak + 1]) > abs(valYder[iPeak])) do inc(iPeak);
        while (iPeak - 1 >= 0) and (abs(valYder[iPeak - 1]) > abs(valYder[iPeak])) do dec(iPeak);
        derMax := abs(valYder[iPeak]);
        if (derMax <= 0) or IsNan(derMax) then exit;
        minL := derMax;
        for kLeft := iPeak - 1 downto 0 do
           if abs(valYder[kLeft]) < minL then begin
              minL := abs(valYder[kLeft]);
              if minL <= 0.35 * derMax then break;
           end;
        minR := derMax;
        for kRight := iPeak + 1 to finC do
           if abs(valYder[kRight]) < minR then begin
              minR := abs(valYder[kRight]);
              if minR <= 0.35 * derMax then break;
           end;
        refLevel := Max(minL, minR);
        if refLevel >= 0.98 * derMax then exit;
        kLeft := iPeak - 1;
        while (kLeft > 0) and (abs(valYder[kLeft]) > refLevel) do dec(kLeft);
        i := kLeft;
        penteTg := valYder[i];
        derRef := abs(penteTg);
        i2 := iPeak + 1;
        while (i2 < finC) and (abs(valYder[i2]) > derRef) do inc(i2);
        if (i2 > finC) or (i2 <= iPeak) then exit;
        croissant := true;
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
     until (valX[i3]>veAp) or (i3>=i2); // hypothèse VcroissantSelonI
     if i3 >= finC then i3 := finC - 1;
     i3ap := i3;
     k := 0;
     kmax := (i2-i) div 2;
     if kmax>32 then kmax := 32;
     repeat
        inc(k);
        chercheEqui(i3);
        result := (i3 >= 0) and (succ(i3) <= finC) and
                  ((vee-valX[succ(i3)])*(vee-valX[i3])<=0);
{ result si vee entre les deux points }
        if not Result then begin
           if vee>valX[i3]
              then if VcroissantSelonI then inc(i3) else dec(i3)
              else if VcroissantSelonI then dec(i3) else inc(i3);
        end;
     until result or (k>kmax) or (i3>=i2) or (i3<i) or (succ(i3)>finC);
     if not result then chercheEqui(i3Ap);
// on remet à la valeur approchée la plus raisonnable
     result := (vee<monde[mondeX].maxi) and (vee>monde[mondeX].mini);
end end; // ChercheVpHmodele

Function ChercheVpH : boolean;
var veAp,pHeAp : double;

procedure ChercheEqui(i : integer);
var v3,pH3,penteCourbe,dx : double;
// intersection droite (veeAp pHeAp pentetg) et (v3 ph3 pentecourbe)
begin
     if (i < 0) or (succ(i) >= pages[pageCourante].nmes) then exit;
     dx := monde[mondeX].axe.valeur[succ(i)]-monde[mondeX].axe.valeur[i];
     if dx = 0 then exit;
     penteCourbe :=
        (monde[mondeDerivee].axe.valeur[succ(i)]-monde[mondeDerivee].axe.valeur[i])/dx;
     if penteTg = penteCourbe then exit;
     v3 := monde[mondeX].axe.valeur[i];
     ph3 := monde[mondeDerivee].axe.valeur[i];
     vee := (pH3-penteCourbe*v3-pHeAp+penteTg*veAp)/(penteTg-penteCourbe);
     pHee := pH3+penteCourbe*(vee-v3);
end;// ChercheEqui

var i3,iprec,isuiv,iPeak,kLeft,kRight,nmesLoc : integer;
    derRef,derMax,minL,minR,refLevel,dDer,dX : double;
    k,kmax : integer;
    VcroissantSelonI,Croissant,trouvePaire : boolean;
begin
     result := false;
     nmesLoc := pages[pageCourante].nmes;
     if (nmesLoc < 3) or (i < 0) or (i >= nmesLoc) then exit;
     vee := monde[mondeX].Maxi;
     penteTg := grandeurs[codeDerivee].valeur[i];
     if IsNan(penteTg) then exit;
     derRef := abs(penteTg);
     i2 := i;
     croissant := true;
     trouvePaire := false;
     iprec := i2-2;
     if iprec<0 then iprec := 0;
     isuiv := i2+2;
     if isuiv>=nmesLoc
        then isuiv := pred(nmesLoc);
     with monde[mondeX].axe do VcroissantSelonI :=
          valeur[isuiv]>valeur[iprec];
     repeat inc(i2)
     until (i2>=nmesLoc) or
           (abs(grandeurs[codeDerivee].valeur[i2])>derRef);
     if i2>=nmesLoc then begin
        croissant := false;
        i2 := i;
        repeat dec(i2)
        until (i2<0) or
              (abs(grandeurs[codeDerivee].valeur[i2])>derRef);
        if i2>=0 then begin
          repeat dec(i2);
          until (i2<0) or
                 (abs(grandeurs[codeDerivee].valeur[i2])<derRef);
          if i2>=0 then trouvePaire := true;
        end;
     end
     else begin
         repeat inc(i2);
         until (i2>=nmesLoc) or
          (abs(grandeurs[codeDerivee].valeur[i2])<derRef);
         if i2<nmesLoc then trouvePaire := true;
     end;
     if not trouvePaire then begin
        // Utilisateur a cliqué près/sur le point d'inflexion : chercher deux flancs de même pente
        iPeak := i;
        while (iPeak + 1 < nmesLoc) and (abs(grandeurs[codeDerivee].valeur[iPeak + 1]) > abs(grandeurs[codeDerivee].valeur[iPeak])) do inc(iPeak);
        while (iPeak - 1 >= 0) and (abs(grandeurs[codeDerivee].valeur[iPeak - 1]) > abs(grandeurs[codeDerivee].valeur[iPeak])) do dec(iPeak);
        derMax := abs(grandeurs[codeDerivee].valeur[iPeak]);
        if (derMax <= 0) or IsNan(derMax) then exit;
        minL := derMax;
        for kLeft := iPeak - 1 downto 0 do
           if abs(grandeurs[codeDerivee].valeur[kLeft]) < minL then begin
              minL := abs(grandeurs[codeDerivee].valeur[kLeft]);
              if minL <= 0.35 * derMax then break;
           end;
        minR := derMax;
        for kRight := iPeak + 1 to pred(nmesLoc) do
           if abs(grandeurs[codeDerivee].valeur[kRight]) < minR then begin
              minR := abs(grandeurs[codeDerivee].valeur[kRight]);
              if minR <= 0.35 * derMax then break;
           end;
        refLevel := Max(minL, minR);
        if refLevel >= 0.98 * derMax then exit;
        kLeft := iPeak - 1;
        while (kLeft > 0) and (abs(grandeurs[codeDerivee].valeur[kLeft]) > refLevel) do dec(kLeft);
        i := kLeft;
        penteTg := grandeurs[codeDerivee].valeur[i];
        derRef := abs(penteTg);
        i2 := iPeak + 1;
        while (i2 < pred(nmesLoc)) and (abs(grandeurs[codeDerivee].valeur[i2]) > derRef) do inc(i2);
        if (i2 >= nmesLoc) or (i2 <= iPeak) then exit;
        croissant := true;
     end;
     if not croissant then swap(i,i2);
// i2 : point après l'équivalence de même pente 
     v11 := monde[mondeX].axe.valeur[i];
     ph11 := monde[mondeDerivee].axe.valeur[i];
     if (i2 > 0) and (i2 < nmesLoc) then begin
        dDer := grandeurs[codeDerivee].valeur[i2]-grandeurs[codeDerivee].valeur[pred(i2)];
        dX := monde[mondeX].axe.valeur[i2]-monde[mondeX].axe.valeur[pred(i2)];
        if (dDer <> 0) and (not IsNan(dDer)) then
           v22 := monde[mondeX].axe.valeur[i2]+(penteTg-grandeurs[codeDerivee].valeur[i2])*dX/dDer
        else
           v22 := monde[mondeX].axe.valeur[i2];
        if (dX <> 0) and (not IsNan(dX)) then
           ph22 := monde[mondeDerivee].axe.valeur[i2]+(v22-monde[mondeX].axe.valeur[i2])*
              (monde[mondeDerivee].axe.valeur[i2]-monde[mondeDerivee].axe.valeur[pred(i2)])/dX
        else
           ph22 := monde[mondeDerivee].axe.valeur[i2];
     end else begin
        v22 := monde[mondeX].axe.valeur[i2];
        ph22 := monde[mondeDerivee].axe.valeur[i2];
     end;
// valeur approchée de ve pHe
     veAp := (v11+v22)/2;
     pHeAp := (pH11+pH22)/2;
// cherche intersection avec courbe
     i3 := (i+i2) div 2;
     if i3 >= pred(nmesLoc) then i3 := nmesLoc - 2;
     if i3 < 0 then i3 := 0;
     k := 0;
     kmax := abs(i3-i2);
     if kmax>16 then kmax := 16;
     repeat
        inc(k);
        chercheEqui(i3);
        result := (i3 >= 0) and (succ(i3) < nmesLoc) and
                  ((vee-monde[mondeX].axe.valeur[succ(i3)])*
                   (vee-monde[mondeX].axe.valeur[i3])<=0);
// result si vee entre les deux points
        if not Result then begin
           if vee>monde[mondeX].axe.valeur[i3]
               then if VcroissantSelonI then inc(i3) else dec(i3)
               else if VcroissantSelonI then dec(i3) else inc(i3);
        end;
     until result or (k>kmax) or (i3>i2) or (i3<i) or (succ(i3)>=nmesLoc);
     if not result then begin
        i3 := (i+i2) div 2;
        if i3 >= pred(nmesLoc) then i3 := nmesLoc - 2;
        if i3 < 0 then i3 := 0;
        chercheEqui(i3);
     end;
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
    yVar : Tgrandeur;
begin // AjouteEquivalence
     if (monde[mondeDerivee].axe = nil) or (monde[mondeX].axe = nil) then exit;
     if (indexCourbeEquivalence < 0) or (indexCourbeEquivalence >= courbes.Count) then exit;
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
             yVar := GetVarY;
             if (yVar <> nil) and
                (abs(x1-monde[mondeX].axe.valeur[i])<dx) and
                (abs(y1-yVar.valeur[i])<dy) then begin
                  if effaceDouble then begin
                     Draw;
                     equivalences[pageCourante].Delete(t);
                  end;
                  exit;
            end;
        end;
      NewEquivalence := Tequivalence.CreateEq(vee,phee,penteTg,self);
      with NewEquivalence do begin
         index1 := i;
         index2 := i2;
         modelisee := IsModelisee;
         mondepH := mondeDerivee;
         nomVarY := monde[mondeDerivee].axe.nom;
         ligneRappel := [ligneRappelCourante];
         x2 := v22;
         y2 := ph22;
         x1 := v11;
         y1 := ph11;
      end;
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
    yVar : Tgrandeur;
begin with Agraphe do begin
     if modelisee
        then begin
           if (indexCourbeEquivalence < 0) or (indexCourbeEquivalence >= courbes.Count) then exit;
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
           yVar := GetVarY;
           if (yVar = nil) or (monde[mondeX].axe = nil) then exit;
           codeDerivee := indexDerivee(yVar,monde[mondeX].axe,true,true);
           ve := monde[mondeX].axe.valeur[i];
           pHe := yVar.valeur[i];
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
  writeIntegerXML(ANode,'isRappel',word(byte(LigneRappel)));
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
  modelisee := litBooleanRW3;{8}
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
var v3,pH3,penteCourbe,dx : double;
// intersection droite (veeAp pHeAp pentetg) et (v3 ph3 pentecourbe)
begin
     if (i < 0) or (succ(i) >= pages[pageCourante].nmes) then exit;
     dx := aGraphe.monde[mondeX].axe.valeur[succ(i)]-aGraphe.monde[mondeX].axe.valeur[i];
     if dx = 0 then exit;
     penteCourbe :=
        (aGraphe.monde[mondepH].axe.valeur[succ(i)]-aGraphe.monde[mondepH].axe.valeur[i])/dx;
     if pente = penteCourbe then exit;
     v3 := aGraphe.monde[mondeX].axe.valeur[i];
     ph3 := agraphe.monde[mondepH].axe.valeur[i];
     ve := (pH3-penteCourbe*v3-pHeAp+pente*veAp)/(pente-penteCourbe);
     pHe := pH3+penteCourbe*(ve-v3);
end; // ChercheEqui

var i2,i3,iprec,isuiv,nmesLoc : integer;
    derRef,dDer,dX : double;
    k,kmax : integer;
    VcroissantSelonI,Croissant : boolean;
begin with agraphe do begin
     result := false;
     nmesLoc := pages[pageCourante].nmes;
     if (nmesLoc < 3) or (index1 < 0) or (index1 >= nmesLoc) then exit;
     ve := monde[mondeX].Maxi;
     pente := grandeurs[codeDerivee].valeur[index1];
     if IsNan(pente) then exit;
     derRef := abs(pente);
     i2 := index1;
     croissant := true;
     iprec := i2-2;
     if iprec<0 then iprec := 0;
     isuiv := i2+2;
     if isuiv>=nmesLoc
        then isuiv := pred(nmesLoc);
     with monde[mondeX].axe do VcroissantSelonI :=
          valeur[isuiv]>valeur[iprec];
     repeat inc(i2)
     until (i2>=nmesLoc) or
           (abs(grandeurs[codeDerivee].valeur[i2])>derRef);
     if i2>=nmesLoc then begin
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
         until (i2>=nmesLoc) or
          (abs(grandeurs[codeDerivee].valeur[i2])<derRef);
         if i2>=nmesLoc then exit;
     end;
     if not croissant then swap(index1,i2);
// i2 : point après l'équivalence de même pente
     x1 := monde[mondeX].axe.valeur[index1];
     y1 := monde[mondepH].axe.valeur[index1];
     if (i2 > 0) and (i2 < nmesLoc) then begin
        dDer := grandeurs[codeDerivee].valeur[i2]-grandeurs[codeDerivee].valeur[pred(i2)];
        dX := monde[mondeX].axe.valeur[i2]-monde[mondeX].axe.valeur[pred(i2)];
        if (dDer <> 0) and (not IsNan(dDer)) then
           x2 := monde[mondeX].axe.valeur[i2]+(pente-grandeurs[codeDerivee].valeur[i2])*dX/dDer
        else
           x2 := monde[mondeX].axe.valeur[i2];
        if (dX <> 0) and (not IsNan(dX)) then
           y2 := monde[mondepH].axe.valeur[i2]+(x2-monde[mondeX].axe.valeur[i2])*
              (monde[mondepH].axe.valeur[i2]-monde[mondepH].axe.valeur[pred(i2)])/dX
        else
           y2 := monde[mondepH].axe.valeur[i2];
     end else begin
        x2 := monde[mondeX].axe.valeur[i2];
        y2 := monde[mondepH].axe.valeur[i2];
     end;
// valeur approchée de ve pHe
     veAp := (x1+x2)/2;
     pHeAp := (y1+y2)/2;
// cherche intersection avec courbe
     i3 := (index1+i2) div 2;
     if i3 >= pred(nmesLoc) then i3 := nmesLoc - 2;
     if i3 < 0 then i3 := 0;
     k := 0;
     kmax := abs(i3-i2);
     if kmax>16 then kmax := 16;
     repeat
        inc(k);
        chercheEqui(i3);
        result := (i3 >= 0) and (succ(i3) < nmesLoc) and
                  ((ve-monde[mondeX].axe.valeur[succ(i3)])*
                   (ve-monde[mondeX].axe.valeur[i3])<=0);
// result si vee entre les deux points
        if not Result then begin
           if ve>monde[mondeX].axe.valeur[i3]
               then if VcroissantSelonI then inc(i3) else dec(i3)
               else if VcroissantSelonI then dec(i3) else inc(i3);
        end;
     until result or (k>kmax) or (i3>i2) or (i3<index1) or (succ(i3)>=nmesLoc);
     if not result then begin
        i3 := (index1+i2) div 2;
        if i3 >= pred(nmesLoc) then i3 := nmesLoc - 2;
        if i3 < 0 then i3 := 0;
        chercheEqui(i3);
     end;
// on remet à la valeur approchée la plus raisonnable
     result := (ve<monde[mondeX].maxi) and (ve>monde[mondeX].mini);
end end; // ChercheVpH

var i : integer;
    yVar : Tgrandeur;
begin //equivalence.modifDerivee
     if (agraphe.monde[agraphe.mondeDerivee].axe = nil) or
        (agraphe.monde[mondeX].axe = nil) then exit;
     codeDerivee := indexDerivee(agraphe.monde[agraphe.mondeDerivee].axe,
                                 aGraphe.monde[mondeX].axe,true,true);
     aGraphe.indexCourbeEquivalence := -1;
     yVar := GetVarY;
     for i  := 0 to pred(agraphe.courbes.count) do
         if (yVar <> nil) and (agraphe.courbes[i].varY=yVar) then
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


