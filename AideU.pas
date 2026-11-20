// This software is Copyright (c) 2015 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

unit AideU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Edit,
  FMX.WebBrowser, FMX.Layouts, FMX.Controls.Presentation,
  regutil;

type
  TAideForm = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure WebBrowser1DidFailLoadWithError(ASender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FHelpContext: Integer;
  public
    property HelpContext: Integer read FHelpContext write FHelpContext;
  end;

var
  AideForm: TAideForm;

procedure ShowAide(AContext: Integer = 0; AModal: Boolean = False);

implementation

{$R *.fmx}

procedure ShowAide(AContext: Integer = 0; AModal: Boolean = False);
begin
  if AideForm = nil then
    Application.CreateForm(TAideForm, AideForm);
  AideForm.HelpContext := AContext;
  CentreForm(AideForm);
  if AModal then
    AideForm.ShowModal
  else
    AideForm.Show;
end;

procedure TAideForm.FormActivate(Sender: TObject);
begin
    WebBrowser1.URL := HelpHtml;
end;

procedure TAideForm.WebBrowser1DidFailLoadWithError(ASender: TObject);
begin
    showMessage('Impossible de trouver '+HelpHtml)
end;


end.
