(*
  * Copyright (c) 2024 TikoTako (https://github.com/TikoTako)
  * All rights reserved.
  *
  * The original code can be found at:
  * https://github.com/TikoTako/SilentStreamFixer
  *
  * This source code is licensed under the BSD 3-Clause License
  * found in the LICENSE file.
  *
  * You may also obtain a copy of the License at:
  * https://raw.githubusercontent.com/TikoTako/SilentStreamFixer/master/LICENSE
*)

program SilentStreamFixer;

{$R *.dres}

uses
  WinAPI.MMSystem,
  System.Classes, System.SysUtils,
  vcl.Forms, vcl.Menus, vcl.ExtCtrls;

{$R *.res}

type
  TFormHelper = class helper for TForm
    procedure aPopUpMenuClick(aSender: TObject);
  end;

function CreateMenuItem(aOwner: TComponent; aCaption: string; aProcedure: TNotifyEvent): TMenuItem;
begin
  result := TMenuItem.Create(aOwner);
  if Assigned(aProcedure) then
    result.OnClick := aProcedure;
  result.Caption := aCaption;
end;

procedure TFormHelper.aPopUpMenuClick(aSender: TObject);
var
  vMenuItem: TMenuItem;
begin
  vMenuItem := TMenuItem(aSender);

  if vMenuItem.Caption.Equals('Start') then
  begin
    vMenuItem.Caption := 'Stop';
    PlaySound({$IFDEF DEBUG} 'DEBUG' {$ELSE} 'EMPTY' {$ENDIF}, HInstance, SND_LOOP or SND_ASYNC or SND_RESOURCE);
    with TTrayIcon(FindComponent('vTrayIcon')) do
    begin
      Visible := False;
      Icon.LoadFromResourceName(HInstance, 'OK');
      Visible := True;
    end;
  end
  else if vMenuItem.Caption.Equals('Stop') then
  begin
    vMenuItem.Caption := 'Start';
    PlaySound(nil, HInstance, SND_ASYNC);
    with TTrayIcon(FindComponent('vTrayIcon')) do
    begin
      Visible := False;
      Icon.LoadFromResourceName(HInstance, 'NOT_DAIJOUBU');
      Visible := True;
    end;
  end
  else if vMenuItem.Caption.Equals('Exit') then
  begin
    Close;
  end;
end;

var
  vForm: TForm;
  vTrayIcon: TTrayIcon;
  vPopupMenu: TPopupMenu;
begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.ShowMainForm := False;
  Application.CreateForm(TForm, vForm);

  vPopupMenu := TPopupMenu.Create(vForm);
  vPopupMenu.AutoHotkeys := maManual;
  vPopupMenu.Items.Add(
    //
    [CreateMenuItem(vPopupMenu, 'Start', vForm.aPopUpMenuClick),
    //
    CreateMenuItem(vPopupMenu, '-', nil),
    //
    CreateMenuItem(vPopupMenu, 'Exit', vForm.aPopUpMenuClick)]);

  vTrayIcon := TTrayIcon.Create(vForm);
  vTrayIcon.Name := 'vTrayIcon';
  vTrayIcon.PopupMenu := vPopupMenu;
  vTrayIcon.PopupMenu.Items[0].Click;
  // vTrayIcon.Visible := True;

  Application.Run;
end.
