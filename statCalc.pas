unit statcalc;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Math,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,

  constreg,
  maths,
  regutil;

Const
      MaxHisto = 256;
{ Les bornes vont de 0 à MaxHisto et les classes de 1 à MaxHisto
  Classe i = entre bornes(pred(i)) et bornes(i) }

type
  TClasseStat = (csAuto,csNombreImpose,csEcartImpose,csEffectifDonne,csFrequenceDonnee,csSigma);

  TcalculStatistique = class
      FNbre : integer;
      Fntotal : integer;
      FpourCent : boolean;
      procedure setNbre(Anbre : integer);
      public
      Min,Max,Moyenne,Mediane,Sigma,t95,t99,ecartMoyen : double;
      ClasseStat : TclasseStat;
      Donnees,Effectif : vecteur;
      Cible,EcartDist,DebutDist,maxDist : double;
      NbreClasse : integer;
      MoyDist,NbreDist,BornesDist,DistPourCent : vecteur;
      StatOK,avecTri,DataInteger : boolean;
      property Nbre : integer read Fnbre write setNbre;
      property Ntotal : integer read Fntotal;      
      constructor Create;
      destructor Destroy; override;
      Procedure TestDataEntier;
      Function TestEffectif : boolean;
      Function TestFrequence : boolean;
      Procedure Calcul;
      Procedure SetValeur(Valeur : vecteur;Nmes : integer;wTri : boolean);
      Procedure SetValeurEffectif(Valeur,valEff : vecteur;Nmes : integer);
  end;

  TStatistiqueDeuxVar = class
      Sy,Sy2,Sx,Sx2,Sxx,Syy,sigma : double;
      covariance,penteY,Y0 : double;
      SSE,SSR : double;
      xmoyen,ymoyen : double;
      X,Y : vecteur;
      Nbre : integer;
      Fcorrelation : double;
      FFisher : double;
      Procedure yConfidence(x,y : double;var maxM,minM,maxI,minI : double);
      public
      Property Correlation : double read Fcorrelation;
      Property Fisher : double read FFisher;
      Procedure Init(ax,ay : vecteur;debut,fin : integer);
      Procedure GenereBande(X,Y : TvecteurExtrapole;Nbande : integer);
  end;

Procedure CalcCornish(X,Y : vecteur;N : integer;var K,V : vecteur;var Nbre : integer);
Procedure CalcCornishInters(X,Y : vecteur;N : integer;var Km,Vm : double);

var indexStat,indexEffectif : integer;
    statCourante : TcalculStatistique;

implementation

constructor TcalculStatistique.Create;
begin
   inherited create;
   setLength(MoyDist,MaxVecteurDefaut+1);
   setLength(NbreDist,MaxVecteurDefaut+1);
   setLength(DistPourCent,MaxVecteurDefaut+1);
   setLength(BornesDist,MaxVecteurDefaut+1);
   setLength(donnees,MaxVecteurDefaut+1);
   setLength(effectif,MaxVecteurDefaut+1);
   ClasseStat := csAuto;
   Cible := Nan;
   StatOK := false;
end;

procedure TcalculStatistique.Calcul;

Procedure CalculStat;
var i,imilieu : integer;
    total : double;
begin
   min := Donnees[0];
   max := Donnees[pred(Nbre)];
   moyenne := 0;
   mediane := Donnees[0];
   Sigma := 0;
   if Nbre<2 then exit;
   iMilieu := FNbre div 2;
   if odd(FNbre)
          then Mediane := Donnees[iMilieu]
          else Mediane := (Donnees[iMilieu]+Donnees[pred(iMilieu)])/2;
   for i := 0 to pred(FNbre) do begin
       moyenne := moyenne+Donnees[i];
       sigma := sigma+sqr(Donnees[i]);
       if Donnees[i]<Min then Min := Donnees[i];
       if Donnees[i]>Min then Max := Donnees[i];
   end;
   sigma := sqrt((sigma-sqr(moyenne)/Nbre)/pred(Nbre));
   moyenne := moyenne/Nbre;
   t99 := Sigma*Student99(Nbre-1)/sqrt(Nbre);
   t95 := Sigma*Student95(Nbre-1)/sqrt(Nbre);
   Fntotal := Fnbre;
   total := 0;
   for i := 0 to pred(FNbre) do
       total := total+abs(Donnees[i]-moyenne);
   ecartMoyen := total/Fnbre;
end;

Procedure CalculStatEffectif;
var i,imilieu,n : integer;
begin
   min := Donnees[0];
   max := Donnees[pred(Nbre)];
   moyenne := 0;
   Fntotal := 0;
   mediane := Donnees[0];
   Sigma := 0;
   if Nbre<2 then exit;
   for i := 0 to pred(Nbre) do begin
       Fntotal := Fntotal+round(effectif[i]);
       moyenne := moyenne+Effectif[i]*Donnees[i];
       sigma := sigma+Effectif[i]*sqr(Donnees[i]);
       if Donnees[i]<Min then Min := Donnees[i];
       if Donnees[i]>Min then Max := Donnees[i];
   end;
   iMilieu := Fntotal div 2;
   i := 0;
   n := 0;
   repeat
       n := n+round(effectif[i]);
       if n>=iMilieu
         then Mediane := Donnees[i]
         else inc(i);
   until n>=iMilieu;
   sigma := sqrt((sigma-sqr(moyenne)/Fntotal)/pred(Fntotal));
   moyenne := moyenne/Fntotal;
   t99 := Sigma*Student99(Fntotal-1)/sqrt(Fntotal);
   t95 := Sigma*Student95(Fntotal-1)/sqrt(Fntotal);
end;

Procedure CalculStatFrequence;
var i : integer;
begin
   min := Donnees[0];
   max := Donnees[pred(Nbre)];
   moyenne := 0;
   Fntotal := 1;
   Sigma := 0;
   if Nbre<2 then exit;
   for i := 0 to pred(Nbre) do begin
       moyenne := moyenne+Effectif[i]*Donnees[i];
       sigma := sigma+Effectif[i]*sqr(Donnees[i]);
       if Donnees[i]<Min then Min := Donnees[i];
       if Donnees[i]>Min then Max := Donnees[i];
   end;
   if FpourCent then begin
      moyenne := moyenne/100;
      sigma := sigma/100;
      Fntotal := 100;
   end;
   sigma := sqrt(sigma-sqr(moyenne));
   t99 := 3*Sigma;
   t95 := 2*Sigma;
   mediane := moyenne;
end;

Procedure CalculDistFrequence;
var i : integer;
begin
    NbreClasse := Nbre;
    ecartDist := (Max-Min)/(NbreClasse-1);
    DebutDist := Donnees[0];
    maxDist := 0;
    for i := 0 to pred(Nbre) do begin
          NbreDist[i] := Effectif[i];
          BornesDist[i] := Donnees[i];
          MoyDist[i] := Donnees[i];
          if Effectif[i]>maxDist then maxDist := Effectif[i];
          DistPourCent[i] := 100*NbreDist[i]/Ntotal;
    end;
    for i := Nbre to MaxHisto do begin
        NbreDist[i] := 0;
        MoyDist[i] := 0;
        DistPourCent[i] := 0;
    end;
end;

Procedure CalculDist;
var i,j : integer;
    k : integer;
    trouve : boolean;
    c,m : double;
begin
   if ClasseStat=csNombreImpose
      then begin
           ecartDist := (Max-Min)/NbreClasse;
           k := floor(log10(abs(ecartDist)));
           C := dix(1-k); // 2 chiffres pour l'amplitude
           EcartDist := floor(EcartDist*C)/C;
           M := round(Min*C)/C;
           DebutDist := M-ecartDist;
           if DataInteger then debutDist := ceil(debutDist)-0.5;
           for i:=0 to MaxHisto do
               BornesDist[i] := DebutDist+ecartDist*i;
      end
      else begin
         if ClasseStat=csAuto then begin
            EcartDist := sigma/2;
            if (ecartDist>2) then ecartDist := trunc(ecartDist);
            try
            k := floor(log10(abs(ecartDist)));
            C := dix(1-k); // 2 chiffres pour l'amplitude
            except
                C := 1;
            end;
            EcartDist := floor(EcartDist*C)/C;
            M := round(Moyenne*C)/C;
            DebutDist := M-ecartDist*MaxHisto/2;
            if ecartDist>=2 then DebutDist := round(debutDist);
         end;
         if ClasseStat=csSigma then begin
            EcartDist := sigma;
            DebutDist := Moyenne-ecartDist*MaxHisto/2;
         end;
         if dataInteger then debutDist := ceil(debutDist)-0.5;
         for i:=0 to MaxHisto do
             BornesDist[i] := DebutDist+ecartDist*i;
      end;
   for i:=0 to MaxHisto do begin
        NbreDist[i] := 0;
        MoyDist[i] := 0;
        DistPourCent[i] := 0;
   end;
   i := 0;
   for k:=0 to pred(Nbre) do begin
// rangement des données dans les intervalles
       trouve := Donnees[k]<=BornesDist[i];
       while (i<MaxHisto) and not trouve do begin
           inc(i);
           trouve := Donnees[k]<=BornesDist[i];
       end;
       if trouve then begin
           NbreDist[i] := NbreDist[i] + 1;
           MoyDist[i] := MoyDist[i]+Donnees[k];
       end;
   end;
   if ClasseStat<>csNombreImpose then begin
       i := 0;
       While NbreDist[i]=0 do inc(i);
       j := MaxHisto;
       While NbreDist[j]=0 do dec(j);
       NbreClasse := succ(j-i);
       if NbreClasse<3 then NbreClasse := 3;
   end;
   maxDist := 0;
   DistPourCent[0] := 100*NbreDist[0]/Ntotal;
   for i:=1 to MaxHisto do begin
       if NbreDist[i]>0
           then MoyDist[i] := MoyDist[i]/NbreDist[i]
           else MoyDist[i] := (BornesDist[pred(i)]+BornesDist[i])/2;
       if NbreDist[i]>maxDist then maxDist := round(NbreDist[i]);
       DistPourCent[i] := 100*NbreDist[i]/Ntotal;
   end;
   if (MaxDist<0.2*Nbre) and
      (ClasseStat<>csEcartImpose) then MaxDist := ceil(0.2*Nbre);
end; // CalculDist

Procedure CalculDistEffectif;
var i : integer;
begin
    NbreClasse := Nbre;
    ecartDist := (Max-Min)/(NbreClasse-1);
    DebutDist := Donnees[0];
    maxDist := 0;
    for i := 0 to pred(Nbre) do begin
        NbreDist[i] := Effectif[i];
        BornesDist[i] := Donnees[i];
        MoyDist[i] := Donnees[i];
        if Effectif[i]>maxDist then maxDist := ceil(Effectif[i]);
        DistPourCent[i] := 100*NbreDist[i]/Ntotal;
   end;
   for i := Nbre to MaxHisto do begin
        NbreDist[i] := 0;
        MoyDist[i] := 0;
        DistPourCent[i] := 0;
   end;
end;

Procedure TriDonnees;
{ Tri Shell Meyer-Baudoin p 456 }
{ origine vecteur en 0 ? }
var increment,k : integer;
    cle,sauveEffectif : double;
    i,j : integer;
Begin
   increment := 1;
   while (increment<(Nbre div 3)) do increment := succ(3*increment);
   repeat
     for k := 0 to pred(increment) do begin
       	  i := increment+k;
   	  while (i<Nbre) do begin
	  	  cle := Donnees[i];
        sauveEffectif := Effectif[i];
	  	  j := i-increment;
	  	  while (j>=0) and (donnees[j]>cle) do begin
               Donnees[j+increment] := Donnees[j];
               Effectif[j+increment] := Effectif[j];
               dec(j,increment);
  		  end;
        Donnees[j+increment] := cle;
        Effectif[j+increment] := sauveEffectif;
	  	  inc(i,increment);
	   end; { i>=nmes }
      end; { for k }
      increment := increment div 3;
   Until increment=0;
end; // triDonnees

var SauveData,SauveEff : vecteur;
begin
     statOK := Nbre>2;
     if not StatOK then exit;
     if not avecTri then begin
        copyVecteur(sauveData,Donnees);
        copyVecteur(sauveEff,Effectif);
     end;
     try
     TriDonnees;
     case classeStat of
        csEffectifDonne : begin
           statOK := TestEffectif;
           if statOK then begin
                calculStatEffectif;
                calculDistEffectif;
           end;
        end;
        csFrequenceDonnee : begin
           statOK := TestFrequence;
           if statOK then begin
                calculStatFrequence;
                calculDistFrequence;
           end;
        end
        else begin
           testDataEntier;
           calculStat;
           calculDist;
        end;
     end;
     if not avecTri then begin
         copyVecteur(Donnees,sauveData);
         copyVecteur(Effectif,sauveEff);
         SauveData := nil;
         SauveEff := nil;
     end;
     except
        statOK := false;
        t99 := 1;
        t95 := 1;
     end;
end; // Calcul

destructor TcalculStatistique.Destroy;
begin
     MoyDist := nil;
     NbreDist := nil;
     DistPourCent := nil;
     BornesDist := nil;
     donnees := nil;
     effectif := nil;
     inherited destroy;
end;

Procedure TcalculStatistique.SetValeur(Valeur : vecteur;Nmes : integer;wTri : boolean);
begin
     FNbre := Nmes;
     CopyVecteur(Donnees,Valeur);
     setLength(effectif,Puiss2Sup(length(valeur)));
     AvecTri := wTri;
     Calcul;
end;

Procedure CalcCornish(X,Y : vecteur;N : integer;var K,V : vecteur;var Nbre : integer);
var i,j,m : integer;
    Denom : double;
begin
    m := 0;
    for i := 0 to pred(N) do begin
        for j := succ(i) to pred(N) do begin
            try
            Denom := -X[i]*Y[j]+X[j]*Y[i];
            K[m] := X[i]*X[j]*(Y[j]-Y[i])/denom;
            V[m] := Y[i]*Y[j]*(X[j]-X[i])/denom;
            inc(m);
            if m=high(K) then break;
            except
            end;
        end;
        if m=high(K) then break;
    end;
    Nbre := m;
end;

Procedure TstatistiqueDeuxVar.Init(ax,ay : vecteur;debut,fin : integer);
var i : integer;
    xsigma,ysigma : double;
begin
    X := ax;
    Y := ay;
    try
    Sx := 0;Sy := 0;
    Sx2 := 0;Sy2 := 0;
    Nbre := succ(Fin-Debut);
    for i := Debut to Fin do begin
       Sx := Sx+X[i];Sy := Sy+Y[i];
       Sx2 := Sx2+sqr(X[i]);Sy2 := Sy2+sqr(Y[i]);
    end;
    Sxx := sx2-sqr(sx)/Nbre;
    Syy := sy2-sqr(sy)/Nbre;
    Xsigma := sqrt(Sxx/pred(Nbre));
    Ysigma := sqrt(Syy/pred(Nbre));
    Xmoyen := Sx/Nbre;Ymoyen := Sy/Nbre;
    Covariance := 0;
    for  i := Debut to Fin do
      Covariance := Covariance+(X[i]-Xmoyen)*(Y[i]-Ymoyen);
    Covariance := Covariance/pred(Nbre);
    Fcorrelation := Covariance/Xsigma/Ysigma;
    PenteY := Fcorrelation*Ysigma/Xsigma;
    Y0 := Ymoyen-PenteY*Xmoyen;
    SSR := sqr(PenteY)*Sxx;
    SSE := Syy-SSR;
    sigma := sqrt(SSE/(Nbre-2));
    FFisher := SSR*(Nbre-2)/SSE;
    // interprétable comme r^2*(n-2)/(1-r^2)
    except
      Fcorrelation := Nan;
      FFisher := Nan;
    end;
end; // Calcul stat deux variables

Procedure CalcCornishInters(X,Y : vecteur;N : integer;var Km,Vm : double);
var i,imax : integer;
    K,V : vecteur;
    Kmax,Vmax : double;
begin
    setLength(K,N+1);
    setLength(V,N+1);
    CalcCornish(X,Y,N,K,V,imax);
    Km := 0;
    Vm := 0;
    for i := 0 to pred(imax) do begin
        Km := Km + K[i];
        Vm := Vm + V[i];
    end;
    Kmax := 0;
    Vmax := 0;
    for i := 2 to imax-3 do begin
        if K[i]>Kmax then Kmax := K[i];
        if V[i]>Vmax then Vmax := V[i];
    end;
    Km := Km/imax;
    Vm := Vm/imax;
    if (Kmax-Km)<Km*0.4
       then Km := -Kmax
       else Km := -Km*1.2;
    if (Vmax-Vm)<Vm*0.4
       then Vm := -Vmax
       else Vm := -Vm*1.2;
    K := nil;
    V := nil;
end;

procedure TcalculStatistique.setNbre(Anbre : integer);
begin
     if (classeStat=csEffectifDonne) and
        (Anbre>MaxVecteurDefaut) then Anbre := MaxVecteurDefaut;
     if ANbre>MaxMaxVecteur then ANbre := MaxMaxVecteur;
     if ANbre>Fnbre then begin
        setLength(donnees,Puiss2Sup(Anbre));
        setLength(effectif,Puiss2Sup(Anbre));
     end;
     Fnbre := Anbre;
end;

Procedure TcalculStatistique.SetValeurEffectif(Valeur,ValEff : vecteur;Nmes : integer);
var i : integer;
begin
     Nbre := Nmes;
     for i := 0 to pred(FNbre) do begin
         Donnees[i] := Valeur[i];
         Effectif[i] := ValEff[i];
     end;
     AvecTri := true;
     Calcul;
end;

Procedure TstatistiqueDeuxVar.yConfidence(x,y : double;var maxM,minM,maxI,minI : double);
var ecartMean,ecartIndividual,st,zz : double;
begin
    st := student95(Nbre-2)*sigma;
    zz := 1/Nbre+sqr(x-xmoyen)/Sxx;
    ecartMean := st*sqrt(zz);
    ecartIndividual := st*sqrt(1+zz);
    maxM := y+ecartMean;
    minM := y-ecartMean;
    maxI := y+ecartIndividual;
    minI := y-ecartIndividual;
end;

Procedure TstatistiqueDeuxVar.GenereBande(X,Y : TvecteurExtrapole;Nbande : integer);
var i : integer;
    j : codeIntervalle;
begin
   for i := 0 to Nbande do begin
       for j := 2 to maxIntervalles do x[j,i] := x[1,i];
       yConfidence(x[1,i],y[1,i],y[1,i],y[2,i],y[3,i],y[4,i]);
   end;{i}
end;{ GenereBande }

Procedure TcalculStatistique.TestDataEntier;
Var i,n : integer;
begin
       DataInteger := true;
       for i := 0 to pred(Fnbre) do begin
           if not IsEntier(donnees[i],n) then begin
                DataInteger := false;
                break;
           end;     // indexEffectif non entier donc pas un effectif
      end;
end;

Function TcalculStatistique.TestEffectif : boolean;
Var i,j,n : integer;
begin
       result := true;
       for i := 0 to pred(Fnbre) do begin
           if not IsEntier(effectif[i],n) then begin
                result := false;
                break;
           end;
           for j := 0 to pred(i) do
               if donnees[i]=donnees[j] then begin
                  result := false;
                  break;
               end; // doublon indexStat donc pas une variable
       end;
end;

Function TcalculStatistique.TestFrequence : boolean;
Var i : integer;
    total : double;
begin
       result := false;
       total := 0;
       for i := 0 to pred(Fnbre) do
           total := total + effectif[i];
       if abs(total-1)<0.01 then begin
          result := true;
          FpourCent := false;
       end;
       if abs(total-100)<1 then begin
          result := true;
          FpourCent := true;
       end;
end;

end.


