program FlyWin;
//{$APPTYPE CONSOLE}
{$R FlyWin.RES}
uses windows,messages, {интерфейсы к системным DLL}
     sysUtils; {Служебные функции Дельфи для форматирования строк и т.д.}

var     s:shortstring='Для выхода из программы нажмите: "Esc"'; //Строка как в Турбо-Паскале
        flag:Boolean=True;
        flagALT:Boolean=False;

function WndProc(hWnd: THandle; Msg: integer;
                 wParam: longint; lParam: longint): longint;
                 stdcall; forward;

procedure WinMain; {Основной цикл обработки сообщений}
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
         szClassName, {имя класса окна}
         'FlyWin by Saffox',    {заголовок окна}
         ws_overlappedWindow,     {стиль окна}
         cw_useDefault,           {Left}
         cw_useDefault,           {Top}
         450,                     {Width}
         100,                     {Height}
         0,                       {хэндл родительского окна}
         0,                       {хэндл оконного меню}
         hInstance,               {хэндл экземпляра приложения}
         nil);                    {параметры создания окна}

  ShowWindow(hwnd,sw_Show);  {отобразить окно}
  updateWindow(hwnd);   {послать wm_paint оконной процедуре, прорисовав
                         окно минуя очередь сообщений (необязательно)}

  while GetMessage(msg,0,0,0) do   {получить очередное сообщение}
  begin
        TranslateMessage(msg);   {Windows транслирует сообщения от клавиатуры}
        DispatchMessage(msg);    {Windows вызовет оконную процедуру}
  end; {выход по wm_quit, на которое GetMessage вернет FALSE}
end;

function WndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
  var ps:TPaintStruct;
      hdc:THandle;
      rect, winrect:TRect;
      lpPoint:TPoint;
      s1, s2:shortstring; //Строки как в Турбо-Паскале
begin
  result:=0;
  
  case Msg of
    WM_PAINT:
      begin
        hdc:=BeginPaint(hwnd,ps); //Удалить WM_PAINT из очереди и начать рисование
        GetClientRect(hwnd,rect);

        GetWindowRect(hWnd,winrect);

        if (flag) then  s:=IntToStr(winrect.Left)+' '+IntToStr(winrect.Top)+'  '+IntToStr(winrect.Right)+' '+IntToStr(winrect.Bottom);

        s2:='Для выхода из программы нажмите: "Esc"';
        s1:='Координаты окна в экранных координатах:';
        TextOut(hdc,5,5,@s2[1],length(s2));
        TextOut(hdc,5,20,@s1[1],length(s1));
        TextOut(hdc,5,35,@s[1],length(s));

        endPaint(hwnd,ps);
      end;

    WM_NCHITTEST:
      begin
        result:=DefWindowProc(hwnd,msg,wparam,lparam);
          {Если попали в рабочую область, то обманываем Windows
          и говорим, что в заголовок}
        if result=HTCLIENT then result:=HTCAPTION;
      end;

    WM_NCMOUSEMOVE:
      begin
        // Если мышь попыталась "залезть" в окно:
        flag:= True;

        GetCursorPos(lpPoint);          // В lParam [y | x]
        GetWindowRect(hWnd,winrect);

        // "убегание" окна в пределах экрана
        if (lpPoint.X <= winrect.Left+200) then  winrect.Left := lpPoint.X+2
        else if (lpPoint.Y >= winrect.Bottom-20) then winrect.Top := lpPoint.Y-100
        else if (lpPoint.X >= winrect.Right-200) then  winrect.Left := lpPoint.X-450
        else if (lpPoint.Y <= winrect.Top+20) then  winrect.Top := lpPoint.Y+2
        else
        begin
          flag := False;
          s:='ПОТЕРЯ МЫШИНЫХ СООБЩЕНИЙ!';
        end;

        // проверка на выход за границы экрана
        // можно фиксировать: 1540 - SM_CXSCREEN
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
        //updateWindow(hwnd); //Перерисовать окно сейчас же, не дожидаясь опустошения очереди
      end;

    WM_KEYDOWN:
      begin
        if (wParam = vk_escape) then DestroyWindow(hwnd);  // Закрыть окно (WM_DESTROY)
        if (wParam = vk_menu) then flagALT := True;
        if (wParam = Byte('X')) then
        begin
          if(flagALT = True) then DestroyWindow(hwnd);  // Закрыть окно (WM_DESTROY)
        end;
      end;

    WM_SYSKEYDOWN:
      begin
        if (wParam = Byte('X')) then DestroyWindow(hwnd); // Закрыть окно (WM_DESTROY)
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
