unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, IdContext,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdSocksServer,
  json, strutils, ShellApi, Vcl.ComCtrls, Winsocket, System.RegularExpressions,
  System.NetEncoding, Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.json.Builders, System.json.Types, IdTCPServer;

type
  wsSt = (disconnet, conn, reconn, off, connecting, start);

type
  TwsInfo = record
    id, name, wa_version, device_model: string;
  end;

type
  Tprincipal = class(TForm)
    DSMessagees: TDataSource;
    MSendMessage: TFDMemTable;
    MSendMessageintent: TIntegerField;
    MSendMessageserNo: TIntegerField;
    MSendMessageto: TStringField;
    MSendMessagetype: TStringField;
    MSendMessagestatus: TStringField;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Pevent: TPanel;
    memo1: TRichEdit;
    Panel1: TPanel;
    clearLog: TButton;
    Panel3: TPanel;
    Label3: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    lbStatus: TLabel;
    lbws: TLabel;
    lbInfo: TLabel;
    Panel2: TPanel;
    resetWS: TButton;
    logOut: TButton;
    PCcenter: TPageControl;
    TabQueue: TTabSheet;
    DBGrid1: TDBGrid;
    TabQR: TTabSheet;
    QrPanel: TPanel;
    PaintBox1: TPaintBox;
    TSConfig: TTabSheet;
    configSC: TScrollBox;
    webhook: TPanel;
    Panel11: TPanel;
    pushMessage: TLabeledEdit;
    wsRest: TLabeledEdit;
    port: TLabeledEdit;
    serverSocket: TLabeledEdit;
    getMessage: TLabeledEdit;
    company: TPanel;
    Panel5: TPanel;
    compName: TLabeledEdit;
    compId: TLabeledEdit;
    sucId: TLabeledEdit;
    count: TPanel;
    Timer1: TTimer;
    clearChats: TPanel;
    Panel6: TPanel;
    hora: TLabeledEdit;
    active: TCheckBox;
    clearChat: TButton;
    Label1: TLabel;
    semana: TLabeledEdit;
    showConsole: TCheckBox;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure OnClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure memo1Change(Sender: TObject);
    procedure clearLogClick(Sender: TObject);
    procedure resetWSClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure logOutClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure clearChatClick(Sender: TObject);

  private
    { Private declarations }
    QRCodeBitmap: TBitmap;
    lastQr, Data: string;
    socketServer: TServerSocket;
    wsInfo: TwsInfo;
    Socket_act: TCustomWinSocket;
    SI: TStartupInfo;
    PI: TProcessInformation;

    procedure update;
    procedure onQr(value: TJSONValue);
    procedure onMsg(value: TJSONValue);
    procedure onConnet(value: TJSONValue);
    procedure initNode();
    procedure initSocket();
    procedure wsSttus(const t: wsSt);
    procedure readConfig;
    procedure createConfig;
    procedure loadConfig(Data: string);
    procedure loadQueue(Data: TJSONArray);
    procedure QueueStatus(Data: TJSONValue);

  public
    { Public declarations }

  end;

var
  principal: Tprincipal;

implementation

{$R *.dfm}

uses QR, System.json.Writers, System.json.Readers;

{ TForm1 }

procedure Tprincipal.Button1Click(Sender: TObject);
begin
  createConfig;
  resetWS.OnClick(resetWS)
end;

procedure Tprincipal.resetWSClick(Sender: TObject);
var
  StringWriter: TStringWriter;
  Writer: TJsonTextWriter;
begin
  if Socket_act <> nil then
  begin

    StringWriter := TStringWriter.Create();
    Writer := TJsonTextWriter.Create(StringWriter);

    with TJSONObjectBuilder.Create(Writer) do
      try

        BeginObject.Add('type', 'reset').Add('data', 'null').EndObject;

        Socket_act.SendText('data:' + TBase64Encoding.Base64.Encode
          (StringWriter.ToString) + #$A#$A);

      finally
        Free;
        StringWriter.Free;
        Writer.Free;
      end;

  end;

end;

procedure Tprincipal.logOutClick(Sender: TObject);
var
  StringWriter: TStringWriter;
  Writer: TJsonTextWriter;
begin
  if MessageDlg('Esto desloguea este app de whatsApp, deseas hacerlo?',
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    if Socket_act <> nil then
    begin

      StringWriter := TStringWriter.Create();
      Writer := TJsonTextWriter.Create(StringWriter);

      with TJSONObjectBuilder.Create(Writer) do
        try
          BeginObject.Add('type', 'logOut').Add('data', 'null').EndObject;
          Socket_act.SendText('data:' + TBase64Encoding.Base64.Encode
            (StringWriter.ToString) + #$A#$A);

        finally
          Free;
          StringWriter.Free;
          Writer.Free;
        end;

    end;
  end;

end;

procedure Tprincipal.clearChatClick(Sender: TObject);
var
  StringWriter: TStringWriter;
  Writer: TJsonTextWriter;
begin
  if Socket_act <> nil then
  begin

    StringWriter := TStringWriter.Create();
    Writer := TJsonTextWriter.Create(StringWriter);

    with TJSONObjectBuilder.Create(Writer) do
      try

        BeginObject.Add('type', 'clearChats').Add('data', 'null').EndObject;

        Socket_act.SendText('data:' + TBase64Encoding.Base64.Encode
          (StringWriter.ToString) + #$A#$A);

      finally
        Free;
        StringWriter.Free;
        Writer.Free;
      end;

  end;
end;

procedure Tprincipal.clearLogClick(Sender: TObject);
begin
  memo1.Lines.Clear;
end;

procedure Tprincipal.createConfig;
var
  I, X: Integer;

  StringWriter: TStringWriter;
  Writer: TJsonTextWriter;
  Builder: TJSONObjectBuilder;
  json: TJSONObjectBuilderPairs;
  StreamWriter: TStreamWriter;
  dir: string;
begin

  StringWriter := TStringWriter.Create();
  Writer := TJsonTextWriter.Create(StringWriter);
  Builder := TJSONObjectBuilder.Create(Writer);
  dir := ExtractFileDir(Application.ExeName);
  dir := ExpandFileName(dir + '\config.json ');
  json := Builder.BeginObject;

  for I := 0 to configSC.ControlCount - 1 do
  begin
    if configSC.Controls[I] is TPanel then
    begin
      json.BeginObject(configSC.Controls[I].Name);
      for X := 0 to (configSC.Controls[I] as TPanel).ControlCount - 1 do
      begin
        if (configSC.Controls[I] as TPanel).Controls[X] is TLabeledEdit then
        begin
          json.Add(((configSC.Controls[I] as TPanel).Controls[X]
            as TLabeledEdit).Name,
            ((configSC.Controls[I] as TPanel).Controls[X] as TLabeledEdit).Text)
        end
        else if (configSC.Controls[I] as TPanel).Controls[X] is TCheckBox then
        begin
          json.Add(((configSC.Controls[I] as TPanel).Controls[X] as TCheckBox)
            .Name, ((configSC.Controls[I] as TPanel).Controls[X]
            as TCheckBox).Checked)
        end;

      end;
      json.EndObject

    end;

  end;
  json.EndObject;
  if FileExists(dir) then
  begin
    DeleteFile(dir)
  end;
  StreamWriter := TStreamWriter.Create(dir, false, TEncoding.ASCII);
  StreamWriter.Write(StringWriter.ToString);

  StreamWriter.Free;
  Builder.Free;
  StringWriter.Free;
end;

procedure Tprincipal.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if (Sender as TDBGrid).DataSource.DataSet.FieldByName('status').AsString = 'success'
  then
  begin
    // change color of row
    DBGrid1.Canvas.Brush.Color := $009DFFCE;
    DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end
  else if (Sender as TDBGrid).DataSource.DataSet.FieldByName('status')
    .AsString = 'sending...' then
  begin
    // change color of row
    DBGrid1.Canvas.Brush.Color := clYellow;
    DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end
  else if (Sender as TDBGrid).DataSource.DataSet.FieldByName('status').AsString
    <> 'Queue' then
  begin
    // change color of row
    DBGrid1.Canvas.Brush.Color := clRed;
    DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end

end;

procedure Tprincipal.FormCreate(Sender: TObject);
begin
  readConfig;
  wsSttus(start);
  initSocket;

end;

procedure Tprincipal.initNode;
var
  api, node, dir, env: string;
  status: boolean;

begin

  dir := ExtractFileDir(Application.ExeName);
  api := 'index.js'; // ExtractFileDir(dir + '.\index.js ');
  node := ExpandFileName(dir + '.\node.exe ');
  env := 'SET PORT=' + socketServer.port.ToString;

  // ShellExecute(0, nil, pchar('cmd.exe /C ' +node), pchar(api), nil, SW_NORMAL);
  with SI do
  begin
    FillChar(SI, SizeOf(SI), 0);
    cb := SizeOf(SI);
    dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    if showConsole.Checked then
      wShowWindow := SW_NORMAL
    else
      wShowWindow := SW_HIDE;
    hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin

  end;
  status := CreateProcess(nil, PChar('cmd.exe /C ' + env + '&"' + node + '" ' +
    api), nil, nil, true, 0, nil, nil, SI, PI);

end;

procedure Tprincipal.initSocket;
var
  _open: boolean;
  port: Integer;
begin

  // open socket
  port := 50000;
  socketServer := TServerSocket.Create(Self);
  _open := false;

  socketServer.OnClientRead := ServerSocket1ClientRead;
  socketServer.OnClientDisconnect := ServerSocket1ClientDisconnect;
  socketServer.OnClientConnect := OnClientConnect;

  while not _open do
  begin
    try
      socketServer.port := port;
      socketServer.active := true;
      _open := true
    except
      on E: ESocketError do
      begin
        inc(port)
      end;
    end;
  end;
  initNode;

end;

procedure Tprincipal.loadConfig(Data: string);
var
  jtr: TJsonTextReader;
  sr: TStringReader;
  component: TComponent;
  key: string;
  value: variant;

begin
  sr := TStringReader.Create(Data);
  jtr := TJsonTextReader.Create(sr);
  while jtr.Read do
  begin
    value := jtr.value.asvariant;
    if jtr.TokenType = TJsonToken.PropertyName then
    begin
      key := jtr.value.ToString;

      component := FindComponent(key);
      if component is TLabeledEdit then
      begin
        jtr.Read;
        value := jtr.value.asvariant;
        TLabeledEdit(component).Text := value
      end
      else if component is TCheckBox then
      begin
        jtr.Read;
        value := jtr.value.asvariant;
        TCheckBox(component).Checked := value
      end;

    end

  end;

end;

procedure Tprincipal.loadQueue(Data: TJSONArray);
var
  json: TJSONValue;
  I: Integer;
  ser_no, username, media_type: string;
begin

  for I := 0 to Data.count - 1 do
  begin
    json := Data.Items[I];
    ser_no := json.GetValue<string>('ser_no');
    media_type := json.GetValue<string>('media_type');
    username := json.GetValue<string>('username');
    with MSendMessage do
    begin
      Open;
      if not Locate('serNo', ser_no) then
      begin
        insert;
        MSendMessageintent.value := 0;
        MSendMessageserNo.value := ser_no.ToInteger;
        MSendMessageto.value := username;
        MSendMessagetype.value := media_type;
        MSendMessagestatus.value := 'Queue';
        Post;

      end;

    end;

  end;

end;

procedure Tprincipal.QueueStatus(Data: TJSONValue);
var
  I: Integer;
  ser_no, status, intent: string;
begin

  ser_no := Data.GetValue<string>('ser_no');
  status := Data.GetValue<string>('status');
  intent := Data.GetValue<string>('intent');

  with MSendMessage do
  begin
    Open;
    if Locate('serNo', ser_no) then
    begin
      Edit;
      MSendMessageintent.value := intent.ToInteger;
      MSendMessagestatus.value := status;
      Post;
    end;
    if not Timer1.Enabled then
      Timer1.Enabled := true;

  end;

end;

procedure Tprincipal.memo1Change(Sender: TObject);
begin
  SendMessage(memo1.handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure Tprincipal.onMsg(value: TJSONValue);
var
  id, remoteJid, messageType, Data: string;
begin
  value := value.FindValue('data');
  id := value.GetValue<string>('id');
  remoteJid := value.GetValue<string>('remoteJid');
  messageType := value.GetValue<string>('messageType');
  Data := value.GetValue<string>('data');

  memo1.Lines.Add(#$A);
  memo1.Lines.Add('new message at ' + FormatDateTime('hh:mm:ss', now) + '');
  memo1.Lines.Add(Concat('id', '         :', id));
  memo1.Lines.Add(Concat('remoteJid', '  :', remoteJid));
  memo1.Lines.Add(Concat('data', '       :', Data));
  memo1.Lines.Add(Concat('messageType', ':', messageType));
  memo1.Lines.Add('-------------------------------------------------');

end;

procedure Tprincipal.onConnet(value: TJSONValue);
begin

  TabQueue.TabVisible := true;
  TabQR.TabVisible := false;
  PCcenter.ActivePageIndex := 0;
  Pevent.Visible := true;
  memo1.Lines.Clear;

  value := value.FindValue('data');
  wsInfo.id := TRegEx.Replace(value.GetValue<string>('jid'), '[^0-9]', '');;
  wsInfo.Name := value.GetValue<string>('name');
  value := value.FindValue('phone');
  wsInfo.wa_version := value.GetValue<string>('wa_version');
  wsInfo.device_model := value.GetValue<string>('device_model');
  wsSttus(conn);

end;

procedure Tprincipal.onQr(value: TJSONValue);
begin
  TabQR.TabVisible := true;
  TabQueue.TabVisible := false;
  PCcenter.ActivePageIndex := 1;
  Pevent.Visible := false;

  Pevent.Align := alBottom;
  QRCodeBitmap := TBitmap.Create;
  QrPanel.Visible := true;
  lastQr := value.FindValue('data').GetValue<string>('qrCode');
  update;
end;

procedure Tprincipal.PaintBox1Paint(Sender: TObject);
var
  Scale: Double;
begin
  if QRCodeBitmap = nil then
    exit;

  PaintBox1.Canvas.Brush.Color := clWhite;
  PaintBox1.Canvas.FillRect(Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
  if ((QRCodeBitmap.Width > 0) and (QRCodeBitmap.Height > 0)) then
  begin
    if (PaintBox1.Width < PaintBox1.Height) then
    begin
      Scale := PaintBox1.Width / QRCodeBitmap.Width;
    end
    else
    begin
      Scale := PaintBox1.Height / QRCodeBitmap.Height;
    end;
    PaintBox1.Canvas.StretchDraw(Rect(0, 0, Trunc(Scale * QRCodeBitmap.Width),
      Trunc(Scale * QRCodeBitmap.Height)), QRCodeBitmap);
  end;
end;

procedure Tprincipal.readConfig;
var
  dir: string;
  json: string;
  Reader: TStreamReader;
begin

  dir := ExtractFileDir(Application.ExeName);
  dir := ExpandFileName(dir + '\config.json ');
  if FileExists(dir) then
  begin
    Reader := TStreamReader.Create(dir, TEncoding.UTF8);
    json := Reader.ReadToEnd();
    { Close and free the writer. }
    Reader.Free();
    loadConfig(json)

  end
  else
    createConfig;

end;

procedure Tprincipal.OnClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if Socket.connected then
  begin
    if not Assigned(Socket_act) then
      Socket_act := Socket
    else
      Socket.Close(true)

  end
end;

procedure Tprincipal.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  if Socket_act = Socket then
  begin
    Socket_act := nil;
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
    wsSttus(disconnet);
    initNode;
  end;

end;

procedure Tprincipal.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  jsonValue: TJSONValue;
  str: string;
  argType: string;
  // arr: TArray<string>;
  // I: Integer;
  // Stream: TFileStream;
  StringWriter: TStringWriter;
  Writer: TJsonTextWriter;
begin

  str := string(Socket.ReceiveText);

  // if (Copy(str, 0, 1) = '>') and (Copy(str, length(str), 1) = '<') then
  // begin
  // Data := '';
  // end
  // else if (Copy(str, 0, 1) = '>') then
  // begin
  // Data := str;
  // exit;
  // end
  // else if (Copy(str, length(str), 1) = '<') then
  // begin
  // Data := Data + str;
  // str := Data;
  // Data := '';
  // end
  // else
  // begin
  // Data := Data + Socket.ReceiveText;
  // exit;
  // end;

  // str := Copy(str, 2, length(str) - 2);

  StringWriter := TStringWriter.Create();
  Writer := TJsonTextWriter.Create(StringWriter);

  with TJSONObjectBuilder.Create(Writer) do
    try
      BeginObject.Add('type', 'dataEnd').Add('data', 'null').EndObject;
      Socket.SendText('data:' + TBase64Encoding.Base64.Encode
        (StringWriter.ToString) + #$A#$A);

    finally
      Free;
      StringWriter.Free;
      Writer.Free;
    end;

  try
    // str := str.Replace('[', '').Replace(']', '');
    // str := TBase64Encoding.Base64.Decode(str);
    if (str.IndexOf('type') = -1) then
      exit;
    jsonValue := TJSonObject.ParseJSONValue(str);
    argType := jsonValue.GetValue<string>('type');
    case IndexStr(argType, ['qr', 'message', 'connected', 'console', 'error',
      'disconnet', 'connecting', 'queue', 'queue_status', 'count']) of
      0:
        onQr(jsonValue);
      1:
        onMsg(jsonValue);
      2:
        onConnet(jsonValue);
      3:
        memo1.Lines.Add(jsonValue.GetValue<string>('data'));
      4:
        begin
          memo1.SelAttributes.Color := clRed;
          memo1.Lines.Add(jsonValue.GetValue<string>('data'));
        end;
      5:
        wsSttus(disconnet);
      6:
        wsSttus(connecting);
      7:
        loadQueue(jsonValue.GetValue<TJSONArray>('data'));
      8:
        QueueStatus(jsonValue.GetValue<TJSONValue>('data'));
      9:
        count.Caption := jsonValue.GetValue<string>('data');

    end;
  except
    on E: EJsonException do
    begin
      //
    end;
  end;

end;

procedure Tprincipal.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  MSendMessage.DisableConstraints;
  with MSendMessage do
  begin
    Open;
    first;
    while not eof do
    begin
      if MSendMessagestatus.value = 'success' then
        delete;
      next;
    end;
    DBGrid1.Refresh;
    Refresh;

  end;

  MSendMessage.EnableControls;
end;

procedure Tprincipal.update;
var
  QRCode: TDelphiZXingQRCode;
  Row, Column: Integer;
begin
  QRCode := TDelphiZXingQRCode.Create;
  try
    QRCode.Data := lastQr;
    QRCode.Encoding := TQRCodeEncoding(0);
    QRCode.QuietZone := 4;
    QRCodeBitmap.SetSize(QRCode.Rows, QRCode.Columns);
    for Row := 0 to QRCode.Rows - 1 do
    begin
      for Column := 0 to QRCode.Columns - 1 do
      begin
        if (QRCode.IsBlack[Row, Column]) then
        begin
          QRCodeBitmap.Canvas.Pixels[Column, Row] := clBlack;
        end
        else
        begin
          QRCodeBitmap.Canvas.Pixels[Column, Row] := clWhite;
        end;
      end;
    end;
  finally
    QRCode.Free;
  end;
  PaintBox1.Repaint;
end;

procedure Tprincipal.wsSttus(const t: wsSt);
begin
  case t of
    disconnet:
      begin
        lbStatus.Caption := 'Disconnected';
        lbws.Caption := '';
        lbStatus.Font.Color := clRed;

      end;
    conn:
      begin
        lbStatus.Caption := 'Connected';
        lbws.Caption := wsInfo.id;
        lbStatus.Font.Color := clGreen;
      end;
    reconn:
      begin

      end;
    connecting:
      begin
        lbStatus.Caption := 'connecting...';
        lbws.Caption := '';
        lbStatus.Font.Color := clRed;
      end;
    start:
      begin
        lbStatus.Caption := 'starting...';
        lbws.Caption := '';
        lbInfo.Caption := '[' + compName.Text + ',' + compId.Text + ',' +
          sucId.Text + ',' + port.Text + ']';
        lbStatus.Font.Color := clNavy;
      end;
  end;
end;

end.
