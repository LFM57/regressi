unit selpage;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Controls.Presentation,

  compile,
  images;

type
  TSelectPageDlg = class(TForm)
    ButtonPanel: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    AllBtn: TButton;
    OneBtn: TButton;
    StatusBar: TStatusBar;
    AllOKBtn: TButton;
    OneOKBtn: TButton;
    CheckListBox: TListBox;
    procedure OKBtnClick(Sender: TObject);
    procedure AllBtnClick(Sender: TObject);
    procedure OneBtnClick(Sender: TObject);
    procedure AllOKBtnClick(Sender: TObject);
    procedure OneOKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    appelPrint : boolean;
  end;

var
  SelectPageDlg: TSelectPageDlg;

implementation

uses regutil, Regmain;

{$R *.FMX}

procedure TSelectPageDlg.FormShow(Sender: TObject);
var p : integer;
    hauteur : integer;
    LabelConst : string;
begin
     inherited;
     CheckListBox.clear;
     for p := 1 to NbrePages do with pages[p] do begin
         labelConst := '';
         CheckListBox.Items.Add(IntToStr(p)+' : '+labelConst+commentaireP);
         CheckListBox.ListItems[p-1].ischecked := active;
     end;
     hauteur := NbrePages*22+60;
     if statusBar.isVisible
        then begin
           hauteur := hauteur + 30;
           if hauteur<260 then hauteur := 260;
        end
        else if hauteur<240 then hauteur := 240;
     if hauteur>420
         then height := 420
         else height := hauteur;
end;

procedure TSelectPageDlg.OKBtnClick(Sender: TObject);
var p : codePage;
    N : integer;
begin
     N := 0;
     for p := 1 to NbrePages do begin
         pages[p].active := CheckListBox.ListItems[p-1].isChecked;
         if pages[p].active then inc(N);
     end;
     if N=0 then pages[pageCourante].active := true;
     if not pages[pageCourante].active then begin
        p := 1;
        while (p<NbrePages) and not pages[p].active do inc(p);
        pageCourante := p;
     end;
     FRegressiMain.WMRegMaj(MajSelectPage);
end;

procedure TSelectPageDlg.AllBtnClick(Sender: TObject);
var p : codePage;
begin
     for p := 1 to NbrePages do
         CheckListBox.ListItems[p-1].isChecked := true;
end;

procedure TSelectPageDlg.OneBtnClick(Sender: TObject);
var p : codePage;
begin
     for p := 1 to NbrePages do
         CheckListBox.ListItems[p-1].isChecked := false;
     CheckListBox.ListItems[pageCourante-1].isChecked := true;
end;

procedure TSelectPageDlg.AllOKBtnClick(Sender: TObject);
var p : codePage;
begin
     for p := 1 to NbrePages do pages[p].active := true;
     FRegressiMain.WMRegMaj(MajSelectPage);
end;

procedure TSelectPageDlg.OneOKBtnClick(Sender: TObject);
var p : codePage;
begin
     for p := 1 to NbrePages do pages[p].active := false;
     pages[pageCourante].active := true;
     FRegressiMain.WMRegMaj(MajSelectPage);
end;

end.
