program FlyWin;
//{$APPTYPE CONSOLE}
{$R FlyWin.RES}
uses windows,messages, {���������� � ��������� DLL}
     sysUtils; {��������� ������� ������ ��� �������������� ����� � �.�.}

var     s:shortstring='��� ������ �� ��������� �������: "Esc"'; //������ ��� � �����-�������
        flag:Boolean=True;
        flagALT:Boolean=False;

function WndProc(hWnd: THandle; Msg: integer;
                 wParam: longint; lParam: longint): longint;
                 stdcall; forward;

procedure WinMain; {�������� ���� ��������� ���������}
  const szClassName='FlyWin';
  var   wndClass:TWndClassEx;
        hWnd: THandle;
        msg:TMsg;
begin
  wndClass.cbSize:=sizeof(wndClass);
  wndClass.style:=cs_hredraw or cs_vredraw;
  wndClass.lpfnWndProc:=@WndProc;
  wndClass.cbClsExtra:=0;
  wndClass.cbWndExtra:=0;
  wndClass.hInstance:=hPrevInst;
  wndClass.hInstance:=hInstance;
  wndClass.hIcon:=loadIcon(0, idi_Application);
  wndClass.hCursor:=loadCursor(0, idc_Arrow);
  wndClass.hbrBackground:=GetStockObject(white_Brush);
  wndClass.lpszMenuName:=nil;
  wndClass.lpszClassName:=szClassName;
  wndClass.hIconSm:=loadIcon(0, idi_Application);

  RegisterClassEx(wndClass);

  hwnd:=CreateWindowEx(
         0,
         szClassName, {��� ������ ����}
         'FlyWin by Saffox',    {��������� ����}
         ws_overlappedWindow,     {����� ����}
         cw_useDefault,           {Left}
         cw_useDefault,           {Top}
         450,                     {Width}
         100,                     {Height}
         0,                       {����� ������������� ����}
         0,                       {����� �������� ����}
         hInstance,               {����� ���������� ����������}
         nil);                    {��������� �������� ����}

  ShowWindow(hwnd,sw_Show);  {���������� ����}
  updateWindow(hwnd);   {������� wm_paint ������� ���������, ����������
                         ���� ����� ������� ��������� (�������������)}

  while GetMessage(msg,0,0,0) do   {�������� ��������� ���������}
  begin
        TranslateMessage(msg);   {Windows ����������� ��������� �� ����������}
        DispatchMessage(msg);    {Windows ������� ������� ���������}
  end; {����� �� wm_quit, �� ������� GetMessage ������ FALSE}
end;

function WndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
  var ps:TPaintStruct;
      hdc:THandle;
      rect, winrect:TRect;
      lpPoint:TPoint;
      s1, s2:shortstring; //������ ��� � �����-�������
begin
  result:=0;
  
  case Msg of
    WM_PAINT:
      begin
        hdc:=BeginPaint(hwnd,ps); //������� WM_PAINT �� ������� � ������ ���������
        GetClientRect(hwnd,rect);

        GetWindowRect(hWnd,winrect);

        if (flag) then  s:=IntToStr(winrect.Left)+' '+IntToStr(winrect.Top)+'  '+IntToStr(winrect.Right)+' '+IntToStr(winrect.Bottom);

        s2:='��� ������ �� ��������� �������: "Esc"';
        s1:='���������� ���� � �������� �����������:';
        TextOut(hdc,5,5,@s2[1],length(s2));
        TextOut(hdc,5,20,@s1[1],length(s1));
        TextOut(hdc,5,35,@s[1],length(s));

        endPaint(hwnd,ps);
      end;

    WM_NCHITTEST:
      begin
        result:=DefWindowProc(hwnd,msg,wparam,lparam);
          {���� ������ � ������� �������, �� ���������� Windows
          � �������, ��� � ���������}
        if result=HTCLIENT then result:=HTCAPTION;
      end;

    WM_NCMOUSEMOVE:
      begin
        // ���� ���� ���������� "�������" � ����:
        flag:= True;

        GetCursorPos(lpPoint);          // � lParam [y | x]
        GetWindowRect(hWnd,winrect);

        // "��������" ���� � �������� ������
        if (lpPoint.X <= winrect.Left+200) then  winrect.Left := lpPoint.X+2
        else if (lpPoint.Y >= winrect.Bottom-20) then winrect.Top := lpPoint.Y-100
        else if (lpPoint.X >= winrect.Right-200) then  winrect.Left := lpPoint.X-450
        else if (lpPoint.Y <= winrect.Top+20) then  winrect.Top := lpPoint.Y+2
        else
        begin
          flag := False;
          s:='������ ������� ���������!';
        end;

        // �������� �� ����� �� ������� ������
        // ����� �����������: 1540 - SM_CXSCREEN
        //                    830 - SM_CYSCREEN
        if (winrect.Top < 0) then
        begin
          if(lpPoint.X+450 < GetSystemMetrics(SM_CXSCREEN))then winrect.Left := lpPoint.X
          else winrect.Left := lpPoint.X-450;
          winrect.Top := 0;
        end;
        if (winrect.Bottom > GetSystemMetrics(SM_CYSCREEN)) then
        begin
          if(lpPoint.X+450 < GetSystemMetrics(SM_CXSCREEN)) then winrect.Left := lpPoint.X
          else winrect.Left := lpPoint.X-450;
          winrect.Top := GetSystemMetrics(SM_CYSCREEN)-100;
        end;
        if (winrect.Left < 0) then
        begin
          if(lpPoint.Y+100 < GetSystemMetrics(SM_CYSCREEN)) then winrect.Top := lpPoint.Y
          else winrect.Top := lpPoint.Y-100;
          winrect.Left := 0;
        end;
        if (winrect.Right > GetSystemMetrics(SM_CXSCREEN)) then
        begin
          if(lpPoint.Y+100 < GetSystemMetrics(SM_CYSCREEN)) then winrect.Top := lpPoint.Y
          else winrect.Top := lpPoint.Y-100;
          winrect.Left := GetSystemMetrics(SM_CXSCREEN)-450;
        end;

        MoveWindow(hWnd,winrect.Left,winrect.Top,450,100,False);
        invalidaterect(hwnd,nil,true);
        //updateWindow(hwnd); //������������ ���� ������ ��, �� ��������� ����������� �������
      end;

    WM_KEYDOWN:
      begin
        if (wParam = vk_escape) then DestroyWindow(hwnd);  // ������� ���� (WM_DESTROY)
        if (wParam = vk_menu) then flagALT := True;
        if (wParam = Byte('X')) then
        begin
          if(flagALT = True) then DestroyWindow(hwnd);  // ������� ���� (WM_DESTROY)
        end;
      end;

    WM_SYSKEYDOWN:
      begin
        if (wParam = Byte('X')) then DestroyWindow(hwnd); // ������� ���� (WM_DESTROY)
      end;

    WM_KEYUP:
      begin
        if (wParam = vk_menu) then flagALT := False;
      end;

    WM_DESTROY:
      begin
        PostQuitMessage(0);
      end;

  else
      result:=DefWindowProc(hwnd,msg,wparam,lparam);
  end;
end;


begin
  WinMain;
end.
