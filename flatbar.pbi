DeclareModule Flatbar
  Declare Create(x, y, w, h, min=0, max=100)
  Declare getVal()
  Declare setVal(val)
  Declare setCallback(procname.s)
  #frColor = $FD6E0D
  #bkColor = $404040
EndDeclareModule

Module Flatbar
  Define canvas, progbar, progbarWidth
  Define callbackName.s
  Declare FlatbarHandler()
  Prototype Function()
  
  Procedure LaunchCallback()
    Shared callbackName.s
    Protected ProcedureName.Function = GetRuntimeInteger(callbackName.s)
    ProcedureName()
  EndProcedure
  
  
  Procedure Create(x, y, w, h, min=0, max=100)
    Shared canvas, progbar, progbarWidth
    
    canvas = CanvasGadget(#PB_Any, x, y, w, h)
    progbar = ProgressBarGadget(#PB_Any, x, y, w, h, min, max)
    SetWindowTheme_(GadgetID(progbar), "", "")
    setVal(0)
    BindGadgetEvent(canvas, @FlatbarHandler())
    progbarWidth = w
  EndProcedure
  
  Procedure setCallback(procname.s)
    Shared callbackName.s
    callbackName.s = procname.s
  EndProcedure
  
  Procedure getVal()
    Shared progbar
    ProcedureReturn GetGadgetState(progbar)
  EndProcedure
  
  Procedure setVal(val)
    Shared progbar
    SetGadgetState(progbar, val)
    SetGadgetColor(progbar, #PB_Gadget_FrontColor, #frColor)
    SetGadgetColor(progbar, #PB_Gadget_BackColor, #bkColor)
  EndProcedure
  
  Procedure incdecProgbar(delta)
    Shared progbar
    val = GetGadgetState(progbar)
    val + 2 * delta
    SetGadgetState(progbar, val)
  EndProcedure
  
  
  Procedure FlatbarHandler()
    Shared canvas, progbar, progbarWidth
    Select EventType()
      Case #PB_EventType_MouseWheel
        delta = GetGadgetAttribute(canvas, #PB_Canvas_WheelDelta)
        incdecProgbar(delta)
        LaunchCallback()
      Case #PB_EventType_LeftClick
        mousex = GetGadgetAttribute(canvas, #PB_Canvas_MouseX)
        relx.f = 100 / (progbarWidth/mousex)
        SetGadgetState(progbar, relx.f)
        LaunchCallback()
        Debug("KlickX: " + mousex + " -> %:" + relx)
    EndSelect
  EndProcedure
  
EndModule
; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 5
; Folding = --
; Optimizer
; EnableXP
; DPIAware
; CompileSourceDirectory
; EnableBuildCount = 0
; EnableExeConstant