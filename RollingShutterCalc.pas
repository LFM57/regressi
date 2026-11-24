unit RollingShutterCalc;

interface

uses system.Types, fmx.graphics, system.Classes, system.sysUtils,
     fmx.utils,
     regutil, math, compile, maths;

const
   NPointsMax = 3;
   maxVecteurVideo = 1024;
   maxPixelCount = 32767;
   crTab = #9;

type
  indicePoint = 1..NPointsMax;
  TCorrectionRS = class
      private
          FRSValue : double;
          FNbre : integer;
          FNbrePoints : integer;
          FHauteur : integer;
          FangleX : double;
          FEchelle : double;
          FSigneY : double;
          FincertXY : integer; // en pixel
          FCorrigePosition : boolean;
          procedure setRSValue(avalue : double);
      public
      XYc : array[indicePoint,0..MaxVecteurVideo] of TpointF;
      XY : array[indicePoint,0..MaxVecteurVideo] of TpointF;
      x0,y0 : single;
      Temps : array[0..MaxVecteurVideo] of double;
      TempsRS : array[indicePoint,0..MaxVecteurVideo] of double;  // Rolling Shutter
      procedure CalculRollingShutter;
      procedure SauveData;
      Function valeurXc(j,i : integer) : double;
      Function valeurYc(j,i : integer) : double;
      Function valeurTc(j,i : integer) : double;
      Function valeurX(j,i : integer) : double;
      Function valeurY(j,i : integer) : double;
      Function valeurT(i : integer) : double;
      procedure Interpole(jdebut,jfin,j0,index : integer);
      property RSvalue : double write setRSValue;
      property nmes : integer write FNbre;
      property NbrePoints : integer write FNbrePoints;
      property hauteur : integer write FHauteur;
      property angleX : double write FangleX;
      property echelle : double write FEchelle;
      property incertXY : integer write FIncertXY;
      property signeY : double write FsigneY;
      property corrigePosition : boolean write FcorrigePosition;
      constructor create;
  end;

var correctionRS : TCorrectionRS;

implementation

uses regmain, grapheVariabU, graphker;

const
   degreLissage = 2;
   ordre = degreLissage+1;
   puissMax = 2*degreLissage;

type
   vectorPuiss = array[0..puissMax] of double;

constructor TCorrectionRS.create;
begin
    FCorrigePosition := true;
    FangleX := 0;
    FRSValue := 0;
    FSigneY := -1;
    FNbrePoints := 1;
    FincertXY := 1; // pixel
end;

procedure TCorrectionRS.interpole(jdebut,jfin,j0,index : integer);
var puissX,puissY : vectorPuiss;
    Ax,Ay : matrice;
    CoeffX,coeffY : matriceLigne;

procedure initXY;
var j : integer;
    locX,locY,locT,t : double;
    i : integer;
begin
    for i := 0 to puissMax do begin
        puissX[i] := 0;
        puissY[i] := 0;
    end;
    for i := 1 to ordre do begin
        Ax[i,ordre+1] := 0;
        Ay[i,ordre+1] := 0;
    end;
    for j := jdebut to jfin do begin
        t := tempsRS[index,j];
        locT := t;
        for i := 1 to puissMax do begin
            puissX[i] := puissX[i]+locT;
            puissY[i] := puissY[i]+locT;
            locT := locT*t;
        end;
        locX := xy[index,j].x;
        locY := xy[index,j].y;
        for i := 1 to ordre do begin
            Ax[i,ordre+1] := Ax[i,ordre+1]+locX;
            Ay[i,ordre+1] := Ay[i,ordre+1]+locY;
            locX := locX*t;
            locY := locY*t;
        end;
        puissX[0] := puissX[0] + 1;
        puissY[0] := puissY[0] + 1;
    end;
    for i := 1 to ordre do
        for j := 1 to ordre do begin
            Ax[i,j] := PuissX[i+j-2];
            Ay[i,j] := PuissY[i+j-2];
        end;
end;

var t0 : double;
begin
    initXY;
    try
    maths.Resolution(Ax,ordre,Coeffx);
    maths.Resolution(Ay,ordre,Coeffy);
    t0 := tempsRS[1,j0];
    xyC[index,j0].x := coeffX[1]+t0*(coeffX[2]+coeffX[3]*t0);
    xyC[index,j0].y := coeffY[1]+t0*(coeffY[2]+coeffY[3]*t0);
    except
    end;
end; // Interpole

procedure TCorrectionRS.CalculRollingShutter;
var i, j: integer;
begin
     if (FRSValue=0) or (FNbre<3) then begin
        for i := 0 to pred(FNbre) do
            for j := 1 to FNbrePoints do begin
                xyC[j,i] := xy[j,i];
                if (FRSValue<>0) and (Fhauteur<>0)
                   then tempsRS[j,i] := (temps[i]-temps[0])+FRSValue*xy[j,i].y/Fhauteur
                   else tempsRS[j,i] := temps[i]-temps[0];
            end;
     end
     else begin
         for i := 0 to pred(FNbre) do
         for j := 1 to FNbrePoints do
             tempsRS[j,i] := (temps[i]-temps[0])+FRSValue*xy[j,i].y/Fhauteur;
         for j := 1 to FNbrePoints do
         if j=1
         then begin // pour le 1, on garde le point et on change le temps
            for i := 0 to pred(FNbre) do
                xyC[1,i] := xy[1,i]; // passage Tpoint integer à TpointF single ?
         end
         else begin
             interpole(0,2,0,j);
             for i := 1 to (FNbre-2) do
                 interpole(i-1,i+1,i,j);
             interpole(FNbre-3,FNbre-1,FNbre-1,j);
         end;
     end;
end;

function TCorrectionRS.valeurXc(j,i : integer) : double;
begin
    result := (xyC[j,i].x-x0)*cos(FangleX)-(xyC[j,i].y-y0)*sin(-FangleX);
    result := result * FEchelle;
end;

function TCorrectionRS.valeurYc(j,i : integer) : double;
begin
    result := (xyC[j,i].x-x0)*sin(-FangleX)+(xyC[j,i].y-y0)*cos(FangleX);
    result := result * FEchelle * FsigneY;
end;

function TCorrectionRS.valeurTc(j,i : integer) : double;
begin
    result := (temps[i]-temps[0])+FRSValue*xy[j,i].y/Fhauteur;
end;

function TCorrectionRS.valeurX(j,i : integer) : double;
begin
    result := (xy[j,i].x-x0)*cos(FangleX)-(xy[j,i].y-y0)*sin(-FangleX);
    result := result * FEchelle;
end;

function TCorrectionRS.valeurY(j,i : integer) : double;
begin
    result := (xy[j,i].x-x0)*sin(-FangleX)+(xy[j,i].y-y0)*cos(FangleX);
    result := result * FEchelle * FsigneY;
end;

function TCorrectionRS.valeurT(i : integer) : double;
begin
    result := temps[i]-temps[0];
end;


procedure TCorrectionRS.setRSValue(avalue : double);
begin
    FRSValue := aValue/1000; // conversion ms / s
end;

procedure TcorrectionRS.SauveData;
var
    indexX,indexY : array[indicePoint] of integer;
    indexT : integer;
    incertTemps : double;
    incertEspace : double;

function Ajoute(nom,unite : string) : codeGrandeur;
var  v : codeGrandeur;
begin
      v :=indexNom(nom);
      if v=grandeurInconnue then begin
         v := ajouteExperimentale(Nom,variable);
         grandeurs[v].fonct.expression := '';
         grandeurs[v].NomUnite := unite;
      end;
      result := v;
end;


procedure SauvePosition;
var i,j : integer;
begin
       pages[pageCourante].nmes := FNbre;
       indexT := ajoute('t','s');
       if FNbrepoints=1
          then begin
             indexX[1] := ajoute('x','m');
             indexY[1] := ajoute('y','m');
          end
          else for j := 1 to FNbrePoints do begin
              indexX[j] := ajoute('x'+intToStr(j),'m');
              indexY[j] := ajoute('y'+intToStr(j),'m');
          end;
       grandeurs[indexT].fonct.expression := 'Temps';
       for j := 1 to FNbrePoints do begin
           grandeurs[indexX[j]].fonct.expression := 'Abscisse';
           grandeurs[indexY[j]].fonct.expression := 'Ordonnée';
       end;
       for i := 0 to pred(FNbre) do begin
           pages[pageCourante].valeurVar[indexT,i] := valeurTc(1,i);
           for j := 1 to FNbrepoints do begin
                pages[pageCourante].valeurVar[indexX[j],i] := valeurXc(j,i);
                pages[pageCourante].valeurVar[indexY[j],i] := valeurYc(j,i);
           end;
       end;
       incertTemps := (temps[1]-temps[0])/100;
       incertEspace := FIncertXY*abs(FEchelle);
       if FIncertXY>0 then begin
             for i := 0 to pred(FNbre) do begin
                 pages[pageCourante].incertVar[indexT,i] := incertTemps;
                 for j := 1 to FNbrePoints do begin
                     pages[pageCourante].incertVar[indexX[j],i] := incertEspace;
                     pages[pageCourante].incertVar[indexY[j],i] := incertEspace;
                 end;
             end;
       end;
end; // SauvePosition

begin
       calculRollingShutter;
       ajoutePage;
       sauvePosition;
       graphe.coordonnee[1].nomX := grandeurs[indexX[1]].nom;
       graphe.coordonnee[1].nomY := grandeurs[indexY[1]].nom;
       include(graphe.OptionGraphe,OgOrthonorme);
       graphe.configCharge := true;
       graphe.useDefaut := false;
       modeAcquisition := acqVideo;
end; // SauveData

initialization
     correctionRS := TCorrectionRS.create;
finalization
     correctionRS.free;
end.
