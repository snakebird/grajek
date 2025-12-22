; ----------------------------------------------------------------------------------
;
;
;
;
;
;
;
;
; ----------------------------------------------------------------------------------

EnableExplicit

;- Enumerations
Enumeration Window
  #Window_Main
EndEnumeration

Enumeration Gadgets
  #Btn_Stop
  #Info_1
  #Info_2
  #Info_Status
  #ListView
  #ListViewContainer
EndEnumeration

; dla trybu ciemnego
Enumeration DWMWINDOWATTRIBUTE
  #DWMWA_USE_IMMERSIVE_DARK_MODE = 20
EndEnumeration

PrototypeC.i DwmSetWindowAttribute(hwnd.i, dwAttribute.l, *pvAttribute, cbAttribute.l)



;- Deklaracje
Declare Event_Btn_Stop()
Declare Event_Track_Vol()
Declare Event_ListView()
Declare Open_Window_Main(X = 0, Y = 0, Width = 300, Height = 400)

XIncludeFile "flatbar.pbi"
UseModule Flatbar

IncludeFile "bass_play.pbi"

;- Zmienne globalne
Global NewMap Stacje.s()
Global BA_chan.l = 0
Global WinXpos.l, WinYpos.l
Global chanInfo.BASS_CHANNELINFO
Global tagRegexp = CreateRegularExpression(#PB_Any, "StreamTitle='(.[^;]*)'")
Global BASSvolume.f = 0.3  ; początkowa głośność

; kolorki dla labelki
#kolorGramy = $00FF66
#kolorError = $1414FF
#kolorInfo  = $00D7FF
#kolorStatus = $666666
#kolorBlue = $FF901E

; kolory dla trybu ciemnego
#kolorDarkBG = $202020
#kolorDarkFG = $FAFAFA

; pierdolety do gadzetow
Procedure SetText(gadget, tekst.s, kolorTekstu = #kolorDarkFG, kolorTla = #kolorDarkBG)
  SetGadgetColor(gadget, #PB_Gadget_BackColor, kolorTla)
  SetGadgetColor(gadget, #PB_Gadget_FrontColor, kolorTekstu)
  SetGadgetText(gadget, tekst.s)  
EndProcedure

Procedure GetMeta()
  Protected meta.s, adres
  
  adres = BASS_ChannelGetTags(BA_chan, #BASS_TAG_META)
  
  If adres
    meta = PeekS(adres, -1, #PB_UTF8)
    Debug "GetMeta: " + meta
  EndIf
  
  If ExamineRegularExpression(tagRegexp, meta)
    If NextRegularExpressionMatch(tagRegexp)
      meta = RegularExpressionGroup(tagRegexp, 1)
    EndIf
  EndIf
  
  If Len(meta) And (FindString(meta, "StreamTitle=''") = 0)
    SetText(#Info_2, meta, #kolorGramy)
  EndIf
EndProcedure

; ----------------------------------------------------------------
;- BASS play stream
; ----------------------------------------------------------------
Procedure BA_Play(url.s)
  Protected attr.f
  #BASS_ATTRIB_BITRATE = 12
  
  If BA_chan
    BASS_StreamFree(BA_chan)
  EndIf
  
  BA_chan = BASS_StreamCreateURL(@url, 0, #BASS_STREAM_BLOCK | #BASS_STREAM_STATUS | #BASS_STREAM_AUTOFREE | #BASS_SAMPLE_FLOAT | #BASS_UNICODE, #Null, 0)
  Debug "BA_chan=" + Str(BA_chan)
  If BA_chan
    BASS_ChannelPlay(BA_chan, #False)
    BASS_ChannelSetAttribute(BA_chan, #BASS_ATTRIB_VOL, BASSvolume)
    BASS_ChannelSetSync(BA_chan, #BASS_SYNC_META, #NUL, @GetMeta(), #NUL)
    BASS_ChannelGetAttribute(BA_chan, #BASS_ATTRIB_BITRATE, @attr.f)
    SetWindowTitle(#Window_Main, GetGadgetText(#Info_1))
    SetText(#Info_1, GetGadgetText(#Info_1) + " @" + Round(attr.f, #PB_Round_Up))
    Debug("Bitrate: " + Round(attr.f, #PB_Round_Up))
    SetText(#Info_2, "GRAMY", #kolorGramy)
  Else
    SetText(#Info_2, "! Problem ze strumieniem !", #kolorError)
  EndIf
EndProcedure


;- Klik na STOP
Procedure Event_Btn_Stop()
  Select EventType()
    Case #PB_EventType_LeftClick
      If BA_chan
        BASS_ChannelStop(BA_chan)
        BASS_StreamFree(BA_chan) : BA_chan = #False
        SetText(#Info_1, "")
        SetText(#Info_2, "STOP")
        SetWindowTitle(#Window_Main, "Grajek")
      EndIf
  EndSelect
EndProcedure

;- Zmiana głośności
Runtime Procedure Event_Track_Vol()
  BASSvolume = Flatbar::getVal()/100
  BASS_ChannelSetAttribute(BA_chan, #BASS_ATTRIB_VOL, BASSvolume)
EndProcedure


;- Klik na liście stacji
Procedure Event_ListView()
  Protected lista, item, url.s, stacja.s
  Select EventType()
    Case #PB_EventType_LeftClick
      item = GetGadgetState(#ListView)  ; selected item
      stacja = GetGadgetItemText(#ListView, item) ; nazwa stacji
      If FindString(stacja, "|")  ; jeśli w nazwie stacji występuje znak "|"
        stacja = Trim(StringField(stacja, 2, "|"))  ; to bierzemy jako nazwę stacji wszytko co następuje po "|"
      EndIf
      SetText(#Info_1, stacja)
      SetText(#Info_2, "Buforowanie", #kolorInfo)      
      SetActiveGadget(#Info_2)  ; bez tego gadget się nie odświeżał
      url = Stacje(GetGadgetItemText(#ListView, item))  ; url stacji
      Debug url
      BA_Play(url)
  EndSelect
EndProcedure

Procedure Open_Window_Main(X = 0, Y = 0, Width = 300, Height = 400)
  If OpenWindow(#Window_Main, X, Y, Width, Height, "Grajek", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget)
    
    ; tryb ciemny
    Define.DwmSetWindowAttribute DwmSetWindowAttribute  
    Define.i UseDarkMode = #True

    If OpenLibrary(0, "dwmapi")  
      DwmSetWindowAttribute = GetFunction(0, "DwmSetWindowAttribute")  
      DwmSetWindowAttribute(WindowID(#Window_Main), #DWMWA_USE_IMMERSIVE_DARK_MODE, @UseDarkMode, SizeOf(UseDarkMode))
      CloseLibrary(0)
    EndIf

    SetWindowColor(#Window_Main, #kolorDarkBG)
    
    TextGadget(#Info_1, 10, 10, 280, 17, "", #PB_Text_Center)
    SetGadgetColor(#Info_1, #PB_Gadget_BackColor, #kolorDarkBG)
    SetGadgetColor(#Info_1, #PB_Gadget_FrontColor, #kolorDarkFG)
  
    StringGadget(#Info_2, 10, 40, 280, 20, "Klik na stacji poniżej, przewijasz kółkiem", #PB_String_BorderLess | #PB_String_ReadOnly | #ES_CENTER)
    SetGadgetColor(#Info_2, #PB_Gadget_BackColor, #kolorDarkBG)
    SetGadgetColor(#Info_2, #PB_Gadget_FrontColor, #kolorBlue)

    ;ButtonGadget(#Btn_Stop, 10, 70, 70, 24, "Stop")
    HyperLinkGadget(#Btn_Stop, 30, 70, 50, 24, " [STOP] ", #kolorGramy)
    SetGadgetColor(#Btn_Stop, #PB_Gadget_BackColor, #kolorDarkBG)
    SetGadgetColor(#Btn_Stop, #PB_Gadget_FrontColor, #kolorBlue)
    BindGadgetEvent(#Btn_Stop, @Event_Btn_Stop())
    
    ; mój ładny volume slider
    Flatbar::Create(90, 76, 200, 10)
    Flatbar::setCallback("Event_Track_Vol()")
    Flatbar::setVal(BASSvolume*100)
    
    ; kontener w celu ukrycia wstrętnego scrollbar-a
    ContainerGadget(#ListViewContainer, 10, 100, 280, 270, #PB_Container_Flat)
      ListViewGadget(#ListView, 0, 0, 300, 270, #LBS_SORT |  #LBS_HASSTRINGS)
      SetGadgetColor(#ListView, #PB_Gadget_BackColor, #kolorDarkBG)
      SetGadgetColor(#ListView, #PB_Gadget_FrontColor, #kolorDarkFG)
      BindGadgetEvent(#ListView, @Event_ListView())
    CloseGadgetList()
    
    SetWindowLongPtr_(GadgetID(#ListView), #GWL_EXSTYLE, GetWindowLongPtr_(GadgetID(#ListView), #GWL_EXSTYLE) &(~#WS_EX_CLIENTEDGE) )
    ;SetWindowPos_(GadgetID(#ListView), 0, 0, 0, 0, 0, #SWP_SHOWWINDOW | #SWP_NOZORDER | #SWP_NOSIZE | #SWP_NOMOVE | #SWP_FRAMECHANGED)
  
    ; About w niby-statusbarze
    CompilerIf #PB_Compiler_Debugger = #False
      TextGadget(#Info_Status, 100, 380, 190, 17, "Grajek " + #PB_Editor_FileVersion + "." + #PB_Editor_BuildCount + " © snakebirdG", #PB_Text_Right)
      SetGadgetColor(#Info_Status, #PB_Gadget_BackColor, #kolorDarkBG)
      SetGadgetColor(#Info_Status, #PB_Gadget_FrontColor, #kolorStatus)
    CompilerEndIf
    
    ProcedureReturn #True
  EndIf
EndProcedure


;-* Main Program
;SetObjectTheme(#ObjectTheme_DarkBlue)

DisableExplicit

; ----------------------------------------------------------------
;- Preferencje - utworzenie jesli nie ma
; ----------------------------------------------------------------
prefFile.s = GetPathPart(ProgramFilename())+"prefs.ini"
Debug "Pref file: " + prefFile
If FileSize(prefFile) = -1
  If CreatePreferences(prefFile, #PB_Preference_GroupSeparator)
    PreferenceGroup("Window")
    WritePreferenceLong ("WindowX", 0)
    WritePreferenceLong ("WindowY", 0)
    
    PreferenceGroup("Stacje")
    WritePreferenceString("M | Off Radio", "http://s3.yesstreaming.net:7062/stream")
    WritePreferenceString("L | Ostrowiec [95.2 FM]", "http://s1.slotex.pl:7050/stream/1/;?type=http")
    ClosePreferences()
  EndIf
EndIf

; ----------------------------------------------------------------
;- Odczyt preferencji
; ----------------------------------------------------------------
If OpenPreferences(prefFile)
  ; lista stacji
  PreferenceGroup("Stacje")
  ExaminePreferenceKeys()
  While  NextPreferenceKey() ; While a key exists
    Stacje(PreferenceKeyName()) = PreferenceKeyValue()
  Wend
  ; pozycja okna
  PreferenceGroup("Window")
  WinXpos = ReadPreferenceLong("WindowX", 0)
  WinYpos = ReadPreferenceLong("WindowY", 0)
  ClosePreferences()  
EndIf

If Open_Window_Main(WinXpos, WinYpos)
  
  ; wypelnienie listy stacji
  ForEach Stacje()
    ;AddGadgetItem(#ListView, -1, MapKey(Stacje()))
    SendMessage_(GadgetID(#ListView), #LB_ADDSTRING, 0, MapKey(Stacje())) ; dzięki temu są posortowane alfabetycznie
  Next
  
  ; ----------------------------------------------------------------
  ;- Inicjalizacja BASS
  ; ----------------------------------------------------------------
  If BASS_Load_Library("bass.dll") = #False
    ;MessageRequester("Błąd", "Brak [bass.dll]!", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
    Debug "Failed to load bass.dll"
    End
  EndIf
  
  Debug "BASS Version: " + Hex(BASS_GetVersion(), #PB_Long)
  
  BASS_SetConfig(#BASS_CONFIG_UNICODE, #True)
  ;BASS_SetConfig(#BASS_CONFIG_NET_BUFFER, 4000)
  ;BASS_SetConfig(#BASS_CONFIG_NET_PREBUF, 80)
  ;BASS_SetConfig(#BASS_CONFIG_BUFFER, 2000)
  BASS_SetConfig(#BASS_CONFIG_NET_TIMEOUT, 4000)
  BASS_SetConfig(#BASS_CONFIG_NET_PLAYLIST, #True) 
  BASS_Init(-1, 44100, #Null, WindowID(#Window_Main), #Null)
  Debug "BASSInit: " + BASS_ErrorGetCode()
  
  
  ;- Event Loop
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow
        Break
       
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Info_2
            HideCaret_(GadgetID(#Info_2))
        EndSelect
        
    EndSelect
  ForEver
  
  ;- The End
  
  ; zapis pozycji okna
  If OpenPreferences(prefFile)
    PreferenceGroup("Window")
    WritePreferenceLong ("WindowX", WindowX(#Window_Main))
    WritePreferenceLong ("WindowY", WindowY(#Window_Main))
    ClosePreferences()  
  EndIf
  
  BASS_Free_Library()
  Debug "BASS free"
EndIf


; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 139
; FirstLine = 130
; Folding = --
; Markers = 197
; Optimizer
; EnableXP
; DPIAware
; CompileSourceDirectory
; EnableBuildCount = 0
; EnableExeConstant