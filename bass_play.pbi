;	Quick example to list the recording inputs.
;
;	The assert stuff is there to help detect if the wrong BASS.DLL is loaded, if a function can not be found the assert will detect this during debug.
;
;	BASS_Load_Library() and BASS_Free_Library() implemenation is for Windows only, for Linux and MacOS you need to make your own.

EnableExplicit ;Used to ensure strict coding

IncludeFile "bass.pbi"

;- Prototype Macros
Macro GetFunctionProtoQuote
  "
EndMacro
Macro GetFunctionProto(dll, name)
  Global name.name
  name = GetFunction(dll, GetFunctionProtoQuote#name#GetFunctionProtoQuote)
  CompilerIf #PB_Compiler_Debugger  ; Only enable assert in debug mode
    If name = #Null
      Debug "Assert on line " + #PB_Compiler_Line + ", GetFunction(" + GetFunctionProtoQuote#dll#GetFunctionProtoQuote + ", " + GetFunctionProtoQuote#name#GetFunctionProtoQuote + ")"
    EndIf
  CompilerEndIf
EndMacro

; BASS_Load_Library
Threaded _BASS_Load_Library_DLL_.i

Procedure BASS_Free_Library()
  If IsLibrary(_BASS_Load_Library_DLL_)
    CloseLibrary(_BASS_Load_Library_DLL_)
  EndIf
EndProcedure

Procedure.i BASS_Load_Library(dllpath$)
  Protected dll.i, result.i
  
  If IsLibrary(_BASS_Load_Library_DLL_)
    ProcedureReturn #False
  EndIf
  
  _BASS_Load_Library_DLL_ = OpenLibrary(#PB_Any, dllpath$)
  dll = _BASS_Load_Library_DLL_
  If IsLibrary(dll) = #False
    ProcedureReturn #False
  EndIf
  
  GetFunctionProto(dll, BASS_GetVersion)
  If BASS_GetVersion = #Null
    ;BASS_GetVersion() not found, is this really bass.dll ?
    BASS_Free_Library()
    ProcedureReturn #False
  EndIf
  
  ;Make sure BASS API and bass.dll are compatible.
  result = BASS_GetVersion()
  If (result & $FFFF0000) <> (#BASSVERSION & $FFFF0000) Or (result < #BASSVERSION)
    BASS_Free_Library()
    ProcedureReturn #False
  EndIf
  
  ;You should only use the GetFunctionProto() for the BASS functions you actually need/use,
  ;these are macros thus you will save some memory/exe size by removing the functions you don't use,
  ;during debugging the GetFunctionProto() macro will also check if the BASS function exists in the loaded library to catch wrong library versions.
  GetFunctionProto(dll, BASS_SetConfig)
  GetFunctionProto(dll, BASS_GetConfig)
  GetFunctionProto(dll, BASS_SetConfigPtr)
  GetFunctionProto(dll, BASS_GetConfigPtr)
  GetFunctionProto(dll, BASS_ErrorGetCode)
  GetFunctionProto(dll, BASS_GetDeviceInfo)
  GetFunctionProto(dll, BASS_Init)
  GetFunctionProto(dll, BASS_SetDevice)
  GetFunctionProto(dll, BASS_GetDevice)
  GetFunctionProto(dll, BASS_Free)
;  GetFunctionProto(dll, BASS_GetDSoundObject)
  GetFunctionProto(dll, BASS_GetInfo)
  GetFunctionProto(dll, BASS_Update)
;  GetFunctionProto(dll, BASS_GetCPU)
  GetFunctionProto(dll, BASS_Start)
  GetFunctionProto(dll, BASS_Stop)
  GetFunctionProto(dll, BASS_Pause)
  GetFunctionProto(dll, BASS_SetVolume)
  GetFunctionProto(dll, BASS_GetVolume)
  
;  GetFunctionProto(dll, BASS_PluginLoad)
;  GetFunctionProto(dll, BASS_PluginFree)
;  GetFunctionProto(dll, BASS_PluginGetInfo)
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
;    GetFunctionProto(dll, BASS_SetEAXParameters)
;    GetFunctionProto(dll, BASS_GetEAXParameters)
  CompilerEndIf
  
;   GetFunctionProto(dll, BASS_MusicLoad)
;   GetFunctionProto(dll, BASS_MusicFree)
;   
;   GetFunctionProto(dll, BASS_SampleLoad)
;   GetFunctionProto(dll, BASS_SampleCreate)
;   GetFunctionProto(dll, BASS_SampleFree)
;   GetFunctionProto(dll, BASS_SampleSetData)
;   GetFunctionProto(dll, BASS_SampleGetData)
;   GetFunctionProto(dll, BASS_SampleGetInfo)
;   GetFunctionProto(dll, BASS_SampleSetInfo)
;   GetFunctionProto(dll, BASS_SampleGetChannel)
;   GetFunctionProto(dll, BASS_SampleGetChannels)
;   GetFunctionProto(dll, BASS_SampleStop)
  
;  GetFunctionProto(dll, BASS_StreamCreate)
;  GetFunctionProto(dll, BASS_StreamCreateFile)
  GetFunctionProto(dll, BASS_StreamCreateURL)
;  GetFunctionProto(dll, BASS_StreamCreateFileUser)
  GetFunctionProto(dll, BASS_StreamFree)
;  GetFunctionProto(dll, BASS_StreamGetFilePosition)
;  GetFunctionProto(dll, BASS_StreamPutData)
;  GetFunctionProto(dll, BASS_StreamPutFileData)
  
;  GetFunctionProto(dll, BASS_ChannelBytes2Seconds)
;  GetFunctionProto(dll, BASS_ChannelSeconds2Bytes)
  GetFunctionProto(dll, BASS_ChannelGetDevice)
  GetFunctionProto(dll, BASS_ChannelSetDevice)
  GetFunctionProto(dll, BASS_ChannelIsActive)
  GetFunctionProto(dll, BASS_ChannelGetInfo)
  GetFunctionProto(dll, BASS_ChannelGetTags)
  GetFunctionProto(dll, BASS_ChannelFlags)
  GetFunctionProto(dll, BASS_ChannelUpdate)
  GetFunctionProto(dll, BASS_ChannelLock)
  GetFunctionProto(dll, BASS_ChannelPlay)
  GetFunctionProto(dll, BASS_ChannelStop)
  GetFunctionProto(dll, BASS_ChannelPause)
  GetFunctionProto(dll, BASS_ChannelSetAttribute)
;  GetFunctionProto(dll, BASS_ChannelSetAttributeEx)
  GetFunctionProto(dll, BASS_ChannelGetAttribute)
;  GetFunctionProto(dll, BASS_ChannelGetAttributeEx)
;  GetFunctionProto(dll, BASS_ChannelSlideAttribute)
;  GetFunctionProto(dll, BASS_ChannelIsSliding)
;  GetFunctionProto(dll, BASS_ChannelSet3DAttributes)
;  GetFunctionProto(dll, BASS_ChannelGet3DAttributes)
;  GetFunctionProto(dll, BASS_ChannelSet3DPosition)
;  GetFunctionProto(dll, BASS_ChannelGet3DPosition)
;  GetFunctionProto(dll, BASS_ChannelGetLength)
;  GetFunctionProto(dll, BASS_ChannelSetPosition)
;  GetFunctionProto(dll, BASS_ChannelGetPosition)
;  GetFunctionProto(dll, BASS_ChannelGetLevel)
;  GetFunctionProto(dll, BASS_ChannelGetLevelEx)
;  GetFunctionProto(dll, BASS_ChannelGetData)
  GetFunctionProto(dll, BASS_ChannelSetSync)
;  GetFunctionProto(dll, BASS_ChannelRemoveSync)
;  GetFunctionProto(dll, BASS_ChannelSetDSP)
;  GetFunctionProto(dll, BASS_ChannelRemoveDSP)
;  GetFunctionProto(dll, BASS_ChannelSetLink)
;  GetFunctionProto(dll, BASS_ChannelRemoveLink)
;  GetFunctionProto(dll, BASS_ChannelSetFX)
;  GetFunctionProto(dll, BASS_ChannelRemoveFX)
  
;   GetFunctionProto(dll, BASS_FXSetParameters)
;   GetFunctionProto(dll, BASS_FXGetParameters)
;   GetFunctionProto(dll, BASS_FXReset)
  
  ProcedureReturn #True
EndProcedure


; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 128
; FirstLine = 101
; Folding = -
; Optimizer
; EnableXP
; DPIAware
; CompileSourceDirectory
; EnableExeConstant