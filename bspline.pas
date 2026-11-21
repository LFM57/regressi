procedure CalculBSpline(const X,Y : vecteur;ordre : integer;
                        var N : integer;var Xspline,Yspline : vecteur);
Const Nmax = 256; // 1 pixel sur 4 pour écran 1024
var
   xi : vecteur;
   Nij : array[1..ordreMaxSpline] of vecteur;
   nspl,ix : integer;
   pas,t,xx,yy,e1,e2 : extended;
   i,k,j : integer;

  procedure calculX;
  var i : integer;
  begin
     for i := 1 to N+ordre do begin
        if i<=ordre
           then xi[i] := 0
           else if i>n
             then xi[i] := N+1-ordre
             else xi[i] := i-ordre
     end;
  end;

  var jmoins1 : integer;
      coeff : extended;
  begin // CalculBSpline
    copyVecteur(Xspline,X);
    copyVecteur(Yspline,Y);
    if ordre>ordreMaxSpline then ordre := ordreMaxSpline;
    if ordre<ordreMinSpline then ordre := ordreMinSpline;
    if (N<=ordre) or (N>=(high(X)-ordreMaxSpline)) then exit;
    setLength(xi,N+OrdreMaxSpline+3);
    for j := 1 to ordre do setLength(Nij[j],N+OrdreMaxSpline+3);
    calculX;
    pas := (N+1-ordre)/Nmax;
    setLength(Xspline,Nmax+1);
    setLength(Yspline,Nmax+1);
    Xspline[0] := X[0];
    Yspline[0] := Y[0];
// balayage de Xspline
    ix := ordre;
    for nspl := 1 to pred(Nmax) do begin
        t := nspl*pas;
// recherche de xi
        while t>xi[succ(ix)] do inc(ix);
// xi[ix]<=t<=xi[ix+1]
// initialisation Nij
		  for j := 1 to ordre do
			  for i := 1 to n+ordre do
				  Nij[j,i] := 0;
// affectation de Ni1
		  Nij[1,ix] := 1;
// Calcul Ni2
      try
      Coeff := 1/(xi[succ(ix)]-xi[ix]);
		  Nij[2,ix]:=(t-xi[ix])*coeff;
		  Nij[2,pred(ix)]:=(xi[succ(ix)]-t)*coeff;
      except
      end;
// Calcul Nij j>2
		  for j := 3 to ordre do begin
		      jmoins1 := j-1;
		      for k := ix-jmoins1 to ix do begin
                          e1 := xi[k+jmoins1]-xi[k];
                          if e1<>0 then e1:=(t-xi[k])*Nij[jmoins1,k]/e1;
                          e2 := xi[k+j]-xi[k+1];
                          if e2<>0 then e2:=(xi[k+j]-t)*Nij[jmoins1,k+1]/e2;
                          Nij[j,k] := e1+e2;
		      end;// for k
		  end;// for j
// calcul de Xspline, Yspline
		  xx := 0;
		  yy := 0;
		  for k := 0 to pred(N) do begin
		       xx := X[k]*Nij[ordre,k+1]+xx;
		       yy := Y[k]*Nij[ordre,k+1]+yy;
		  end;// for k
		  Xspline[nspl] := xx;
		  Yspline[nspl] := yy;
	 end; // for nspl
     Xspline[Nmax] := X[pred(N)];
     Yspline[Nmax] := Y[pred(N)];
     N := succ(Nmax);
     xi := nil;
     for j := 1 to ordre do Nij[j] := nil;
end; // CalculBSpline

procedure InterpoleSinc(const X,Y : vecteur;ordre : integer;
                        var N : integer;var Xspline,Yspline : vecteur);
Const Nmax = 4096; // tous les pixels d'un écran 4096
      a = 6; // à droite et à gauche soit 13 points
      NijMax = (ordreMaxSinc+1)*(2*a+1); // 208
var
   Nij : array[0..NijMax] of double;
   i,j,k,Nsinc : integer;
   imin,imax : integer;
   yy,deltaX,w : double;
begin
    copyVecteur(Xspline,X);
    copyVecteur(Yspline,Y);
    if (N<ordreMaxSinc) then exit;
    if ordre>ordreMaxSinc then ordre := ordreMaxSinc;
    if ordre<2 then ordre := 2;
    while ((N*ordre)>Nmax) and
          (ordre>2) do dec(ordre);
    Nsinc := N*ordre;
    if Nsinc>Nmax then exit;
    setLength(Xspline,Nsinc+1);
    setLength(Yspline,Nsinc+1);
    Nij[0] := 1;
		for j := 1 to NijMax do begin // calcul du noyau
        yy := pi*j/ordre;
        Nij[j] := sinc(yy)*sinc(yy/a);
    end;
    deltaX := (X[N-1]-X[0])/(N-1)/ordre;
// calcul de Xspline, Yspline
    for j := 0 to Nsinc-1 do begin
        k := round(j/ordre);
        Xspline[j] := X[0]+j*deltaX;
        yy := 0;
        w := 0;
        imin := k-a;
        if imin<0 then imin := 0;
        imax := imin+2*a; // 2*a+1 points
        if imax>=N then begin
           imax := N-1;
           imin := imax-2*a;
           if imin<0 then imin := 0;
        end;
        for i := imin to imax do begin
            yy := yy + Y[i]*Nij[abs(i*ordre-j)];
            w := w + Nij[abs(i*ordre-j)];
        end;
        if w<>0
           then Yspline[j] := yy/w
           else Yspline[j] := yy;
    end;
    N := Nsinc;
end; // InterpoleSinc


procedure MoyGlissante(Y,Ylisse : vecteur;ordre,N : integer);
var Yg,dY : vecteur;

procedure RemoveGlitche;
var
   ordreG,j : integer;
   ecart,coeff : extended;
begin
   ordreG := ordre div 3;
   if ordreG<3 then ordreG := 3;
   coeff := 1/ordreG;
   copyVecteur(Yg,Y);
   ecart := 0;
   for j := 1 to N-1 do dY[j] := y[j]-y[j-1];
   for j := 1 to 2*ordreG do ecart := ecart+abs(dY[j]);
   for j := ordreG to N-ordreG-1 do begin
       ecart := ecart+abs(dy[j+ordreG])-abs(dy[j-ordreG])-abs(dy[j])-abs(dy[j+1]);
       if (dy[j]*dy[j+1]<0) and
          (abs(dy[j])>ecart*coeff) and
          (abs(dy[j+1])>ecart*coeff) then begin
              Yg[j] := (y[j+1]+yg[j-1])/2;
              dy[j] := yg[j]-yg[j-1];
              dy[j+1] := y[j+1]-yg[j];
       end;
       ecart := ecart+abs(dy[j])+abs(dy[j+1]);
   end;
   for j := N-ordreG to N-2 do begin
       ecart := ecart-dy[j]-dy[j+1];
       if (dy[j]*dy[j+1]<0) and
          ((abs(dy[j])>ecart*coeff) or
           (abs(dy[j+1])>ecart*coeff)) then begin
              Yg[j] := (y[j+1]+yg[j-1])/2;
              dy[j] := yg[j]-yg[j-1];
              dy[j+1] := y[j+1]-yg[j];
       end;
       ecart := ecart+dy[j]+dy[j+1];
   end;
   if (abs(dy[N-1])>abs(dy[N-2])*1.5) or
      (abs(dy[N-1])<abs(dy[N-2])*0.5) then
        Yg[N-1] := Yg[N-2]+dY[N-2];
   ecart := 0;
   for j := 1 to 2*ordreG do ecart := ecart+dY[j];
   for j := 1 to ordreG-1 do begin
       ecart := ecart-dy[j]-dy[j+1];
       if (dy[j]*dy[j+1]<0) and
          ((abs(dy[j])>ecart*coeff) or
           (abs(dy[j+1])>ecart*coeff)) then begin
              Yg[j] := (y[j+1]+yg[j-1])/2;
              dy[j] := yg[j]-yg[j-1];
              dy[j+1] := y[j+1]-yg[j];
       end;
       ecart := ecart+dy[j]+dy[j+1];
   end;
   if (abs(dy[1])>abs(dy[2])*1.5) or
      (abs(dy[1])<abs(dy[2])*0.5) then
        Yg[0] := Yg[1]-dY[2];
   affecteVecteur(Ylisse,yg);
end; // RemoveGlitche

const OrdreMax = 32;
      OrdreMin = 1;
var j : integer;
    a : extended;
begin  // MoyGlissante
   if ordre>ordreMax then ordre := ordreMax;
   if ordre<ordreMin then ordre := ordreMin;
   setLength(dy,N+1);
   RemoveGlitche;
   a := exp(-1/ordre);
   Ylisse[0] := Y[0];
   for j := 1 to pred(N) do
       Ylisse[j] := Y[j]*(1-a)+a*Ylisse[j-1];
 // (1-a) de manière à avoir une réponse de 1 à une entrée de 1
   yg := nil;
   dy := nil;
end; // MoyGlissante

{
procedure FiltreButterWorth(Y,Ylisse : vecteur;ordre,N : integer);
const OrdreMax = 64;
      OrdreMin = 3;
var j : integer;
    b1,b2 : extended;
begin
   copyVecteur(Ylisse,Y);
   if ordre>ordreMax then ordre := ordreMax;
   if ordre<ordreMin then ordre := ordreMin;
   b2 := ordre; //?
   b1 := sqrt(2)*sqrt(b2); //?
   for j := 2 to pred(N) do
       Ylisse[j] := Y[j]-b1*Ylisse[j-1]-b2*Ylisse[j-2];
end; // ButterWorth
}

Procedure CalculIntLineaire(const X,Y : vecteur;Debut,Fin,NbreLisse : integer;
          var XLisse,YLisse : vecteur);
var
      pas,t : extended;
      i,ix : integer;
begin
      pas := (X[fin]-X[debut])/pred(NbreLisse);
      Xlisse[0] := X[debut];
      Ylisse[0] := Y[debut];
      Ylisse[pred(NbreLisse)] := Y[fin];
      Xlisse[pred(NbreLisse)] := X[fin];
      ix := debut;
      for i := 1 to NbreLisse-2 do begin
          t := X[debut]+i*pas;
          Xlisse[i] := t;
// recherche de ix
	  while t>x[succ(ix)] do inc(ix);
// x[ix]<t<=x[ix+1]
          try
	      Ylisse[i] := Y[ix]+(t-X[ix])*(Y[succ(ix)]-Y[ix])/(X[succ(ix)]-X[ix]);
          except
          Ylisse[i] := Nan;
          end
      end; // for i
// interpolation à gauche
      try
      Ylisse[NbreLisse] := Y[fin]+pas*(Y[pred(fin)]-Y[fin])/(X[pred(fin)]-X[fin]);
      except
      Ylisse[NbreLisse] := Y[fin];
      end;
      Xlisse[NbreLisse] := X[fin]+pas;
end; // CalculIntLineaire 



