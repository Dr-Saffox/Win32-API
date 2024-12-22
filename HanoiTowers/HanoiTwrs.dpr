program HanoiTwrs;

uses
  windows,
  messages;

{интерфейсы к системным DLL}

{$H-}

function WndProc(hWnd: THandle; Msg: integer;
                 wParam: longint; lParam: longint): longint;
                 stdcall; forward;

procedure WinMain; {Основной цикл обработки сообщений}
  const szClassName='HanoiTwrs';
  var   wndClass:TWndClassEx;
        msg:TMsg;
        hwnd1,hwnd2:THandle;
begin
  wndClass.cbSize:=sizeof(wndClass);
  wndClass.style:=0;
  wndClass.lpfnWndProc:=@WndProc;
  wndClass.cbClsExtra:=0;
  wndClass.cbWndExtra:=dlgwindowextra;
  wndClass.hInstance:=hInstance;
  wndClass.hIcon:=loadIcon(0, idi_Application);
  wndClass.hCursor:=loadCursor(0, idc_Arrow);
  wndClass.hbrBackground:=GetStockObject(ltgray_Brush);
  wndClass.lpszMenuName:=nil;
  wndClass.lpszClassName:=szClassName;
  wndClass.hIconSm:=loadIcon(0, idi_Application);

  RegisterClassEx(wndClass);

  hwnd1:=CreateWindowEx(ws_ex_controlparent,
         szClassName, {имя класса окна}
         'HanoiTwrs by Saffox',    {заголовок окна}
         ws_popupwindow or ws_sysmenu or ws_caption or ws_border or ws_visible,       {стиль окна}
         10,           {Left}
         10,           {Top}
         500,                     {Width}
         200,                     {Height}
         0,                       {хэндл родительского окна}
         0,                       {хэндл оконного меню}
         hInstance,               {хэндл экземпляра приложения}
         nil);                    {параметры создания окна}

  while GetMessage(msg,0,0,0) do begin
    if not IsDialogMessage(GetActiveWindow,msg)
           {Если Windows не распознает и не обрабатывает клавиатурные сообщения
            как команды переключения между оконными органами управления,
            тогда чообщение идет на стандартную обработку}
    then begin
      TranslateMessage(msg);
      DispatchMessage(msg);    
    end;
  end;
end;

function WndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
  const
      list1 = 1;      btnFrom1st = 11;      btnTo1st = 21;
      list2 = 2;      btnFrom2nd = 12;      btnTo2nd = 22;
      list3 = 3;      btnMove = 6;          btnReset = 7;

  var rect:TRect;
      len, i:integer;
      buffer: array[0..255] of char;
begin
  result:=0;
  case Msg of
    wm_create: {Органы управления создаются при создании главного окна}
      begin
        GetClientRect(hwnd,rect); //размеры клиентской области

        {-------------------- autoradiobutton's -------------------------------}
        CreateWindow('button',
                   'Откуда:',
                   ws_visible or ws_child or bs_groupbox or
                   ws_group, // Начало первой группы органов управления
                   5,0,
                   70,100,
                   hwnd,         // хэндл родительского окна
                   4,            // идентификатор органа управления
                   hInstance,
                   nil);

        CreateWindow('button',
                   '1',
                   ws_visible or ws_child or bs_autoradiobutton OR WS_TABSTOP,
                   20,20,
                   40,20,
                   hWnd,
                   11, //btnFrom1-st
                   hInstance,
                   nil);

        CreateWindow('button',
                   '2',
                   ws_visible or ws_child or bs_autoradiobutton,
                   20,40,
                   40,20,
                   hWnd,
                   12, //btnFrom2-nd
                   hInstance,
                   nil);

        CreateWindow('button',
                   '3',
                   ws_visible or ws_child or bs_autoradiobutton,
                   20,60,
                   40,20,
                   hWnd,
                   13, //btnFrom3-rd
                   hInstance,
                   nil);

        CreateWindow('button',
                   'Куда:',
                   ws_visible or ws_child or bs_groupbox or
                   ws_group, // Начало второй группы органов управления
                   75,0,
                   70,100,
                   hwnd,
                   5,
                   hInstance,
                   nil);

        CreateWindow('button',
                   '1',
                   ws_visible or ws_child or bs_autoradiobutton OR WS_TABSTOP,
                   90,20,
                   40,20,
                   hWnd,
                   21, //btnTo1-st
                   hInstance,
                   nil);

        CreateWindow('button',
                   '2',
                   ws_visible or ws_child or bs_autoradiobutton,
                   90,40,
                   40,20,
                   hWnd,
                   22, //btnTo2-nd
                   hInstance,
                   nil);

        CreateWindow('button',
                   '3',
                   ws_visible or ws_child or bs_autoradiobutton,
                   90,60,
                   40,20,
                   hWnd,
                   23, //btnTo3-rd
                   hInstance,
                   nil);
        {--------------------------------------------------------------------}

        {---------------------- button --------------------------------------}
        CreateWindow('button',
                   'Переместить',
                   ws_visible or ws_child or bs_pushbutton or ws_tabstop,
                   20,100,
                   100,25,
                   hwnd,
                   6, //btnMove
                   hInstance,
                   nil);
        CreateWindow('button',
                   'Начать',
                   ws_visible or ws_child or bs_defpushbutton or ws_tabstop,
                   20,130,
                   100,25,
                   hwnd,
                   7, //btnReset
                   hInstance,
                   nil);
        {--------------------------------------------------------------------}

        {--------------------- "WALL" ---------------------------------------}
        CreateWindowEx(WS_EX_CLIENTEDGE, // Утопленная рамка
                   'listbox',
                   '',
                   ws_visible or ws_child or ws_border or ws_tabstop,
                   150,5,
                   100,rect.bottom-35,
                   hwnd,
                   1, //list1
                   hInstance,
                   nil);

        CreateWindowEx(WS_EX_CLIENTEDGE, // Утопленная рамка
                   'listbox',
                   '',
                   ws_visible or ws_child or ws_border or ws_tabstop,
                   255,5,
                   100,rect.bottom-35,
                   hwnd,
                   2, //list2
                   hInstance,
                   nil);

        CreateWindowEx(WS_EX_CLIENTEDGE, // Утопленная рамка
                   'listbox',
                   '',
                   ws_visible or ws_child or ws_border or ws_tabstop,
                   360,5,
                   100,rect.bottom-35,
                   hwnd,
                   3, //list3
                   hInstance,
                   nil);
        {--------------------------------------------------------------------}
        SendMessage(GetDlgItem(hwnd,btnFrom1st), BM_SETCHECK, BST_CHECKED, 0);
        SendMessage(GetDlgItem(hwnd,btnTo1st), BM_SETCHECK, BST_CHECKED, 0);
      end;

    wm_command: // Обработка команд от всех органов управления
      case hiword(wParam) of
        BN_Clicked:
          if loword(wParam) = btnMove then begin

            if SendMessage(GetDlgItem(hwnd,btnFrom1st), BM_GETCHECK,0,0)<>0 then begin
              len := SendDlgItemMessage(hwnd,list1,LB_GETCOUNT,0,0);
              if (len <> 0) then begin
                SendDlgItemMessage(hwnd,list1,LB_GETTEXT,len-1,integer(@buffer));
                SendDlgItemMessage(hwnd,list1,LB_DELETESTRING,len-1,0);
              end;
            end
            else if SendMessage(GetDlgItem(hwnd,btnFrom2nd), BM_GETCHECK,0,0)<>0 then begin
              len := SendDlgItemMessage(hwnd,list2,LB_GETCOUNT,0,0);
              if (len <> 0) then begin
                SendDlgItemMessage(hwnd,list2,LB_GETTEXT,len-1,integer(@buffer));
                SendDlgItemMessage(hwnd,list2,LB_DELETESTRING,len-1,0);
              end;
            end
            else begin
              len := SendDlgItemMessage(hwnd,list3,LB_GETCOUNT,0,0);
              if (len <> 0) then begin
                SendDlgItemMessage(hwnd,list3,LB_GETTEXT,len-1,integer(@buffer));
                SendDlgItemMessage(hwnd,list3,LB_DELETESTRING,len-1,0);
              end;
            end;

            if (len <> 0) then
            begin
              if SendMessage(GetDlgItem(hwnd,btnTo1st), BM_GETCHECK,0,0)<>0 then
                SendMessage(GetDlgItem(hwnd,list1),LB_ADDSTRING,0,integer(@buffer))
              else if SendMessage(GetDlgItem(hwnd,btnTo2nd), BM_GETCHECK,0,0)<>0 then
                SendMessage(GetDlgItem(hwnd,list2),LB_ADDSTRING,0,integer(@buffer))
              else SendMessage(GetDlgItem(hwnd,list3),LB_ADDSTRING,0,integer(@buffer));
            end;

            invalidaterect(hWnd,nil,true);
          end
          else if loword(wParam) = btnReset then begin
            // Инициализация "ханойских башен"
            for i := 1 to 255 do begin
              len := SendDlgItemMessage(hwnd,list1,LB_GETCOUNT,0,0);
              if (len <> 0) then SendDlgItemMessage(hwnd,list1,LB_DELETESTRING,len-1,0);

              len := SendDlgItemMessage(hwnd,list2,LB_GETCOUNT,0,0);
              if (len <> 0) then SendDlgItemMessage(hwnd,list2,LB_DELETESTRING,len-1,0);

              len := SendDlgItemMessage(hwnd,list3,LB_GETCOUNT,0,0);
              if (len <> 0) then SendDlgItemMessage(hwnd,list3,LB_DELETESTRING,len-1,0);
            end;

            for i := 1 to 255 do begin
              if(i > 7) then buffer[i-1]:= ' '
              else buffer[i-1]:= '1';
            end;

            for i := 8 downto 2 do begin
              buffer[i-1]:= ' ';
              SendMessage(GetDlgItem(hwnd,list1),LB_ADDSTRING,0,integer(@buffer));
            end;

          end;

      end; //case hiword(wparam) in for WM_COMMAND message

    wm_close: DestroyWindow(hwnd);

    wm_destroy: PostQuitMessage(0); // Органы управления уничтожаются автоматически

    else
      result:=DefDlgProc(hwnd,msg,wparam,lparam);
  end;
end;



begin
  WinMain;
end.
