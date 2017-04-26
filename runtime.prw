#Include "Protheus.ch"

Class RPO2
    Data oRPO
    Data cRPO
    Data lAberto
    Data cErrStr
    Data nErrLine

    Method New() Constructor
    Method Open()
    Method Close()
    Method Reload()
    Method Compile(cFile, cSource)
EndClass


Method New(cRPO) Class RPO2
    ::cRPO := cRPO
    ::lAberto := .F.
    ::cErrStr := ""
    ::nErrLine := 0
Return Self


Method Open() Class RPO2
    If ! ::lAberto
        ::oRPO := RPO():New()
        If ::oRPO:Open(::cRPO)
            ::lAberto := .T.
            Return .T.
        EndIf
        Return .F.
    EndIf
Return .T.


Method Close() Class RPO2
    If ::lAberto
        If ::oRPO:Close()
            ::lAberto := .F.
            Return .T.
        EndIf
        Return .F.
    EndIf
Return .T.


Method Reload() Class RPO2
Return ::Close() .And. ::Open()


Method Compile(cFile, cSource) Class RPO2
    If ! ::Open()
        Return .F.
    EndIf

    If ! ::oRPO:StartBuild(.T.)
        ::Reload()
        Return .F.
    EndIf

    If ! ::oRPO:Compile(cFile, cSource, 0, ::oRPO:ChkSum(cSource))
        ::cErrStr := ::oRPO:ErrStr
        ::nErrLine := ::oRPO:ErrLine
        ::Reload()
        Return .F.
    EndIf

    If ! ::oRPO:EndBuild()
        ::Reload()
        Return .F.
    EndIf
Return ::Reload()


Function Stdout(cMessage)
    cOutput += AsString(cMessage)
Return


Function StdoutLn(cMessage)
    cOutput += AsString(cMessage) + Chr(10)
Return


Function Stdin()
    Local cInput := ""

    If nInput <= Len(aInput)
        cInput := aInput[nInput++]
    EndIf

Return cInput


User Function Runtime(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
    Local nI      := 0
    Local cName   := ""
    Local cValue  := ""
    // variaveis
    Local cUUID   := ""
    Local cCodigo := ""
    Local cEntry  := ""
    // compilacao
    Local oRPO2   := Nil
    // saida
    Private cOutput := ""
    Private aInput  := {}
    Private nInput  := 1

    // preparando parametros
    For nI := 1 To Len(__aPostParms)

        cName := Lower(__aPostParms[nI][1])
        cValue := __aPostParms[nI][2]

        If cName == "uuidv4"
            cUUID := cValue

        ElseIf cName == "codigo"
            cCodigo := cValue

        ElseIf cName == "entry"
            cEntry := cValue

        ElseIf cName == "stdin"
            // altera CR para LF
            cValue := StrTran(cValue, Chr(13), Chr(10))
            // altera LFLF para LF
            cValue := StrTran(cValue, Chr(10)+Chr(10), Chr(10))
            // quebra valores por LF
            aInput := StrTokArr2(cValue, Chr(10), .T.)

        EndIf
    Next nI

    // inicializa
    oRPO2 := RPO2():New(cUUID + ".rpo")

    // se compilou executa
    If oRPO2:Compile(cUUID + ".prw", cCodigo)
        &(cEntry)
        oRPO2:Close()

    // se nao compilou mostra erro
    Else
        cOutput := oRPO2:cErrStr
        oRPO2:Close()
    EndIf
Return cOutput