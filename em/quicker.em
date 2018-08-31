
/*****************************************************************************
 �� �� ��  : AutoExpand
 ��������  : ��չ������ں���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :

  2.��    ��   : 2006��9��18��
    ��    ��   : ͯ��ƽ
    �޸�����   : �޸�Ĭ������ΪӢ�ģ���ǿ��������
 
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸�

*****************************************************************************/
macro AutoExpand()
{
    //������Ϣ
    // get window, sel, and buffer handles
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.lnFirst != sel.lnLast) 
    {
        /*�������*/
        BlockCommandProc()
    }
    if (sel.ichFirst == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
/*    
    if(language != 1)
    {
        language = 1
    }
*/
    
    nVer = 0
    nVer = GetVersion()
    /*ȡ���û���*/
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    // get line the selection (insertion point) is on
    szLine = GetBufLine(hbuf, sel.lnFirst);
    // parse word just to the left of the insertion point
    wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)
    ln = sel.lnFirst;
    chTab = CharFromAscii(9)
        
    // prepare a new indented blank line to be inserted.
    // keep white space on left and add a tab to indent.
    // this preserves the indentation level.
    chSpace = CharFromAscii(32);
    ich = 0
    while (szLine[ich] == chSpace || szLine[ich] == chTab)
    {
        ich = ich + 1
    }
    szLine1 = strmid(szLine,0,ich)
    szLine = strmid(szLine, 0, ich) # "    "
    
    sel.lnFirst = sel.lnLast
    sel.ichFirst = wordinfo.ich
    sel.ichLim = wordinfo.ich

    /*�Զ���ɼ������ƥ����ʾ*/
    wordinfo.szWord = RestoreCommand(hbuf,wordinfo.szWord)
    sel = GetWndSel(hwnd)
    if (wordinfo.szWord == "pn") /*���ⵥ�ŵĴ���*/
    {
        DelBufLine(hbuf, ln)
        AddPromblemNo()
        return
    }
    /*��������ִ��*/
    else if (wordinfo.szWord == "config" || wordinfo.szWord == "co")
    {
        DelBufLine(hbuf, ln)
        ConfigureSystem()
        return
    }
    /*�޸���ʷ��¼����*/
    else if (wordinfo.szWord == "hi")
    {
        DelBufLine(hbuf, ln)
        InsertHistory(hbuf,ln,language)
        return
    }
    else if (wordinfo.szWord == "cmd" || wordinfo.szWord == "help")
    {
        ShowHelp(hbuf, ln)
        return
    }
    else if (wordinfo.szWord == "key")
    {
        ShowShortKey(hbuf, ln)
        return
    }
    else if (wordinfo.szWord == "abg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseAdd()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "dbg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseDel()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "mbg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseMod()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    if(language == 1)
    {
        ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
    }
    else
    {
        ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
    }
}

/*****************************************************************************
 �� �� ��  : ExpandProcEN
 ��������  : Ӣ��˵������չ�����
 �������  : szMyName  �û���
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
  
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    /*Ӣ��ע��*/
    if (szCmd == "/*")
    {   
        if(wordinfo.ichLim > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        while(wordinfo.ichLim + kk < lineLen)
        {
            if((szCurLine[wordinfo.ichLim + kk] != " ")||(szCurLine[wordinfo.ichLim + kk] != "\t")
            {
                msg("you must insert /* at the end of a line");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("Please input comment")
        DelBufLine(hbuf, ln)
        szLeft = cat( szLeft, " ")
        CommentContent(hbuf,ln,szLeft,szContent,1)            
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    else if (szCmd == "while" || szCmd == "wh")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if( szCmd == "else" || szCmd == "el")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "#ifd" || szCmd == "#ifdef") //#ifdef
    {
        DelBufLine(hbuf, ln)
        InsIfdef()
        return
    }
    else if (szCmd == "#ifn" || szCmd == "#ifndef") //#ifndef
    {
        DelBufLine(hbuf, ln)
        InsIfndef()
        return
    }
    else if (szCmd == "#if")
    {
        DelBufLine(hbuf, ln)
        InsertPredefIf()
        return
    }
    else if (szCmd == "cpp")
    {
        DelBufLine(hbuf, ln)
        InsertCPP(hbuf,ln)
        return
    }    
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " (   )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@"  # ";");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
/*            InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" #  ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");*/
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if (  )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@"  # ";");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if (  )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" #  ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if (  )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" #  ";");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if (   )");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" #  ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@" #  ";");
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
    }
    else if (szCmd == "for")
    {
        SetBufSelText(hbuf, " ( # ;   ;   )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@"  # ";")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
        szVar = ask("Please input loop variable")
        newsel = sel
        newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " ( @szVar@ = # ; @szVar@  ; @szVar@++ )")
    }
    else if (szCmd == "fo")
    {
        SetBufSelText(hbuf, "r ( ulI = 0; ulI < # ; ulI++ )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@"  # ";")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        symname =GetCurSymbol ()
        symbol = GetSymbolLocation(symname)
        if(strlen(symbol) > 0)
        {
            nIdx = symbol.lnName + 1;
            while( 1 )
            {
                szCurLine = GetBufLine(hbuf, nIdx);
                nRet = FindInStr(szCurLine,"{")
                if( nRet != 0xffffffff )
                {
                    break;
                }
                nIdx = nIdx + 1
                if(nIdx > symbol.lnLim)
                {
                    break
                }
             }
             InsBufLine(hbuf, nIdx + 1, "    VOS_UINT32 ulI = 0;");        
         }
    }
    else if (szCmd == "switch" || szCmd == "sw")
    {
        nSwitch = ask("Please input the number of case")
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }
    else if (szCmd == "do")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@"  # ";");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ( # );")
    }
    else if (szCmd == "case" || szCmd == "ca" )
    {
        SetBufSelText(hbuf, " # :")
        InsBufLine(hbuf, ln + 1, "@szLine@" # ";")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
    }
    else if (szCmd == "struct" || szCmd == "st")
    {
        DelBufLine(hbuf, ln)
        szStructName = toupper(Ask("Please input struct name"))
        InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@             ");
        szStructName = cat(szStructName,"_STRU")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "enum" || szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        szStructName = toupper(Ask("Please input enum name"))
        InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@             ");
        szStructName = cat(szStructName,"_ENUM")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "file" || szCmd == "fi")
    {
        DelBufLine(hbuf, ln)
        ln = InsertFileHeaderEN( hbuf,0, szMyName,"" )
        TQPInsertFileHeaderEN( hbuf, ln);
        return
    }
    else if (szCmd == "func" || szCmd == "fu")
    {
        DelBufLine(hbuf,ln)
        lnMax = GetBufLineCount(hbuf)
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            if( (FindInStr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                    FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)
                    return
                }
            }
        }
        szFuncName = Ask("Please input function name")
        FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else if (szCmd == "tab")
    {
        DelBufLine(hbuf, ln)
        ReplaceBufTab()
        return
    }
    else if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* Promblem Number: @szQuestion@     Author:@szMyName@,   Date:@sz@/@sz1@/@sz3@ ");
        szContent = Ask("Description")
        szLeft = cat(szLine1,"   Description    : ");
        if(strlen(szLeft) > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        CreateFunctionDef(hbuf,szMyName,1)
        return
    }
    else if (szCmd == "hdn")
    {
        DelBufLine(hbuf, ln)

        /*���ɲ�Ҫ�ļ�������ͷ�ļ�*/
        CreateNewHeaderFile()
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ */");        
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END:   Added for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");        
        }

        //DelBufLine(hbuf, ln)
       // InsBufLine(hbuf, ln, "@szLine1@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
	DelBufLine(hbuf, ln)
	szQuestion = GetReg ("PNO")
		if(strlen(szQuestion) > 0)
	{
		InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
	}
	else
	{
		InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
	}
	

       // DelBufLine(hbuf, ln + 0)
       // InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
	DelBufLine(hbuf, ln)
	szQuestion = GetReg ("PNO")
	if(strlen(szQuestion) > 0)
	{
		InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
	}
	else
	{
		InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
	}

       // DelBufLine(hbuf, ln)
        //InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else
    {
        SearchForward()
//            ExpandBraceLarge()
        stop
    }
    SetWndSel(hwnd, sel)
    SearchForward()
}


/*****************************************************************************
 �� �� ��  : ExpandProcCN
 ��������  : ����˵������չ����
 �������  : szMyName  
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)

    //����ע��
    if (szCmd == "/*")
    {   
        if(wordinfo.ichLim > 70)
        {
            Msg("�ұ߿ռ�̫С,�����µ���")
            stop 
        }        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        /*ע��ֻ������β������ע�͵����ô���*/
        while(wordinfo.ichLim + kk < lineLen)
        {
            if(szCurLine[wordinfo.ichLim + kk] != " ")
            {
                msg("ֻ������β����");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("������ע�͵�����")
        DelBufLine(hbuf, ln)
        szLeft = cat( szLeft, " ")
        CommentContent(hbuf,ln,szLeft,szContent,1)            
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    else if (szCmd == "while" || szCmd == "wh")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if( szCmd == "else" || szCmd == "el")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "#ifd" || szCmd == "#ifdef") //#ifdef
    {
        DelBufLine(hbuf, ln)
        InsIfdef()
        return
    }
    else if (szCmd == "#ifn" || szCmd == "#ifndef") //#ifdef
    {
        DelBufLine(hbuf, ln)
        InsIfndef()
        return
    }
    else if (szCmd == "#if")
    {
        DelBufLine(hbuf, ln)
        InsertPredefIf()
        return
    }
    else if (szCmd == "cpp")
    {
        DelBufLine(hbuf, ln)
        InsertCPP(hbuf,ln)
        return
    }    
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
/*            InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");*/
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if ( # )");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
    }
    else if (szCmd == "for")
    {
        SetBufSelText(hbuf, " ( # ; # ; # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
        szVar = ask("������ѭ������")
        newsel = sel
        newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " ( @szVar@ = # ; @szVar@ # ; @szVar@++ )")
    }
    else if (szCmd == "fo")
    {
        SetBufSelText(hbuf, "r ( ulI = 0; ulI < # ; ulI++ )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        symname =GetCurSymbol ()
        symbol = GetSymbolLocation(symname)
        if(strlen(symbol) > 0)
        {
            nIdx = symbol.lnName + 1;
            while( 1 )
            {
                szCurLine = GetBufLine(hbuf, nIdx);
                nRet = FindInStr(szCurLine,"{")
                if( nRet != 0xffffffff )
                {
                    break;
                }
                nIdx = nIdx + 1
                if(nIdx > symbol.lnLim)
                {
                    break
                }
            }
            InsBufLine(hbuf, nIdx + 1, "    VOS_UINT32 ulI = 0;");        
        }
    }
    else if (szCmd == "switch" || szCmd == "sw")
    {
        nSwitch = ask("������case�ĸ���")
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }
    else if (szCmd == "do")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ( # );")
    }
    else if (szCmd == "case" || szCmd == "ca" )
    {
        SetBufSelText(hbuf, " # :")
        InsBufLine(hbuf, ln + 1, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
    }
    else if (szCmd == "struct" || szCmd == "st" )
    {
        DelBufLine(hbuf, ln)
        szStructName = toupper(Ask("������ṹ��:"))
        InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@      ");
        szStructName = cat(szStructName,"_STRU")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "enum" || szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        //��ʾ����ö������ת��Ϊ��д
        szStructName = toupper(Ask("������ö����:"))
        InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@       ");
        szStructName = cat(szStructName,"_ENUM")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "file" || szCmd == "fi" )
    {
        DelBufLine(hbuf, ln)
        /*�����ļ�ͷ˵��*/
        InsertFileHeaderCN( hbuf,0, szMyName,"" )
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        /*����C���Ե�ͷ�ļ�*/
        CreateFunctionDef(hbuf,szMyName,0)
        return
    }
    else if (szCmd == "hdn")
    {
        DelBufLine(hbuf, ln)
        /*���ɲ�Ҫ�ļ�������ͷ�ļ�*/
        CreateNewHeaderFile()
        return
    }
    else if (szCmd == "func" || szCmd == "fu")
    {
        DelBufLine(hbuf,ln)
        lnMax = GetBufLineCount(hbuf)
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            /*����2.1���si����ǷǷ�symbol�ͻ��ж�ִ�У��ʸ�Ϊ�Ժ�һ��
              �Ƿ��С��������ж��Ƿ����º���*/
            if( (FindInStr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                /*���Ѿ����ڵĺ���*/
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0)
                    return
                }
            }
        }
        szFuncName = Ask("�����뺯������:")
        /*���º���*/
        FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else if (szCmd == "tab") /*��tab��չΪ�ո�*/
    {
        DelBufLine(hbuf, ln)
        ReplaceBufTab()
    }
    else if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* �� �� ��: @szQuestion@     �޸���:@szMyName@,   ʱ��:@sz@/@sz1@/@sz3@ ");
        szContent = Ask("�޸�ԭ��")
        szLeft = cat(szLine1,"   �޸�ԭ��: ");
        if(strlen(szLeft) > 70)
        {
            Msg("�ұ߿ռ�̫С,�����µ���")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ */");        
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END:   Added for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");        
        }
       // DelBufLine(hbuf, ln)
        //InsBufLine(hbuf, ln, "@szLine1@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
	DelBufLine(hbuf, ln+0)
	szQuestion = GetReg ("PNO")
	if(strlen(szQuestion) > 0)
	{
		InsBufLine(hbuf, ln, "@szLine1@/* END:  Deleted for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
	}
	else
	{
		InsBufLine(hbuf, ln, "@szLine1@/* END:  Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
	}

        //DelBufLine(hbuf, ln + 0)
       // InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
	DelBufLine(hbuf, ln)
	szQuestion = GetReg ("PNO")
	if(strlen(szQuestion) > 0)
	{
		InsBufLine(hbuf, ln, "@szLine1@/* END:  Modified for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
	}
	else
	{
		InsBufLine(hbuf, ln, "@szLine1@/* END:  Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
	}

        //DelBufLine(hbuf, ln)
        //InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else
    {
        SearchForward()
        stop
    }
    SetWndSel(hwnd, sel)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : BlockCommandProc
 ��������  : �����������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro BlockCommandProc()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    if(sel.lnFirst > 0)
    {
        ln = sel.lnFirst - 1
    }
    else
    {
        stop
    }
    szLine = GetBufLine(hbuf,ln)
    szLine = TrimString(szLine)
    if(szLine == "while" || szLine == "wh")
    {
        InsertWhile()   /*����while*/
    }
    else if(szLine == "do")
    {
        InsertDo()   //����do while���
    }
    else if(szLine == "for")
    {
        InsertFor()  //����for���
    }
    else if(szLine == "if")
    {
        InsertIf()   //����if���
    }
    else if(szLine == "el" || szLine == "else")
    {
        InsertElse()  //����else���
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifd") || (szLine == "#ifdef"))
    {
        InsIfdef()        //����#ifdef
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifn") || (szLine == "#ifndef"))
    {
        InsIfndef()        //����#ifdef
        DelBufLine(hbuf,ln)
        stop
    }    
    else if (szLine == "abg")
    {
        InsertReviseAdd()
        DelBufLine(hbuf, ln)
        stop
    }
    else if (szLine == "dbg")
    {
        InsertReviseDel()
        DelBufLine(hbuf, ln)
        stop
    }
    else if (szLine == "mbg")
    {
        InsertReviseMod()
        DelBufLine(hbuf, ln)
        stop
    }
    else if(szLine == "#if")
    {
        InsertPredefIf()
        DelBufLine(hbuf,ln)
        stop
    }
    DelBufLine(hbuf,ln)
    SearchForward()
    stop
}

/*****************************************************************************
 �� �� ��  : RestoreCommand
 ��������  : ��������ָ�����
 �������  : hbuf   
             szCmd  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RestoreCommand(hbuf,szCmd)
{
    if(szCmd == "ca")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "case"
    }
    else if(szCmd == "sw") 
    {
        SetBufSelText(hbuf, "itch")
        szCmd = "switch"
    }
    else if(szCmd == "el")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "else"
    }
    else if(szCmd == "wh")
    {
        SetBufSelText(hbuf, "ile")
        szCmd = "while"
    }
    return szCmd
}

/*****************************************************************************
 �� �� ��  : SearchForward
 ��������  : ��ǰ����#
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchForward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Forward
}

/*****************************************************************************
 �� �� ��  : SearchBackward
 ��������  : �������#
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchBackward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Backward
}

/*****************************************************************************
 �� �� ��  : InsertFuncName
 ��������  : �ڵ�ǰλ�ò��뵫ǰ������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFuncName()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    symbolname = GetCurSymbol()
    SetBufSelText (hbuf, symbolname)
}

/*****************************************************************************
 �� �� ��  : FindInStr
 ��������  : �ַ���ƥ���ѯ����
 �������  : str1  Դ��
             str2  ��ƥ���Ӵ�
 �������  : ��
 �� �� ֵ  : 0xffffffffΪû���ҵ�ƥ���ַ�����V2.1��֧��-1�ʲ��ø�ֵ
             ����Ϊƥ���ַ�������ʼλ��
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FindInStr(str1,str2)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if((len1 == 0) || (len2 == 0))
    {
        return 0xffffffff
    }
    while( i < len1)
    {
        if(str1[i] == str2[j])
        {
            while(j < len2)
            {
                j = j + 1
                if(str1[i+j] != str2[j]) 
                {
                    break
                }
            }     
            if(j == len2)
            {
                return i
            }
            j = 0
        }
        i = i + 1      
    }  
    return 0xffffffff
}

/*****************************************************************************
 �� �� ��  : InsertTraceInfo
 ��������  : �ں�������ںͳ��ڲ����ӡ,��֧��һ���ж����������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTraceInfo()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    symbol = GetSymbolLocationFromLn(hbuf, sel.lnFirst)
    InsertTraceInCurFunction(hbuf,symbol)
}

/*****************************************************************************
 �� �� ��  : InsertTraceInCurFunction
 ��������  : �ں�������ںͳ��ڲ����ӡ,��֧��һ���ж����������
 �������  : hbuf
             symbol
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTraceInCurFunction(hbuf,symbol)
{
    ln = GetBufLnCur (hbuf)
    symbolname = symbol.Symbol
    nLineEnd = symbol.lnLim
    nExitCount = 1;
    InsBufLine(hbuf, ln, "    VOS_Debug_Trace(\"\\r\\n |@symbolname@() entry--- \");")
    ln = ln + 1
    fIsEnd = 1
    fIsNeedPrt = 1
    fIsSatementEnd = 1
    szLeftOld = ""
    while(ln < nLineEnd)
    {
        szLine = GetBufLine(hbuf, ln)
        iCurLineLen = strlen(szLine)
        
        /*�޳����е�ע�����*/
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //�����Ƿ���return���
/*        ret =FindInStr(szLine,"return")
        if(ret != 0xffffffff)
        {
            if( (szLine[ret+6] == " " ) || (szLine[ret+6] == "\t" )
                || (szLine[ret+6] == ";" ) || (szLine[ret+6] == "(" ))
            {
                szPre = strmid(szLine,0,ret)
            }
            SetBufIns(hbuf,ln,ret)
            Paren_Right
            sel = GetWndSel(hwnd)
            if( sel.lnLast != ln )
            {
                GetbufLine(hbuf,sel.lnLast)
                RetVal = SkipCommentFromString(szLine,1)
                szLine = RetVal.szContent
                fIsEnd = RetVal.fIsEnd
            }
        }*/
        //�����߿հ״�С
        nLeft = GetLeftBlank(szLine)
        if(nLeft == 0)
        {
            szLeft = "    "
        }
        else
        {
            szLeft = strmid(szLine,0,nLeft)
        }
        szLine = TrimString(szLine)
        iLen = strlen(szLine)
        if(iLen == 0)
        {
            ln = ln + 1
            continue
        }
        szRet = GetFirstWord(szLine)
//        if( (szRet == "if") || (szRet == "else")
        //�����Ƿ���return���
//        ret =FindInStr(szLine,"return")
        
        if( szRet == "return")
        {
            if( fIsSatementEnd == 0)
            {
                fIsNeedPrt = 1
                InsBufLine(hbuf,ln+1,"@szLeftOld@}")
                szEnd = cat(szLeft,"VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")
                InsBufLine(hbuf, ln, szEnd )
                InsBufLine(hbuf,ln,"@szLeftOld@{")
                nExitCount = nExitCount + 1
                nLineEnd = nLineEnd + 3
                ln = ln + 3
            }
            else
            {
                fIsNeedPrt = 0
                szEnd = cat(szLeft,"VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")
                InsBufLine(hbuf, ln, szEnd )
                nExitCount = nExitCount + 1
                nLineEnd = nLineEnd + 1
                ln = ln + 1
            }
        }
        else
        {
                ret =FindInStr(szLine,"}")
                if( ret != 0xffffffff )
                {
                    fIsNeedPrt = 1
                }
        }
        
        szLeftOld = szLeft
        ch = szLine[iLen-1] 
        if( ( ch  == ";" ) || ( ch  == "{" ) 
             || ( ch  == ":" )|| ( ch  == "}" ) || ( szLine[0] == "#" ))
        {
            fIsSatementEnd = 1
        }
        else
        {
            fIsSatementEnd = 0
        }
        ln = ln + 1
    }
    
    //ֻҪǰ���return����һ��"}"��˵�������Ľ�βû�з��أ���Ҫ�ټ�һ�����ڴ�ӡ
    if(fIsNeedPrt == 1)
    {
        InsBufLine(hbuf, ln,  "    VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")        
        InsBufLine(hbuf, ln,  "")        
    }
}

/*****************************************************************************
 �� �� ��  : GetFirstWord
 ��������  : ȡ���ַ����ĵ�һ������
 �������  : szLine
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFirstWord(szLine)
{
    szLine = TrimLeft(szLine)
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen)
    {
        if( (szLine[nIdx] == " ") || (szLine[nIdx] == "\t") 
          || (szLine[nIdx] == ";") || (szLine[nIdx] == "(")
          || (szLine[nIdx] == ".") || (szLine[nIdx] == "{")
          || (szLine[nIdx] == ",") || (szLine[nIdx] == ":") )
        {
            return strmid(szLine,0,nIdx)
        }
        nIdx = nIdx + 1
    }
    return ""
    
}

/*****************************************************************************
 �� �� ��  : AutoInsertTraceInfoInBuf
 ��������  : �Զ���ǰ�ļ���ȫ����������ڼ����ӡ��ֻ��֧��C++
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AutoInsertTraceInfoInBuf()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)

    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        symbol = GetBufSymLocation(hbuf, isym)
        isCodeBegin = 0
        fIsEnd = 1
        isBlandLine = 0
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
                {
                        hsyml = SymbolChildren(symbol)
                                cchild = SymListCount(hsyml)
                                ichild = 0
                        while (ichild < cchild)
                                {
                    symbol = GetBufSymLocation(hbuf, isym)
                        hsyml = SymbolChildren(symbol)
                                        childsym = SymListItem(hsyml, ichild)
                    ln = childsym.lnName 
                    isCodeBegin = 0
                    fIsEnd = 1
                    isBlandLine = 0
                    while( ln < childsym.lnLim )
                    {   
                        szLine = GetBufLine (hbuf, ln)
                        
                        //ȥ��ע�͵ĸ���
                        RetVal = SkipCommentFromString(szLine,fIsEnd)
                                szNew = RetVal.szContent
                                fIsEnd = RetVal.fIsEnd
                        if(isCodeBegin == 1)
                        {
                            szNew = TrimLeft(szNew)
                            //����Ƿ��ǿ�ִ�д��뿪ʼ
                            iRet = CheckIsCodeBegin(szNew)
                            if(iRet == 1)
                            {
                                if( isBlandLine != 0 )
                                {
                                    ln = isBlandLine
                                }
                                InsBufLine(hbuf,ln,"")
                                childsym.lnLim = childsym.lnLim + 1
                                SetBufIns(hbuf, ln+1 , 0)
                                InsertTraceInCurFunction(hbuf,childsym)
                                break
                            }
                            if(strlen(szNew) == 0) 
                            {
                                if( isBlandLine == 0 ) 
                                {
                                    isBlandLine = ln;
                                }
                            }
                            else
                            {
                                isBlandLine = 0
                            }
                        }
                                //���ҵ������Ŀ�ʼ
                                if(isCodeBegin == 0)
                                {
                                iRet = FindInStr(szNew,"{")
                            if(iRet != 0xffffffff)
                            {
                                isCodeBegin = 1
                            }
                        }
                        ln = ln + 1
                    }
                    ichild = ichild + 1
                                }
                        SymListFree(hsyml)
                }
            else if( ( symbol.Type == "Function") ||  (symbol.Type == "Method") )
            {
                ln = symbol.lnName     
                while( ln < symbol.lnLim )
                {   
                    szLine = GetBufLine (hbuf, ln)
                    
                    //ȥ��ע�͵ĸ���
                    RetVal = SkipCommentFromString(szLine,fIsEnd)
                        szNew = RetVal.szContent
                        fIsEnd = RetVal.fIsEnd
                    if(isCodeBegin == 1)
                    {
                        szNew = TrimLeft(szNew)
                        //����Ƿ��ǿ�ִ�д��뿪ʼ
                        iRet = CheckIsCodeBegin(szNew)
                        if(iRet == 1)
                        {
                            if( isBlandLine != 0 )
                            {
                                ln = isBlandLine
                            }
                            SetBufIns(hbuf, ln , 0)
                            InsertTraceInCurFunction(hbuf,symbol)
                            InsBufLine(hbuf,ln,"")
                            break
                        }
                        if(strlen(szNew) == 0) 
                        {
                            if( isBlandLine == 0 ) 
                            {
                                isBlandLine = ln;
                            }
                        }
                        else
                        {
                            isBlandLine = 0
                        }
                    }
                        //���ҵ������Ŀ�ʼ
                        if(isCodeBegin == 0)
                        {
                                iRet = FindInStr(szNew,"{")
                        if(iRet != 0xffffffff)
                        {
                            isCodeBegin = 1
                        }
                    }
                    ln = ln + 1
                }
            }
        }
        isym = isym + 1
    }
    
}

/*****************************************************************************
 �� �� ��  : CheckIsCodeBegin
 ��������  : �Ƿ�Ϊ�����ĵ�һ����ִ�д���
 �������  : szLine ���û�пո��ע�͵��ַ���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckIsCodeBegin(szLine)
{
    iLen = strlen(szLine)
    if(iLen == 0)
    {
        return 0
    }
    nIdx = 0
    nWord = 0
    if( (szLine[nIdx] == "(") || (szLine[nIdx] == "-") 
           || (szLine[nIdx] == "*") || (szLine[nIdx] == "+"))
    {
        return 1
    }
    if( szLine[nIdx] == "#" )
    {
        return 0
    }
    while(nIdx < iLen)
    {
        if( (szLine[nIdx] == " ")||(szLine[nIdx] == "\t") 
             || (szLine[nIdx] == "(")||(szLine[nIdx] == "{")
             || (szLine[nIdx] == ";") )
        {
            if(nWord == 0)
            {
                if( (szLine[nIdx] == "(")||(szLine[nIdx] == "{")
                         || (szLine[nIdx] == ";")  )
                {
                    return 1
                }
                szFirstWord = StrMid(szLine,0,nIdx)
                if(szFirstWord == "return")
                {
                    return 1
                }
            }
            while(nIdx < iLen)
            {
                if( (szLine[nIdx] == " ")||(szLine[nIdx] == "\t") )
                {
                    nIdx = nIdx + 1
                }
                else
                {
                    break
                }
            }
            nWord = nWord + 1
            if(nIdx == iLen)
            {
                return 1
            }
        }
        if(nWord == 1)
        {
            asciiA = AsciiFromChar("A")
            asciiZ = AsciiFromChar("Z")
            ch = toupper(szLine[nIdx])
            asciiCh = AsciiFromChar(ch)
            if( ( szLine[nIdx] == "_" ) || ( szLine[nIdx] == "*" )
                 || ( ( asciiCh >= asciiA ) && ( asciiCh <= asciiZ ) ) )
            {
                return 0
            }
            else
            {
                return 1
            }
        }
        nIdx = nIdx + 1
    }
    return 1
}

/*****************************************************************************
 �� �� ��  : AutoInsertTraceInfoInPrj
 ��������  : �Զ���ǰ����ȫ���ļ���ȫ����������ڼ����ӡ��ֻ��֧��C++
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AutoInsertTraceInfoInPrj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        szExt = toupper(GetFileNameExt(filename))
        if( (szExt == "C") || (szExt == "CPP") )
        {
            hbuf = OpenBuf (filename)
            if(hbuf != 0)
            {
                SetCurrentBuf(hbuf)
                AutoInsertTraceInfoInBuf()
            }
        }
        //�Զ�������ļ����ɸ�����Ҫ��
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemoveTraceInfo
 ��������  : ɾ���ú����ĳ���ڴ�ӡ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemoveTraceInfo()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    if(hbuf == hNil)
       stop
    symbolname = GetCurSymbol()
    symbol = GetSymbolLocationFromLn(hbuf, sel.lnFirst)
//    symbol = GetSymbolLocation (symbolname)
    nLineEnd = symbol.lnLim
    szEntry = "VOS_Debug_Trace(\"\\r\\n |@symbolname@() entry--- \");"
    szExit = "VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---:" 
    ln = symbol.lnName
    fIsEntry = 0
    while(ln < nLineEnd)
    {
        szLine = GetBufLine(hbuf, ln)
        
        /*�޳����е�ע�����*/
        RetVal = TrimString(szLine)
        if(fIsEntry == 0)
        {
            ret = FindInStr(szLine,szEntry)
            if(ret != 0xffffffff)
            {
                DelBufLine(hbuf,ln)
                nLineEnd = nLineEnd - 1
                fIsEntry = 1
                ln = ln + 1
                continue
            }
        }
        ret = FindInStr(szLine,szExit)
        if(ret != 0xffffffff)
        {
            DelBufLine(hbuf,ln)
            nLineEnd = nLineEnd - 1
        }
        ln = ln + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemoveCurBufTraceInfo
 ��������  : �ӵ�ǰ��buf��ɾ�����ӵĳ���ڴ�ӡ��Ϣ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemoveCurBufTraceInfo()
{
    hbuf = GetCurrentBuf()
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
                {
                        hsyml = SymbolChildren(symbol)
                                cchild = SymListCount(hsyml)
                                ichild = 0
                        while (ichild < cchild)
                                {
                        hsyml = SymbolChildren(symbol)
                                        childsym = SymListItem(hsyml, ichild)
                    SetBufIns(hbuf,childsym.lnName,0)
                    RemoveTraceInfo()
                                        ichild = ichild + 1
                                }
                        SymListFree(hsyml)
                }
            else if( ( symbol.Type == "Function") ||  (symbol.Type == "Method") )
            {
                SetBufIns(hbuf,symbol.lnName,0)
                RemoveTraceInfo()
            }
        }
        isym = isym + 1
    }
}

/*****************************************************************************
 �� �� ��  : RemovePrjTraceInfo
 ��������  : ɾ�������е�ȫ������ĺ����ĳ���ڴ�ӡ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RemovePrjTraceInfo()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            SetCurrentBuf(hbuf)
            RemoveCurBufTraceInfo()
        }
        //�Զ�������ļ����ɸ�����Ҫ��
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

macro TQPInsertFileHeaderEN(hbuf, ln)
{
    InsBufLine(hbuf, ln + 1, "")
    InsBufLine(hbuf, ln + 2, "/*==============================================*")
    InsBufLine(hbuf, ln + 3, " *      include header files                    *")
    InsBufLine(hbuf, ln + 4, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 5, "")
    InsBufLine(hbuf, ln + 6, "")
    InsBufLine(hbuf, ln + 7, "")
    InsBufLine(hbuf, ln + 8, "")
    InsBufLine(hbuf, ln + 9, "/*==============================================*")
    InsBufLine(hbuf, ln + 10, " *      constants or macros define              *")
    InsBufLine(hbuf, ln + 11, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 12, "")
    InsBufLine(hbuf, ln + 13, "")
    InsBufLine(hbuf, ln + 14, "/*==============================================*")
    InsBufLine(hbuf, ln + 15, " *      project-wide global variables           *")
    InsBufLine(hbuf, ln + 16, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 17, "")
    InsBufLine(hbuf, ln + 18, "")
    InsBufLine(hbuf, ln + 19, "")
    InsBufLine(hbuf, ln + 20, "/*==============================================*")
    InsBufLine(hbuf, ln + 21, " *      routines' or functions' implementations *")
    InsBufLine(hbuf, ln + 22, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 23, "")

}

/*****************************************************************************
 �� �� ��  : InsertFileHeaderEN
 ��������  : ����Ӣ���ļ�ͷ����
 �������  : hbuf       
             ln         �к�
             szName     ������
             szContent  ������������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileHeaderEN(hbuf, ln,szName,szContent)
{
    
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    GetFunctionList(hbuf,hnewbuf)
    InsBufLine(hbuf, ln + 0,  "/******************************************************************************")
    InsBufLine(hbuf, ln + 1,  "*")
    InsBufLine(hbuf, ln + 2,  "*  Copyright (C), 2001-2005, Huawei Tech. Co., Ltd.")
    InsBufLine(hbuf, ln + 3,  "*")
    InsBufLine(hbuf, ln + 4,  "*******************************************************************************")
    sz = GetFileName(GetBufName (hbuf))
    InsBufLine(hbuf, ln + 5,  "*  File Name     : @sz@")
    InsBufLine(hbuf, ln + 6,  "*  Version       : Initial Draft")
    InsBufLine(hbuf, ln + 7,  "*  Author        : @szName@")
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    InsBufLine(hbuf, ln + 8,  "*  Created       : @sz@/@sz1@/@sz3@")
    InsBufLine(hbuf, ln + 9,  "*  Last Modified :")
    szTmp = "*  Description   : "
    nlnDesc = ln
    iLen = strlen (szContent)
    InsBufLine(hbuf, ln + 10, "*  Description   : @szContent@")
    InsBufLine(hbuf, ln + 11, "*  Function List :")
    
    //���뺯���б�
    ln = InsertFileList(hbuf,hnewbuf,ln + 12) - 12
    closebuf(hnewbuf)
    InsBufLine(hbuf, ln + 11, "*  History:")
    InsBufLine(hbuf, ln + 12, "* ")
    InsBufLine(hbuf, ln + 13, "*       1.  Date         : @sz@/@sz1@/@sz3@")
    InsBufLine(hbuf, ln + 14, "*           Author       : @szName@")
    InsBufLine(hbuf, ln + 15, "*           Modification : Created file")
    InsBufLine(hbuf, ln + 16, "*")
    InsBufLine(hbuf, ln + 17, "******************************************************************************/")
    //TQPInsertFileHeaderEN(hbuf, ln+17);       
/*    
*/    
    if(iLen != 0)
    {
        return ln+17
    }
    
    //���û�й���������������ʾ����
    szContent = Ask("Description")
    SetBufIns(hbuf,nlnDesc + 14,0)
    DelBufLine(hbuf,nlnDesc +10)
    
    //ע���������,�Զ�����
    CommentContent(hbuf,nlnDesc + 10,"*  Description   : ",szContent,0)
    return ln+17
}


/*****************************************************************************
 �� �� ��  : InsertFileHeaderCN
 ��������  : �������������ļ�ͷ˵��
 �������  : hbuf       
             ln         
             szName     
             szContent  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileHeaderCN(hbuf, ln,szName,szContent)
{
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    GetFunctionList(hbuf,hnewbuf)
    InsBufLine(hbuf, ln + 0,  "/******************************************************************************")
    InsBufLine(hbuf, ln + 1,  "")
    InsBufLine(hbuf, ln + 2,  "                  ��Ȩ���� (C), 2001-2011, ��Ϊ�������޹�˾")
    InsBufLine(hbuf, ln + 3,  "")
    InsBufLine(hbuf, ln + 4,  " ******************************************************************************")
    sz = GetFileName(GetBufName (hbuf))
    InsBufLine(hbuf, ln + 5,  "  �� �� ��   : @sz@")
    InsBufLine(hbuf, ln + 6,  "  �� �� ��   : ����")
    InsBufLine(hbuf, ln + 7,  "  ��    ��   : @szName@")
    SysTime = GetSysTime(1)
    szTime = SysTime.Date
    InsBufLine(hbuf, ln + 8,  "  ��������   : @szTime@")
    InsBufLine(hbuf, ln + 9,  "  ����޸�   :")
    iLen = strlen (szContent)
    nlnDesc = ln
    szTmp = "  ��������   : "
    InsBufLine(hbuf, ln + 10, "  ��������   : @szContent@")
    InsBufLine(hbuf, ln + 11, "  �����б�   :")
    
    //���뺯���б�
    ln = InsertFileList(hbuf,hnewbuf,ln + 12) - 12
    closebuf(hnewbuf)
    InsBufLine(hbuf, ln + 12, "  �޸���ʷ   :")
    InsBufLine(hbuf, ln + 13, "  1.��    ��   : @szTime@")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln + 14, "    ��    ��   : @szName@")
    }
    else
    {
       InsBufLine(hbuf, ln + 14, "    ��    ��   : #")
    }
    InsBufLine(hbuf, ln + 15, "    �޸�����   : �����ļ�")    
    InsBufLine(hbuf, ln + 16, "")
    InsBufLine(hbuf, ln + 17, "******************************************************************************/")
    InsBufLine(hbuf, ln + 18, "")
    InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 20, " * �ⲿ����˵��                                 *")
    InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 22, "")
    InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 24, " * �ⲿ����ԭ��˵��                             *")
    InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 26, "")
    InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 28, " * �ڲ�����ԭ��˵��                             *")
    InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 30, "")
    InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 32, " * ȫ�ֱ���                                     *")
    InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 34, "")
    InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 36, " * ģ�鼶����                                   *")
    InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 38, "")
    InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 40, " * ��������                                     *")
    InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 42, "")
    InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 44, " * �궨��                                       *")
    InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 46, "")
    if(strlen(szContent) != 0)
    {
        return
    }
    
    //���û�����빦�������Ļ���ʾ����
    szContent = Ask("�������ļ���������������")
    SetBufIns(hbuf,nlnDesc + 14,0)
    DelBufLine(hbuf,nlnDesc +10)
    
    //�Զ�������ʾ��������
    CommentContent(hbuf,nlnDesc+10,"  ��������   : ",szContent,0)
}

/*****************************************************************************
 �� �� ��  : GetFunctionList
 ��������  : ��ú����б�
 �������  : hbuf  
             hnewbuf    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFunctionList(hbuf,hnewbuf)
{
    isymMax = GetBufSymCount (hbuf)
    isym = 0
    //����ȡ��ȫ���ĵ�ǰbuf���ű��е�ȫ������
    while (isym < isymMax) 
    {
        symbol = GetBufSymLocation(hbuf, isym)
        if(symbol.Type == "Class Placeholder")
        {
                hsyml = SymbolChildren(symbol)
                        cchild = SymListCount(hsyml)
                        ichild = 0
                while (ichild < cchild)
                        {
                                childsym = SymListItem(hsyml, ichild)
                AppendBufLine(hnewbuf,childsym.symbol)
                                ichild = ichild + 1
                        }
                SymListFree(hsyml)
        }
        if(strlen(symbol) > 0)
        {
            if( (symbol.Type == "Method") || 
                (symbol.Type == "Function") || ("Editor Macro" == symbol.Type) )
            {
                //ȡ�������Ǻ����ͺ�ķ���
                symname = symbol.Symbol
                //�����Ų��뵽��buf����������Ϊ�˼���V2.1
                AppendBufLine(hnewbuf,symname)
               }
           }
        isym = isym + 1
    }
}
/*****************************************************************************
 �� �� ��  : InsertFileList
 ��������  : �����б�����
 �������  : hbuf  
             ln    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileList(hbuf,hnewbuf,ln)
{
    if(hnewbuf == hNil)
    {
        return ln
    }
    isymMax = GetBufLineCount (hnewbuf)
    //isym = 0
    isym = 1
    InsBufLine(hbuf,ln,"*")
    ln = ln + 1
    //while (isym < isymMax) 
    while (isym <= isymMax) 
    {
        szLine = GetBufLine(hnewbuf, isym-1)
        //szLine = GetBufLine(hnewbuf, isym)
        InsBufLine(hbuf,ln,"*       @isym@.                @szLine@")
        ln = ln + 1
        isym = isym + 1
    }
    InsBufLine(hbuf,ln,"*")
    ln = ln + 2
    return ln 
}


/*****************************************************************************
 �� �� ��  : CommentContent1
 ��������  : �Զ�������ʾ�ı�,��Ϊmsg�Ի����ܴ������е���������Ҳ��ܳ���255
             ���ַ�����Ϊ���У������˴Ӽ�����ȡ���ݵİ취���������������Ǽ�
             ���������ݵ�ǰ���ֵĻ�����Ϊ�û��ǿ��������ݣ���������Ȼ�п�����
             �󣬵����ָ��ʷǳ��͡���CommentContent��ͬ���������������е�����
             �ϲ���һ�������������Ը�����Ҫѡ�������ַ�ʽ
 �������  : hbuf       
             ln         �к�
             szPreStr   ������Ҫ������ַ���
             szContent  ��Ҫ������ַ�������
             isEnd      �Ƿ���Ҫ��ĩβ����'*'��'/'
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CommentContent1 (hbuf,ln,szPreStr,szContent,isEnd)
{
    //���������еĶ���ı��ϲ�
    szClip = MergeString()
    //ȥ������Ŀո�
    szTmp = TrimString(szContent)
    //������봰���е������Ǽ������е�����˵���Ǽ���������
    ret = FindInStr(szClip,szTmp)
    if(ret == 0)
    {
        szContent = szClip
    }
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }
    iLen = strlen (szContent)
    szTmp = cat(szPreStr,"#");
    if( iLen == 0)
    {
        InsBufLine(hbuf, ln, "@szTmp@")
    }
    else
    {
        i = 0
        while  (iLen - i > 75 - k )
        {
            j = 0
            while(j < 75 - k)
            {
                iNum = szContent[i + j]
                //��������ı���ɶԴ���
                if( AsciiFromChar (iNum)  > 160 )
                {
                   j = j + 2
                }
                else
                {
                   j = j + 1
                }
                if( (j > 70 - k) && (szContent[i + j] == " ") )
                {
                    break
                }
            }
            if( (szContent[i + j] != " " ) )
            {
                n = 0;
                iNum = szContent[i + j + n]
                while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                {
                    n = n + 1
                    if((n >= 3) ||(i + j + n >= iLen))
                         break;
                    iNum = szContent[i + j + n]
                   }
                if(n < 3)
                {
                    j = j + n 
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)                
                }
                else
                {
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                    if(sz1[strlen(sz1)-1] != "-")
                    {
                        sz1 = cat(sz1,"-")                
                    }
                }
            }
            else
            {
                sz1 = strmid(szContent,i,i+j)
                sz1 = cat(szPreStr,sz1)
            }
            InsBufLine(hbuf, ln, "@sz1@")
            ln = ln + 1
            szPreStr = szLeftBlank
            i = i + j
            while(szContent[i] == " ")
            {
                i = i + 1
            }
        }
        sz1 = strmid(szContent,i,iLen)
        sz1 = cat(szPreStr,sz1)
        if(isEnd)
        {
            sz1 = cat(sz1,"*/")
        }
        InsBufLine(hbuf, ln, "@sz1@")
    }
    return ln
}



/*****************************************************************************
 �� �� ��  : CommentContent
 ��������  : �Զ�������ʾ�ı�,��Ϊmsg�Ի����ܴ������е���������Ҳ��ܳ���255
             ���ַ�����Ϊ���У������˴Ӽ�����ȡ���ݵİ취���������������Ǽ�
             ���������ݵ�ǰ���ֵĻ�����Ϊ�û��ǿ��������ݣ���������Ȼ�п�����
             �󣬵����ָ��ʷǳ���
 �������  : hbuf       
             ln         �к�
             szPreStr   ������Ҫ������ַ���
             szContent  ��Ҫ������ַ�������
             isEnd      �Ƿ���Ҫ��ĩβ����'*'��'/'
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CommentContent (hbuf,ln,szPreStr,szContent,isEnd)
{
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }

    hNewBuf = newbuf("clip")
    if(hNewBuf == hNil)
        return       
    SetCurrentBuf(hNewBuf)
    PasteBufLine (hNewBuf, 0)
    lnMax = GetBufLineCount( hNewBuf )
    szTmp = TrimString(szContent)

    //�ж������������0��ʱ������Щ�汾�������⣬Ҫ�ų���
    if(lnMax != 0)
    {
        szLine = GetBufLine(hNewBuf , 0)
            ret = FindInStr(szLine,szTmp)
            if(ret == 0)
            {
                /*������봰����������Ǽ������һ����˵���Ǽ���������ȡ�������е���
                  ��*/
                szContent = TrimString(szLine)
            }
            else
            {
                lnMax = 1
            }       
    }
    else
    {
        lnMax = 1
    }    
    szRet = ""
    nIdx = 0
    while ( nIdx < lnMax) 
    {
        if(nIdx != 0)
        {
            szLine = GetBufLine(hNewBuf , nIdx)
            szContent = TrimLeft(szLine)
               szPreStr = szLeftBlank
        }
        iLen = strlen (szContent)
        szTmp = cat(szPreStr,"#");
        if( (iLen == 0) && (nIdx == (lnMax - 1))
        {
            InsBufLine(hbuf, ln, "@szTmp@")
        }
        else
        {
            i = 0
            //��ÿ��75���ַ�����
            while  (iLen - i > 75 - k )
            {
                j = 0
                while(j < 75 - k)
                {
                    iNum = szContent[i + j]
                    if( AsciiFromChar (iNum)  > 160 )
                    {
                       j = j + 2
                    }
                    else
                    {
                       j = j + 1
                    }
                    if( (j > 70 - k) && (szContent[i + j] == " ") )
                    {
                        break
                    }
                }
                if( (szContent[i + j] != " " ) )
                {
                    n = 0;
                    iNum = szContent[i + j + n]
                    //����������ַ�ֻ�ܳɶԴ���
                    while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                    {
                        n = n + 1
                        if((n >= 3) ||(i + j + n >= iLen))
                             break;
                        iNum = szContent[i + j + n]
                    }
                    if(n < 3)
                    {
                        //�ֶκ�ֻ��С��3�����ַ������¶���������ȥ
                        j = j + n 
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)                
                    }
                    else
                    {
                        //����3���ַ��ļ����ַ��ֶ�
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)
                        if(sz1[strlen(sz1)-1] != "-")
                        {
                            sz1 = cat(sz1,"-")                
                        }
                    }
                }
                else
                {
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                }
                InsBufLine(hbuf, ln, "@sz1@")
                ln = ln + 1
                szPreStr = szLeftBlank
                i = i + j
                while(szContent[i] == " ")
                {
                    i = i + 1
                }
            }
            sz1 = strmid(szContent,i,iLen)
            sz1 = cat(szPreStr,sz1)
            if((isEnd == 1) && (nIdx == (lnMax - 1))
            {
                sz1 = cat(sz1," */")
            }
            InsBufLine(hbuf, ln, "@sz1@")
        }
        ln = ln + 1
        nIdx = nIdx + 1
    }
    closebuf(hNewBuf)
    return ln - 1
}

/*****************************************************************************
 �� �� ��  : FormatLine
 ��������  : ��һ�г��ı������Զ�����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FormatLine()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.ichFirst > 70)
    {
        Msg("ѡ��̫������")
        stop 
    }
    hbuf = GetWndBuf(hwnd)
    // get line the selection (insertion point) is on
    szCurLine = GetBufLine(hbuf, sel.lnFirst);
    lineLen = strlen(szCurLine)
    szLeft = strmid(szCurLine,0,sel.ichFirst)
    szContent = strmid(szCurLine,sel.ichFirst,lineLen)
    DelBufLine(hbuf, sel.lnFirst)
    CommentContent(hbuf,sel.lnFirst,szLeft,szContent,0)            

}

/*****************************************************************************
 �� �� ��  : CreateBlankString
 ��������  : ���������ո���ַ���
 �������  : nBlankCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateBlankString(nBlankCount)
{
    szBlank=""
    nIdx = 0
    while(nIdx < nBlankCount)
    {
        szBlank = cat(szBlank," ")
        nIdx = nIdx + 1
    }
    return szBlank
}

/*****************************************************************************
 �� �� ��  : TrimLeft
 ��������  : ȥ���ַ�����ߵĿո�
 �������  : szLine  
 �������  : ȥ����ո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimLeft(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = 0
    while( nIdx < nLen )
    {
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
        nIdx = nIdx + 1
    }
    return strmid(szLine,nIdx,nLen)
}

/*****************************************************************************
 �� �� ��  : TrimRight
 ��������  : ȥ���ַ����ұߵĿո�
 �������  : szLine  
 �������  : ȥ���ҿո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimRight(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = nLen
    while( nIdx > 0 )
    {
        nIdx = nIdx - 1
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
    }
    return strmid(szLine,0,nIdx+1)
}

/*****************************************************************************
 �� �� ��  : TrimString
 ��������  : ȥ���ַ������ҿո�
 �������  : szLine  
 �������  : ȥ�����ҿո����ַ���
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
}


/*****************************************************************************
 �� �� ��  : GetFunctionDef
 ��������  : ���ֳɶ��еĺ�������ͷ�ϲ���һ��
 �������  : hbuf    
             symbol  ��������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFunctionDef(hbuf,symbol)
{
    ln = symbol.lnName
    szFunc = ""
    if(strlen(symbol) == 0)
    {
       return szFunc
    }
    fIsEnd = 1
//    msg(symbol)
    while(ln < symbol.lnLim)
    {
        szLine = GetBufLine (hbuf, ln)
        //ȥ����ע�͵�������
        RetVal = SkipCommentFromString(szLine,fIsEnd)
                szLine = RetVal.szContent
                szLine = TrimString(szLine)
                fIsEnd = RetVal.fIsEnd
        //�����'{'��ʾ��������ͷ������
        ret = FindInStr(szLine,"{")        
        if(ret != 0xffffffff)
        {
            szLine = strmid(szLine,0,ret)
            szFunc = cat(szFunc,szLine)
            break
        }
        szFunc = cat(szFunc,szLine)        
        ln = ln + 1
    }
    return szFunc
}

/*****************************************************************************
 �� �� ��  : GetWordFromString
 ��������  : ���ַ�����ȡ����ĳ�ַ�ʽ�ָ���ַ�����
 �������  : hbuf         ���ɷָ���ַ�����buf
             szLine       �ַ���
             nBeg         ��ʼ����λ��
             nEnd         ��������λ��
             chBeg        ��ʼ���ַ���־
             chSeparator  �ָ��ַ�
             chEnd        �����ַ���־
 �������  : ����ַ�����
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetWordFromString(hbuf,szLine,nBeg,nEnd,chBeg,chSeparator,chEnd)
{
    if((nEnd > strlen(szLine) || (nBeg > nEnd))
    {
        return 0
    }
    nMaxLen = 0
    nIdx = nBeg
    //�ȶ�λ����ʼ�ַ���Ǵ�
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chBeg)
        {
            break
        }
        nIdx = nIdx + 1
    }
    nBegWord = nIdx + 1
    
    //���ڼ��chBeg��chEnd��������
    iCount = 0
    
    nEndWord = 0
    //�Էָ���Ϊ��ǽ�������
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chSeparator)
        {
           szWord = strmid(szLine,nBegWord,nIdx)
           szWord = TrimString(szWord)
           nLen = strlen(szWord)
           if(nMaxLen < nLen)
           {
               nMaxLen = nLen
           }
           AppendBufLine(hbuf,szWord)
           nBegWord = nIdx + 1
        }
        if(szLine[nIdx] == chBeg)
        {
            iCount = iCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            iCount = iCount - 1
            nEndWord = nIdx
            if( iCount == 0 )
            {
                break
            }
        }
        nIdx = nIdx + 1
    }
    if(nEndWord > nBegWord)
    {
        szWord = strmid(szLine,nBegWord,nEndWord)
        szWord = TrimString(szWord)
        nLen = strlen(szWord)
        if(nMaxLen < nLen)
        {
            nMaxLen = nLen
        }
        AppendBufLine(hbuf,szWord)
    }
    return nMaxLen
}


/*****************************************************************************
 �� �� ��  : FuncHeadCommentCN
 ��������  : �������ĵĺ���ͷע��
 �������  : hbuf      
             ln        �к�
             szFunc    ������
             szMyName  ������
             newFunc   �Ƿ��º���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FuncHeadCommentCN(hbuf, ln, szFunc, szMyName,newFunc)
{
    iIns = 0
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
            if(hTmpBuf == hNil)
            {
                stop
            }
            //���ļ�����ͷ������һ�в�ȥ����ע��
            szLine = GetFunctionDef(hbuf,symbol)            
            iBegin = symbol.ichName 
            //ȡ������ֵ����
            szTemp = strmid(szLine,0,iBegin)
            szRet = TrimString(szTemp)
            //szRet =  GetFirstWord(szTemp)
            if(symbol.Type == "Method")
            {
                szTemp = strmid(szTemp,strlen(szRet),strlen(szTemp))
                szTemp = TrimString(szTemp)
                if(szTemp == "::")
                {
                    szRet = ""
                }
            }
            if(toupper (szRet) == "MACRO")
            {
                //���ں귵��ֵ���⴦��
                szRet = ""
            }
            //�Ӻ���ͷ�������������
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        szLine = ""
        szRet = ""
    }
    InsBufLine(hbuf, ln, "/*****************************************************************************")
    if( strlen(szFunc)>0 )
    {
        InsBufLine(hbuf, ln+1, " �� �� ��  : @szFunc@")
    }
    else
    {
        InsBufLine(hbuf, ln+1, " �� �� ��  : #")
    }
    oldln = ln
    InsBufLine(hbuf, ln+2, " ��������  : ")
    szIns = " �������  : "
    if(newFunc != 1)
    {
        //�����Ѿ����ڵĺ������뺯������
        i = 0
        while ( i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)
            nLen = strlen(szTmp);
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            szTmp = cat(szTmp,szBlank)
            ln = ln + 1
            szTmp = cat(szIns,szTmp)
            InsBufLine(hbuf, ln+2, "@szTmp@")
            iIns = 1
            szIns = "             "
            i = i + 1
        }    
        closebuf(hTmpBuf)
    }
    if(iIns == 0)
    {       
            ln = ln + 1
            InsBufLine(hbuf, ln+2, " �������  : ��")
    }
    InsBufLine(hbuf, ln+3, " �������  : ��")
    InsBufLine(hbuf, ln+4, " �� �� ֵ  : @szRet@")
    InsBufLine(hbuf, ln+5, " ���ú���  : ")
    InsBufLine(hbuf, ln+6, " ��������  : ")
    InsbufLIne(hbuf, ln+7, " ");
    InsBufLine(hbuf, ln+8, " �޸���ʷ      :")
    SysTime = GetSysTime(1);
    szTime = SysTime.Date

    InsBufLine(hbuf, ln+9, "  1.��    ��   : @szTime@")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln+10, "    ��    ��   : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln+10, "    ��    ��   : #")
    }
    InsBufLine(hbuf, ln+11, "    �޸�����   : �����ɺ���")    
    InsBufLine(hbuf, ln+12, "")    
    InsBufLine(hbuf, ln+13, "*****************************************************************************/")
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        InsBufLine(hbuf, ln+14, "VOS_UINT32  @szFunc@( # )")
        InsBufLine(hbuf, ln+15, "{");
        InsBufLine(hbuf, ln+16, "    ");
        InsBufLine(hbuf, ln+17, "}");
        SearchForward()
    }        
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 14
    sel.lnLast = ln + 14        
    szContent = Ask("�����뺯����������������")
    setWndSel(hwnd,sel)
    DelBufLine(hbuf,oldln + 2)

    //��ʾ����Ĺ�����������
    newln = CommentContent(hbuf,oldln+2," ��������  : ",szContent,0) - 2
    ln = ln + newln - oldln
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        isFirstParam = 1
            
        //��ʾ�����º����ķ���ֵ
        szRet = Ask("�����뷵��ֵ����")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+4, " �� �� ֵ  : @szRet@")            
            PutBufLine(hbuf, ln+14, "@szRet@ @szFunc@(   )")
            SetbufIns(hbuf,ln+14,strlen(szRet)+strlen(szFunc) + 3
        }
        szFuncDef = ""
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 3
        sel.ichLim = sel.ichFirst + 1
        //ѭ���������
        while (1)
        {
            szParam = ask("�����뺯��������")
            szParam = TrimString(szParam)
            szTmp = cat(szIns,szParam)
            szParam = cat(szFuncDef,szParam)
            sel.lnFirst = ln + 14
            sel.lnLast = ln + 14
            setWndSel(hwnd,sel)
            sel.ichFirst = sel.ichFirst + strlen(szParam)
            sel.ichLim = sel.ichFirst
            oldsel = sel
            if(isFirstParam == 1)
            {
                PutBufLine(hbuf, ln+2, "@szTmp@")
                isFirstParam  = 0
            }
            else
            {
                ln = ln + 1
                InsBufLine(hbuf, ln+2, "@szTmp@")
                oldsel.lnFirst = ln + 14
                oldsel.lnLast = ln + 14        
            }
            SetBufSelText(hbuf,szParam)
            szIns = "             "
            szFuncDef = ", "
            oldsel.lnFirst = ln + 16
            oldsel.lnLast = ln + 16
            oldsel.ichFirst = 4
            oldsel.ichLim = 5
            setWndSel(hwnd,oldsel)
        }
    }
    return ln + 17
}

/*****************************************************************************
 �� �� ��  : FuncHeadCommentEN
 ��������  : ����ͷӢ��˵��
 �������  : hbuf      
             ln        
             szFunc    
             szMyName  
             newFunc   
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FuncHeadCommentEN(hbuf, ln, szFunc, szMyName,newFunc)
{
    iIns = 0
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
                
            //���ļ�����ͷ������һ�в�ȥ����ע��
            szLine = GetFunctionDef(hbuf,symbol)
            iBegin = symbol.ichName
            
            //ȡ������ֵ����
            szTemp = strmid(szLine,0,iBegin)
            szRet = TrimString(szTemp)
            // szTemp = TrimString(szTemp)
            // szRet =  GetFirstWord(szTemp)
            if(symbol.Type == "Method")
            {
                szTemp = strmid(szTemp,strlen(szRet),strlen(szTemp))
                szTemp = TrimString(szTemp)
                if(szTemp == "::")
                {
                    szRet = ""
                }
            }
            if(toupper (szRet) == "MACRO")
            {
                //���ں귵��ֵ���⴦��
                szRet = ""
            }
            
            //�Ӻ���ͷ�������������
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        szRet = ""
        szLine = ""
    }
    InsBufLine(hbuf, ln, "/*****************************************************************************")
    InsBufLine(hbuf, ln+1, "*   Prototype    : @szFunc@")
    InsBufLine(hbuf, ln+2, "*   Description  : ")
    oldln  = ln 
    szIns = "*   Input        : "
    if(newFunc != 1)
    {
        //�����Ѿ����ڵĺ���������������
        i = 0
        while ( i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)
            nLen = strlen(szTmp);
            
            //�����������Ŀո�ʵ���Ƕ������Ĳ�����˵��
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            szTmp = cat(szTmp,szBlank)
            ln = ln + 1
            szTmp = cat(szIns,szTmp)
            InsBufLine(hbuf, ln+2, "@szTmp@")
            iIns = 1
            szIns = "*                  "
            i = i + 1
        }    
        closebuf(hTmpBuf)
    }
    if(iIns == 0)
    {       
            ln = ln + 1
            InsBufLine(hbuf, ln+2, "*   Input        : None")
    }
    InsBufLine(hbuf, ln+3, "*   Output       : None")
    InsBufLine(hbuf, ln+4, "*   Return Value : @szRet@")
    InsBufLine(hbuf, ln+5, "*   Calls        : ")
    InsBufLine(hbuf, ln+6, "*   Called By    : ")
    InsbufLIne(hbuf, ln+7, "*");
    
    SysTime = GetSysTime(1);
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day

    InsBufLine(hbuf, ln + 8, "*   History:")
    InsbufLIne(hbuf, ln + 9, "* ");    
    InsBufLine(hbuf, ln + 10, "*       1.  Date         : @sz1@/@sz2@/@sz3@")
    InsBufLine(hbuf, ln + 11, "*           Author       : @szMyName@")
    InsBufLine(hbuf, ln + 12, "*           Modification : Created function")
    InsBufLine(hbuf, ln + 13, "*")    
    InsBufLine(hbuf, ln + 14, "*****************************************************************************/")
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        InsBufLine(hbuf, ln+15, "VOS_UINT32  @szFunc@( # )")
        InsBufLine(hbuf, ln+16, "{");
        InsBufLine(hbuf, ln+17, "    ");
        InsBufLine(hbuf, ln+18, "}");
        SearchForward()
    }        
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 15
    sel.lnLast = ln + 15        
    szContent = Ask("Description")
    DelBufLine(hbuf,oldln + 2)
    setWndSel(hwnd,sel)
    newln = CommentContent(hbuf,oldln + 2,"*   Description  : ",szContent,0) - 2
    ln = ln + newln - oldln
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        //��ʾ���뺯������ֵ��
        szRet = Ask("Please input return value type")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+4, "*   Return Value : @szRet@")            
            PutBufLine(hbuf, ln+15, "@szRet@ @szFunc@( # )")
            SetbufIns(hbuf,ln+15,strlen(szRet)+strlen(szFunc) + 3
        }
        szFuncDef = ""
        isFirstParam = 1
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 3
        sel.ichLim = sel.ichFirst + 1

        //ѭ�������º����Ĳ���
        while (1)
        {
            szParam = ask("Please input parameter")
            szParam = TrimString(szParam)
            szTmp = cat(szIns,szParam)
            szParam = cat(szFuncDef,szParam)
            sel.lnFirst = ln + 15
            sel.lnLast = ln + 15
            setWndSel(hwnd,sel)
            sel.ichFirst = sel.ichFirst + strlen(szParam)
            sel.ichLim = sel.ichFirst
            oldsel = sel
            if(isFirstParam == 1)
            {
                PutBufLine(hbuf, ln+2, "@szTmp@")
                isFirstParam  = 0
            }
            else
            {
                ln = ln + 1
                InsBufLine(hbuf, ln+2, "@szTmp@")
                oldsel.lnFirst = ln + 15
                oldsel.lnLast = ln + 15        
            }
            SetBufSelText(hbuf,szParam)
            szIns = "*                  "
            szFuncDef = ", "
            oldsel.lnFirst = ln + 17
            oldsel.lnLast = ln + 17
            oldsel.ichFirst = 4
            oldsel.ichLim = 5
            setWndSel(hwnd,oldsel)
        }
    }
    return ln + 10
}

/*****************************************************************************
 �� �� ��  : InsertHistory
 ��������  : �����޸���ʷ��¼
 �������  : hbuf      
             ln        �к�
             language  ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertHistory(hbuf,ln,language)
{
    iHistoryCount = 1
    isLastLine = ln
    i = 0
    while(ln+i>0)
    {
        szCurLine = GetBufLine(hbuf, ln+i);
        iBeg1 = FindInStr(szCurLine,"��    ��")
        iBeg2 = FindInStr(szCurLine,"Date")
        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
        {
            iHistoryCount = iHistoryCount + 1
            i = i + 1
            continue
        }
/****** modify by Tong Qiaoping *************        
        iBeg1 = FindInStr(szCurLine,"��    ��")
        iBeg2 = FindInStr(szCurLine,"History")
        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
        {
            break
        }
**********************************************/        
        iBeg = FindInStr(szCurLine,"/**********************")
        if( iBeg != 0xffffffff )
        {
            break
        }
        iBeg = FindInStr(szCurLine,"**********************/")
        if( iBeg != 0xffffffff )
        {
            break
        }
        i = i + 1
    }
    if(language == 0)
    {
        InsertHistoryContentCN(hbuf,ln,iHistoryCount)
    }
    else
    {
        InsertHistoryContentEN(hbuf,ln,iHistoryCount)
    }
}

/*****************************************************************************
 �� �� ��  : UpdateFunctionList
 ��������  : ���º����б�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro UpdateFunctionList()
{
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    GetFunctionList(hbuf,hnewbuf)
    ln = sel.lnFirst
    iHistoryCount = 1
    isLastLine = ln
    iTotalLn = GetBufLineCount (hbuf) 
    while(ln < iTotalLn)
    {
        szCurLine = GetBufLine(hbuf, ln);
        iLen = strlen(szCurLine)
        j = 0;
        while(j < iLen)
        {
            if(szCurLine[j] != " ")
                break
            j = j + 1
        }
        
        //���ļ�ͷ˵����ǰ�д���10���ո��Ϊ�����б���¼
        if(j > 10)
        {
            DelBufLine(hbuf, ln)   
        }
        else
        {
            break
        }
        iTotalLn = GetBufLineCount (hbuf) 
    }

    //���뺯���б�
    InsertFileList( hbuf,hnewbuf,ln )
    closebuf(hnewbuf)
 }

/*****************************************************************************
 �� �� ��  : InsertHistoryContentCN
 ��������  : ������ʷ�޸ļ�¼����˵��
 �������  : hbuf           
             ln             
             iHostoryCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro  InsertHistoryContentCN(hbuf,ln,iHostoryCount)
{
    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    szMyName = getreg(MYNAME)

    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln + 1, "  @iHostoryCount@.��    ��   : @szTime@")

    if( strlen(szMyName) > 0 )
    {
       InsBufLine(hbuf, ln + 2, "    ��    ��   : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln + 2, "    ��    ��   : #")
    }
       szContent = Ask("�������޸ĵ�����")
       CommentContent(hbuf,ln + 3,"    �޸�����   : ",szContent,0)
}


/*****************************************************************************
 �� �� ��  : InsertHistoryContentEN
 ��������  : ������ʷ�޸ļ�¼Ӣ��˵��
 �������  : hbuf           ��ǰbuf
             ln             ��ǰ�к�
             iHostoryCount  �޸ļ�¼�ı��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro  InsertHistoryContentEN(hbuf,ln,iHostoryCount)
{
    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day
    szMyName = getreg(MYNAME)
    InsBufLine(hbuf, ln, "* ")
    InsBufLine(hbuf, ln + 1, "*       @iHostoryCount@.  Date         : @sz1@/@sz2@/@sz3@")

    InsBufLine(hbuf, ln + 2, "*           Author       : @szMyName@")
       szContent = Ask("Please input modification")
       CommentContent(hbuf,ln + 3,"*           Modification : ",szContent,0)
    InsBufLine(hbuf, ln + 4, "*")       
}

/*****************************************************************************
 �� �� ��  : CreateFunctionDef
 ��������  : ����C����ͷ�ļ�
 �������  : hbuf      
             szName    
             language  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFunctionDef(hbuf, szName, language)
{
    ln = 0

    //��õ�ǰû�к�׺���ļ���
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("������ͷ�ļ���")
        szFileName = GetFileNameNoExt(sz)
        szExt = GetFileNameExt(szFileName)        
        szPreH = toupper (szFileName)
        szPreH = cat("__",szPreH)
        szExt = toupper(szExt)
        szPreH = cat(szPreH,"_@szExt@__")
    }
    szPreH = toupper (szFileName)
    sz = cat(szFileName,".h")
    szPreH = cat("__",szPreH)
    szPreH = cat(szPreH,"_H__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop
    //�������ű�ȡ�ú�����
    SetCurrentBuf(hOutbuf)
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
                {
                        hsyml = SymbolChildren(symbol)
                                cchild = SymListCount(hsyml)
                                ichild = 0
                                szClassName = symbol.Symbol
                InsBufLine(hOutbuf, ln, "}")
                            InsBufLine(hOutbuf, ln, "{")
                            InsBufLine(hOutbuf, ln, "class @szClassName@")
                            ln = ln + 2
                        while (ichild < cchild)
                                {
                                        childsym = SymListItem(hsyml, ichild)
                                        childsym.Symbol = szClassName
                    ln = CreateClassPrototype(hbuf,ln,childsym)
                                        ichild = ichild + 1
                                }
                        SymListFree(hsyml)
                InsBufLine(hOutbuf, ln + 1, "")
                        ln = ln + 2
                }
            else if( symbol.Type == "Function" )
            {
                ln = CreateFuncPrototype(hbuf,ln,"extern",symbol)
            }
            else if( symbol.Type == "Method" ) 
            {
                szLine = GetBufline(hbuf,symbol.lnName)
                szClassName = GetLeftWord(szLine,symbol.ichName)
                symbol.Symbol = szClassName
                ln = CreateClassPrototype(hbuf,ln,symbol)            
            }
            
        }
        isym = isym + 1
    }
    InsertCPP(hOutbuf,0)
    TQPInsertFileHeaderEN(hOutbuf, 6)
    HeadIfdefStr(szPreH)
    szContent = GetFileName(GetBufName (hbuf))
    if(language == 0)
    {
        szContent = cat(szContent," ��ͷ�ļ�")
        //�����ļ�ͷ˵��
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")
        //�����ļ�ͷ˵��
        InsertFileHeaderEN(hOutbuf,0,szName,szContent)        
    }
}


/*****************************************************************************
 �� �� ��  : GetLeftWord
 ��������  : ȡ����ߵĵ���
 �������  : szLine    
             ichRight ��ʼȡ��λ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��05��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetLeftWord(szLine,ichRight)
{
    if(ich == 0)
    {
        return ""
    }
    ich = ichRight
    while(ich > 0)
    {
        if( (szLine[ich] == " ") || (szLine[ich] == "\t")
            || ( szLine[ich] == ":") || (szLine[ich] == "."))

        {
            ich = ich - 1
            ichRight = ich
        }
        else
        {
            break
        }
    }    
    while(ich > 0)
    {
        if(szLine[ich] == " ")
        {
            ich = ich + 1
            break
        }
        ich = ich - 1
    }
    return strmid(szLine,ich,ichRight)
}
/*****************************************************************************
 �� �� ��  : CreateClassPrototype
 ��������  : ����Class�Ķ���
 �������  : hbuf      ��ǰ�ļ�
             hOutbuf   ����ļ�
             ln        ����к�
             symbol    ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��05��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateClassPrototype(hbuf,ln,symbol)
{
    isLastLine = 0
    fIsEnd = 1
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf, symbol.lnName)
    sline = symbol.lnFirst     
    szClassName = symbol.Symbol
    ret = FindInStr(szLine,szClassName)
    if(ret == 0xffffffff)
    {
        return ln
    }
    szPre = strmid(szLine,0,ret)
    szLine = strmid(szLine,symbol.ichName,strlen(szLine))
    szLine = cat(szPre,szLine)
    //ȥ��ע�͵ĸ���
    RetVal = SkipCommentFromString(szLine,fIsEnd)
    fIsEnd = RetVal.fIsEnd
    szNew = RetVal.szContent
    szLine = cat("    ",szLine)
    szNew = cat("    ",szNew)
    while((isLastLine == 0) && (sline < symbol.lnLim))
    {   
        i = 0
        j = 0
        iLen = strlen(szNew)
        while(i < iLen)
        {
            if(szNew[i]=="(")
            {
               j = j + 1;
            }
            else if(szNew[i]==")")
            {
                j = j - 1;
                if(j <= 0)
                {
                    //��������ͷ����
                    isLastLine = 1  
                    //ȥ����������ַ�
                        szLine = strmid(szLine,0,i+1);
                    szLine = cat(szLine,";")
                    break
                }
            }
            i = i + 1
        }
        InsBufLine(hOutbuf, ln, "@szLine@")
        ln = ln + 1
        sline = sline + 1
        if(isLastLine != 1)
        {              
            //��������ͷ��û�н�����ȡһ��
            szLine = GetBufLine (hbuf, sline)
            //ȥ��ע�͵ĸ���
            RetVal = SkipCommentFromString(szLine,fIsEnd)
                szNew = RetVal.szContent
                fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}

/*****************************************************************************
 �� �� ��  : CreateFuncPrototype
 ��������  : ����C����ԭ�Ͷ���
 �������  : hbuf      ��ǰ�ļ�
             hOutbuf   ����ļ�
             ln        ����к�
             szType    ԭ������
             symbol    ����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��05��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFuncPrototype(hbuf,ln,szType,symbol)
{
    isLastLine = 0
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf,symbol.lnName)
    //ȥ��ע�͵ĸ���
    RetVal = SkipCommentFromString(szLine,fIsEnd)
    szNew = RetVal.szContent
    fIsEnd = RetVal.fIsEnd
    szLine = cat("@szType@ ",szLine)
    szNew = cat("@szType@ ",szNew)
    sline = symbol.lnFirst     
    while((isLastLine == 0) && (sline < symbol.lnLim))
    {   
        i = 0
        j = 0
        iLen = strlen(szNew)
        while(i < iLen)
        {
            if(szNew[i]=="(")
            {
               j = j + 1;
            }
            else if(szNew[i]==")")
            {
                j = j - 1;
                if(j <= 0)
                {
                    //��������ͷ����
                    isLastLine = 1  
                    //ȥ����������ַ�
                        szLine = strmid(szLine,0,i+1);
                    szLine = cat(szLine,";")
                    break
                }
            }
            i = i + 1
        }
        InsBufLine(hOutbuf, ln, "@szLine@")
        ln = ln + 1
        sline = sline + 1
        if(isLastLine != 1)
        {              
            //��������ͷ��û�н�����ȡһ��
            szLine = GetBufLine (hbuf, sline)
            szLine = cat("         ",szLine)
            //ȥ��ע�͵ĸ���
            RetVal = SkipCommentFromString(szLine,fIsEnd)
                szNew = RetVal.szContent
                fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}


/*****************************************************************************
 �� �� ��  : CreateNewHeaderFile
 ��������  : ����һ���µ�ͷ�ļ����ļ���������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateNewHeaderFile()
{
    hbuf = GetCurrentBuf()
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szName = getreg(MYNAME)
    if(strlen( szName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    ln = 0
    //��õ�ǰû�к�׺���ļ���
    sz = ask("Please input header file name")
    szFileName = GetFileNameNoExt(sz)
    szExt = GetFileNameExt(sz)        
    szPreH = toupper (szFileName)
    szPreH = cat("__",szPreH)
    szExt = toupper(szExt)
    szPreH = cat(szPreH,"_@szExt@__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop

    SetCurrentBuf(hOutbuf)
    InsertCPP(hOutbuf,0)
    TQPInsertFileHeaderEN(hOutbuf, 6)
    HeadIfdefStr(szPreH)
    szContent = GetFileName(GetBufName (hbuf))
    if(language == 0)
    {
        szContent = cat(szContent," ��ͷ�ļ�")

        //�����ļ�ͷ˵��
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")

        //�����ļ�ͷ˵��
        InsertFileHeaderEN(hOutbuf,0,szName,szContent)        
    }

    lnMax = GetBufLineCount(hOutbuf)
    if(lnMax > 9)
    {
        ln = lnMax - 9
    }
    else
    {
        return
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.lnFirst = ln
    sel.ichFirst = 0
    sel.ichLim = 0
    SetBufIns(hOutbuf,ln,0)
    szType = Ask ("Please prototype type : extern or static")
    //�������ű�ȡ�ú�����
    while (isym < isymMax) 
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Class Placeholder")
                {
                        hsyml = SymbolChildren(symbol)
                                cchild = SymListCount(hsyml)
                                ichild = 0
                                szClassName = symbol.Symbol
                InsBufLine(hOutbuf, ln, "}")
                            InsBufLine(hOutbuf, ln, "{")
                            InsBufLine(hOutbuf, ln, "class @szClassName@")
                            ln = ln + 2
                        while (ichild < cchild)
                                {
                                        childsym = SymListItem(hsyml, ichild)
                                        childsym.Symbol = szClassName
                    ln = CreateClassPrototype(hbuf,ln,childsym)
                                        ichild = ichild + 1
                                }
                        SymListFree(hsyml)
                InsBufLine(hOutbuf, ln + 1, "")
                        ln = ln + 2
                }
            else if( symbol.Type == "Function" )
            {
                ln = CreateFuncPrototype(hbuf,ln,szType,symbol)
            }
            else if( symbol.Type == "Method" ) 
            {
                szLine = GetBufline(hbuf,symbol.lnName)
                szClassName = GetLeftWord(szLine,symbol.ichName)
                symbol.Symbol = szClassName
                ln = CreateClassPrototype(hbuf,ln,symbol)            
            }
        }
        isym = isym + 1
    }
    sel.lnLast = ln 
    SetWndSel(hwnd,sel)
}


/*   G E T   W O R D   L E F T   O F   I C H   */
/*-------------------------------------------------------------------------
    Given an index to a character (ich) and a string (sz),
    return a "wordinfo" record variable that describes the 
    text word just to the left of the ich.

    Output:
        wordinfo.szWord = the word string
        wordinfo.ich = the first ich of the word
        wordinfo.ichLim = the limit ich of the word
-------------------------------------------------------------------------*/
macro GetWordLeftOfIch(ich, sz)
{
    wordinfo = "" // create a "wordinfo" structure
    
    chTab = CharFromAscii(9)
    
    // scan backwords over white space, if any
    ich = ich - 1;
    if (ich >= 0)
        while (sz[ich] == " " || sz[ich] == chTab)
        {
            ich = ich - 1;
            if (ich < 0)
                break;
        }
    
    // scan backwords to start of word    
    ichLim = ich + 1;
    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    while (ich >= 0)
    {
        ch = toupper(sz[ich])
        asciiCh = AsciiFromChar(ch)
        
/*        if ((asciiCh < asciiA || asciiCh > asciiZ)
             && !IsNumber(ch)
             &&  (ch != "#") )
            break // stop at first non-identifier character
*/
        //ֻ��ȡ�ַ���'#','{','/','*'��Ϊ����
        if ((asciiCh < asciiA || asciiCh > asciiZ) 
           && !IsNumber(ch)
           && ( ch != "#" && ch != "{" && ch != "/" && ch != "*"))
            break;

        ich = ich - 1;
    }
    
    ich = ich + 1
    wordinfo.szWord = strmid(sz, ich, ichLim)
    wordinfo.ich = ich
    wordinfo.ichLim = ichLim;
    
    return wordinfo
}


/*****************************************************************************
 �� �� ��  : ReplaceBufTab
 ��������  : �滻tabΪ�ո�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceBufTab()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    iTotalLn = GetBufLineCount (hbuf)
    nBlank = Ask("һ��Tab�滻�����ո�")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)
    ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
}

/*****************************************************************************
 �� �� ��  : ReplaceTabInProj
 ��������  : �������������滻tabΪ�ո�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceTabInProj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    nBlank = Ask("һ��Tab�滻�����ո�")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)

    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            iTotalLn = GetBufLineCount (hbuf)
            ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
        }
        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : ReplaceInBuf
 ��������  : �滻tabΪ�ո�,ֻ��2.1����Ч
 �������  : hbuf             
             chOld            
             chNew            
             nBeg             
             nEnd             
             fMatchCase       
             fRegExp          
             fWholeWordsOnly  
             fConfirm         
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceInBuf(hbuf,chOld,chNew,nBeg,nEnd,fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    sel.ichLim = 0
    sel.lnLast = 0
    sel.ichFirst = sel.ichLim
    sel.lnFirst = sel.lnLast
    SetWndSel(hwnd, sel)
    LoadSearchPattern(chOld, 0, 0, 0);
    while(1)
    {
        Search_Forward
        selNew = GetWndSel(hwnd)
        if(sel == selNew)
        {
            break
        }
        SetBufSelText(hbuf, chNew)
           selNew.ichLim = selNew.ichFirst 
        SetWndSel(hwnd, selNew)
        sel = selNew
    }
}


/*****************************************************************************
 �� �� ��  : ConfigureSystem
 ��������  : ����ϵͳ
 �������  : ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ConfigureSystem()
{
    szLanguage = ASK("Please select language: 0 Chinese, 1 English. Recommend to select \"1 English\" language.");

    if(szLanguage == "0")
    {
       SetReg ("LANGUAGE", "0")
    }
    else
    {
       SetReg ("LANGUAGE", "1")
    }
    
    szName = ASK("Please input your name");
    if(szName == "#")
    {
       SetReg ("MYNAME", "")
    }
    else
    {
       SetReg ("MYNAME", szName)
    }
}

/*****************************************************************************
 �� �� ��  : GetLeftBlank
 ��������  : �õ��ַ�����ߵĿո��ַ���
 �������  : szLine  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetLeftBlank(szLine)
{
    nIdx = 0
    nEndIdx = strlen(szLine)
    while( nIdx < nEndIdx )
    {
        if( (szLine[nIdx] !=" ") && (szLine[nIdx] !="\t") )
        {
            break;
        }
        nIdx = nIdx + 1
    }
    return nIdx
}

/*****************************************************************************
 �� �� ��  : ExpandBraceLittle
 ��������  : С������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceLittle()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    if( (sel.lnFirst == sel.lnLast) 
        && (sel.ichFirst == sel.ichLim) )
    {
        SetBufSelText (hbuf, "(  )")
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst + 2)    
    }
    else
    {
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst)    
        SetBufSelText (hbuf, "( ")
        SetBufIns (hbuf, sel.lnLast, sel.ichLim + 2)    
        SetBufSelText (hbuf, " )")
    }
    
}

/*****************************************************************************
 �� �� ��  : ExpandBraceMid
 ��������  : ��������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceMid()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    if( (sel.lnFirst == sel.lnLast) 
        && (sel.ichFirst == sel.ichLim) )
    {
        SetBufSelText (hbuf, "[]")
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst + 1)    
    }
    else
    {
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst)    
        SetBufSelText (hbuf, "[")
        SetBufIns (hbuf, sel.lnLast, sel.ichLim + 1)    
        SetBufSelText (hbuf, "]")
    }
    
}

/*****************************************************************************
 �� �� ��  : ExpandBraceLarge
 ��������  : ��������չ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceLarge()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    nlineCount = 0
    retVal = ""
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    szRight = ""
    szMid = ""
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        //����û�п�ѡ��������ֱ�Ӳ���{}����
        if( nLeft == strlen(szLine) )
        {
            SetBufSelText (hbuf, "{")
        }
        else
        {    
            ln = ln + 1        
            InsBufLine(hbuf, ln, "@szLeft@{")     
            nlineCount = nlineCount + 1

        }
        InsBufLine(hbuf, ln + 1, "@szLeft@    ")
        InsBufLine(hbuf, ln + 2, "@szLeft@}")
        nlineCount = nlineCount + 2
        SetBufIns (hbuf, ln + 1, strlen(szLeft)+4)
    }
    else
    {
        //�����п�ѡ���������ÿ��ǽ���ѡ�����ֿ���
        
        //���ѡ�������Ƿ��������ԣ������̫����ע�͵�������ж�
        RetVal= CheckBlockBrace(hbuf)
        if(RetVal.iCount != 0)
        {
            msg("Invalidated brace number")
            stop
        }
        
        //ȡ��ѡ����ǰ������
        szOld = strmid(szLine,0,sel.ichFirst)
        if(sel.lnFirst != sel.lnLast)
        {
            //���ڶ��е����
            
            //��һ�е�ѡ�в���
            szMid = strmid(szLine,sel.ichFirst,strlen(szLine))
            szMid = TrimString(szMid)
            szLast = GetBufLine(hbuf,sel.lnLast)
            if( sel.ichLim > strlen(szLast) )
            {
                //���ѡ�������ȴ��ڸ��еĳ��ȣ����ȡ���еĳ���
                szLineselichLim = strlen(szLast)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            
            //�õ����һ��ѡ����Ϊ���ַ�
            szRight = strmid(szLast,szLineselichLim,strlen(szLast))
            szRight = TrimString(szRight)
        }
        else
        {
            //����ѡ��ֻ��һ�е����
             if(sel.ichLim >= strlen(szLine))
             {
                 sel.ichLim = strlen(szLine)
             }
             
             //���ѡ����������
             szMid = strmid(szLine,sel.ichFirst,sel.ichLim)
             szMid = TrimString(szMid)            
             if( sel.ichLim > strlen(szLine) )
             {
                 szLineselichLim = strlen(szLine)
             }
             else
             {
                 szLineselichLim = sel.ichLim
             }
             
             //ͬ���õ�ѡ�����������
             szRight = strmid(szLine,szLineselichLim,strlen(szLine))
             szRight = TrimString(szRight)
        }
        nIdx = sel.lnFirst
        while( nIdx < sel.lnLast)
        {
            szCurLine = GetBufLine(hbuf,nIdx+1)
            if( sel.ichLim > strlen(szCurLine) )
            {
                szLineselichLim = strlen(szCurLine)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            szCurLine = cat("    ",szCurLine)
            if(nIdx == sel.lnLast - 1)
            {
                //�������һ��Ӧ����ѡ�����ڵ����ݺ�����λ
                szCurLine = strmid(szCurLine,0,szLineselichLim + 4)
                PutBufLine(hbuf,nIdx+1,szCurLine)                    
            }
            else
            {
                //������������е����ݺ�����λ
                PutBufLine(hbuf,nIdx+1,szCurLine)
            }
            nIdx = nIdx + 1
        }
        if(strlen(szRight) != 0)
        {
            //���������һ��û�б�ѡ�������
            InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@@szRight@")        
        }
        InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@}")        
        nlineCount = nlineCount + 1
        if(nLeft < sel.ichFirst)
        {
            //���ѡ����ǰ�����ݲ��ǿո���Ҫ�����ò�������
            PutBufLine(hbuf,ln,szOld)
            InsBufLine(hbuf, ln+1, "@szLeft@{")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }
        else
        {
            //���ѡ����ǰû������ֱ��ɾ������
            DelBufLine(hbuf,ln)
            InsBufLine(hbuf, ln, "@szLeft@{")
        }
        if(strlen(szMid) > 0)
        {
            //�����һ��ѡ����������
            InsBufLine(hbuf, ln+1, "@szLeft@    @szMid@")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }        
    }
    retVal.szLeft = szLeft
    retVal.nLineCount = nlineCount
    //������������ߵĿհ�
    return retVal
}

/*
macro ScanStatement(szLine,iBeg)
{
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen -1)
    {
        if(szLine[nIdx] == "/" && szLine[nIdx + 1] == "/")
        {
            return 0xffffffff
        }
        if(szLine[nIdx] == "/" && szLine[nIdx + 1] == "*")
        {
           while(nIdx < iLen)
           {
               if(szLine[nIdx] == "*" && szLine[nIdx + 1] == "/")
               {
                   break
               }
               nIdx = nIdx + 1
               
           }
        }
        if( (szLine[nIdx] != " ") && (szLine[nIdx] != "\t" ))
        {
            return nIdx
        }
        nIdx = nIdx + 1
    }
    if( (szLine[iLen -1] == " ") || (szLine[iLen -1] == "\t" ))
    {
        return 0xffffffff
    }
    return nIdx
}
*/
/*
macro MoveCommentLeftBlank(szLine)
{
    nIdx  = 0
    iLen = strlen(szLine)
    while(nIdx < iLen - 1)
    { 
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "*")
        {
            szLine[nIdx] = " "
            szLine[nIdx + 1] = " "
            nIdx = nIdx + 2
            while(nIdx < iLen - 1)
            {
                if(szLine[nIdx] != " " && szLine[nIdx] != "\t")
                {
                    szLine[nIdx - 2] = "/"
                    szLine[nIdx - 1] = "*"
                    return szLine
                }
                nIdx = nIdx + 1
            }
        
        }
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine[nIdx] = " "
            szLine[nIdx + 1] = " "
            nIdx = nIdx + 2
            while(nIdx < iLen - 1)
            {
                if(szLine[nIdx] != " " && szLine[nIdx] != "\t")
                {
                    szLine[nIdx - 2] = "/"
                    szLine[nIdx - 1] = "/"
                    return szLine
                }
                nIdx = nIdx + 1
            }
        
        }
        nIdx = nIdx + 1
    }
    return szLine
}*/

/*****************************************************************************
 �� �� ��  : DelCompoundStatement
 ��������  : ɾ��һ���������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro DelCompoundStatement()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine(hbuf,ln )
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    Msg("@szLine@  will be deleted !")
    fIsEnd = 1
    while(1)
    {
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szTmp = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //���Ҹ������Ŀ�ʼ
        ret = FindInStr(szTmp,"{")
        if(ret != 0xffffffff)
        {
            szNewLine = strmid(szLine,ret+1,strlen(szLine))
            szNew = strmid(szTmp,ret+1,strlen(szTmp))
            szNew = TrimString(szNew)
            if(szNew != "")
            {
                InsBufLine(hbuf,ln + 1,"@szLeft@    @szNewLine@");
            }
            sel.lnFirst = ln
            sel.lnLast = ln
            sel.ichFirst = ret
            sel.ichLim = ret
            //���Ҷ�Ӧ�Ĵ�����
            
            //ʹ���Լ���д�Ĵ����ٶ�̫��
            retTmp = SearchCompoundEnd(hbuf,ln,ret)
            if(retTmp.iCount == 0)
            {
                
                DelBufLine(hbuf,retTmp.ln)
                sel.ichFirst = 0
                sel.ichLim = 0
                DelBufLine(hbuf,ln)
                sel.lnLast = retTmp.ln - 1
                SetWndSel(hwnd,sel)
                Indent_Left
            }
            
            //ʹ��Si�Ĵ�������Է�������V2.1ʱ��ע��Ƕ��ʱ��������
/*            SetWndSel(hwnd,sel)
            Block_Down
            selNew = GetWndSel(hwnd)
            if(selNew != sel)
            {
                
                DelBufLine(hbuf,selNew.lnFirst)
                sel.ichFirst = 0
                sel.ichLim = 0
                DelBufLine(hbuf,ln)
                sel.lnLast = selNew.lnFirst - 1
                SetWndSel(hwnd,sel)
                Indent_Left
            }*/
            break
        }
        szTmp = TrimString(szTmp)
        iLen = strlen(szTmp)
        if(iLen != 0)
        {
            if(szTmp[iLen-1] == ";")
            {
                break
            }
        }
        DelBufLine(hbuf,ln)   
        if( ln == GetBufLineCount(hbuf ))
        {
             break
        }
        szLine = GetBufLine(hbuf,ln)
    }
}

/*****************************************************************************
 �� �� ��  : CheckBlockBrace
 ��������  : ��ⶨ����еĴ�����������
 �������  : hbuf  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckBlockBrace(hbuf)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nCount = 0
    RetVal = ""
    szLine = GetBufLine( hbuf, ln )    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        RetVal.iCount = 0
        RetVal.ich = sel.ichFirst
        return RetVal
    }
    if(sel.lnFirst == sel.lnLast && sel.ichFirst != sel.ichLim)
    {
        RetTmp = SkipCommentFromString(szLine,fIsEnd)
        szTmp = RetTmp.szContent
        RetVal = CheckBrace(szTmp,sel.ichFirst,sel.ichLim,"{","}",0,1)
        return RetVal
    }
    if(sel.lnFirst != sel.lnLast)
    {
            fIsEnd = 1
            while(ln <= sel.lnLast)
            {
                if(ln == sel.lnFirst)
                {
                    RetVal = CheckBrace(szLine,sel.ichFirst,strlen(szLine)-1,"{","}",nCount,fIsEnd)
                }
                else if(ln == sel.lnLast)
                {
                    RetVal = CheckBrace(szLine,0,sel.ichLim,"{","}",nCount,fIsEnd)
                }
                else
                {
                    RetVal = CheckBrace(szLine,0,strlen(szLine)-1,"{","}",nCount,fIsEnd)
                }
                fIsEnd = RetVal.fIsEnd
                ln = ln + 1
                nCount = RetVal.iCount
                szLine = GetBufLine( hbuf, ln )    
            }
    }
    return RetVal
}

/*****************************************************************************
 �� �� ��  : SearchCompoundEnd
 ��������  : ����һ���������Ľ�����
 �������  : hbuf    
             ln      ��ѯ��ʼ��
             ichBeg  ��ѯ��ʼ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchCompoundEnd(hbuf,ln,ichBeg)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nCount = 0
    SearchVal = ""
//    szLine = GetBufLine( hbuf, ln )
    lnMax = GetBufLineCount(hbuf)
    fIsEnd = 1
    while(ln < lnMax)
    {
        szLine = GetBufLine( hbuf, ln )
        RetVal = CheckBrace(szLine,ichBeg,strlen(szLine)-1,"{","}",nCount,fIsEnd)
        fIsEnd = RetVal.fIsEnd
        ichBeg = 0
        nCount = RetVal.iCount
        
        //���nCount=0��˵��"{""}"����Ե�
        if(nCount == 0)
        {
            break
        }
        ln = ln + 1
//        szLine = GetBufLine( hbuf, ln )    
    }
    SearchVal.iCount = RetVal.iCount
    SearchVal.ich = RetVal.ich
    SearchVal.ln = ln
    return SearchVal
}

/*****************************************************************************
 �� �� ��  : CheckBrace
 ��������  : ������ŵ�������
 �������  : szLine       �����ַ���
             ichBeg       �����ʼ
             ichEnd       ������
             chBeg        ��ʼ�ַ�(������)
             chEnd        �����ַ�(������)
             nCheckCount  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckBrace(szLine,ichBeg,ichEnd,chBeg,chEnd,nCheckCount,isCommentEnd)
{
    retVal = ""
    retVal.ich = 0
    nIdx = ichBeg
    nLen = strlen(szLine)
    if(ichEnd >= nLen)
    {
        ichEnd = nLen - 1
    }
    fIsEnd = 1
    while(nIdx <= ichEnd)
    {
        //�����/*ע�����������ö�
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx <= ichEnd )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    nIdx = nIdx + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                nIdx = nIdx + 1 
            }
            if(nIdx > ichEnd)
            {
                break
            }
        }
        //�����//ע����ֹͣ����
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            break
        }
        if(szLine[nIdx] == chBeg)
        {
            nCheckCount = nCheckCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            nCheckCount = nCheckCount - 1
            if(nCheckCount == 0)
            {
                retVal.ich = nIdx
            }
        }
        nIdx = nIdx + 1
    }
    retVal.iCount = nCheckCount
    retVal.fIsEnd = fIsEnd
    return retVal
}

/*****************************************************************************
 �� �� ��  : InsertElse
 ��������  : ����else���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertElse()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@else")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    ")
        SetBufIns (hbuf, ln+2, strlen(szLeft)+4)
        return
    }
    SetBufIns (hbuf, ln, strlen(szLeft)+7)
}

/*****************************************************************************
 �� �� ��  : InsertCase
 ��������  : ����case���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCase()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    InsBufLine(hbuf, ln, "@szLeft@" # "case # :")
    InsBufLine(hbuf, ln + 1, "@szLeft@" # "    " # "#")
    InsBufLine(hbuf, ln + 2, "@szLeft@" # "    " # "break;")
    SearchForward()    
}

/*****************************************************************************
 �� �� ��  : InsertSwitch
 ��������  : ����swich���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertSwitch()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine( hbuf, ln )    
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    InsBufLine(hbuf, ln, "@szLeft@switch ( # )")    
    InsBufLine(hbuf, ln + 1, "@szLeft@" # "{")
    nSwitch = ask("������case�ĸ���")
    InsertMultiCaseProc(hbuf,szLeft,nSwitch)
    SearchForward()    
}

/*****************************************************************************
 �� �� ��  : InsertMultiCaseProc
 ��������  : ������case
 �������  : hbuf     
             szLeft   
             nSwitch  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertMultiCaseProc(hbuf,szLeft,nSwitch)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst

    nIdx = 0
    if(nSwitch == 0)
    {
        hNewBuf = newbuf("clip")
        if(hNewBuf == hNil)
            return       
        SetCurrentBuf(hNewBuf)
        PasteBufLine (hNewBuf, 0)
        nLeftMax = 0
        lnMax = GetBufLineCount(hNewBuf )
        i = 0
        fIsEnd = 1
        while ( i < lnMax) 
        {
            szLine = GetBufLine(hNewBuf , i)
            //��ȥ��������ע�͵�����
            RetVal = SkipCommentFromString(szLine,fIsEnd)
            szLine = RetVal.szContent
            fIsEnd = RetVal.fIsEnd
//            nLeft = GetLeftBlank(szLine)
            //�Ӽ�������ȡ��caseֵ
            szLine = GetSwitchVar(szLine)
            if(strlen(szLine) != 0 )
            {
                ln = ln + 4
                InsBufLine(hbuf, ln - 1, "@szLeft@    " # "case @szLine@:")
                InsBufLine(hbuf, ln    , "@szLeft@    " # "    " # "#")
                InsBufLine(hbuf, ln + 1, "@szLeft@    " # "    " # "break;")
                InsBufLine(hbuf, ln + 2, "")
              }
              i = i + 1
        }
        closebuf(hNewBuf)
       }
       else
       {
        while(nIdx < nSwitch)
        {
            ln = ln + 4
            InsBufLine(hbuf, ln - 1, "@szLeft@    " # "case # :")
            InsBufLine(hbuf, ln    , "@szLeft@    " # "    " # ";")
            InsBufLine(hbuf, ln + 1, "@szLeft@    " # "    " # "break;")
            InsBufLine(hbuf, ln + 2, "")
            nIdx = nIdx + 1
        }
      }
    InsBufLine(hbuf, ln + 3, "@szLeft@    " # "default:")
    InsBufLine(hbuf, ln + 4, "@szLeft@    " # "    " # ";")
    InsBufLine(hbuf, ln + 5, "@szLeft@    " # "    " # "break;")
    InsBufLine(hbuf, ln + 6, "@szLeft@" # "}")
    SetWndSel(hwnd, sel)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : GetSwitchVar
 ��������  : ��ö�١��궨��ȡ��caseֵ
 �������  : szLine  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetSwitchVar(szLine)
{
    if( (szLine == "{") || (szLine == "}") )
    {
        return ""
    }
    ret = FindInStr(szLine,"#define" )
    if(ret != 0xffffffff)
    {
        szLine = strmid(szLine,ret + 8,strlen(szLine))
    }
    szLine = TrimLeft(szLine)
    nIdx = 0
    nLen = strlen(szLine)
    while( nIdx < nLen)
    {
        if((szLine[nIdx] == " ") || (szLine[nIdx] == ",") || (szLine[nIdx] == "="))
        {
            szLine = strmid(szLine,0,nIdx)
            return szLine
        }
        nIdx = nIdx + 1
    }
    return szLine
}

/*
macro SkipControlCharFromString(szLine)
{
   nLen = strlen(szLine)
   nIdx = 0
   newStr = ""
   while(nIdx < nLen - 1)
   {
       if(szLine[nIdx] == "\t")
       {
           newStr = cat(newStr,"    ")
       }
       else if(szLine[nIdx] < " ")
       {
           newStr = cat(newStr," ")           
       }
       else
       {
           newStr = cat(newStr," ")                      
       }
   }
}
*/
/*****************************************************************************
 �� �� ��  : SkipCommentFromString
 ��������  : ȥ��ע�͵����ݣ���ע��������Ϊ�ո�
 �������  : szLine        �����е�����
             isCommentEnd  �Ƿ�ǰ�еĿ�ʼ�Ѿ���ע�ͽ�����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SkipCommentFromString(szLine,isCommentEnd)
{
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)
    nIdx = 0
    while(nIdx < nLen )
    {
        //�����ǰ�п�ʼ���Ǳ�ע�ͣ���������ע�Ϳ�ʼ�ı��ǣ�ע�����ݸ�Ϊ�ո�?
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx < nLen )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    szLine[nIdx+1] = " "
                    szLine[nIdx] = " " 
                    nIdx = nIdx + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                szLine[nIdx] = " "
                
                //����ǵ����ڶ��������һ��Ҳ�϶�����ע����
//                if(nIdx == nLen -2 )
//                "{"
//                    szLine[nIdx + 1] = " "
//                "}"
                nIdx = nIdx + 1 
            }    
            
            //����Ѿ�������β��ֹ����
            if(nIdx == nLen)
            {
                break
            }
        }
        
        //�����������//��ע�͵�˵�����涼Ϊע��
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine = strmid(szLine,0,nIdx)
            break
        }
        nIdx = nIdx + 1                
    }
    RetVal.szContent = szLine;
    RetVal.fIsEnd = fIsEnd
    return RetVal
}

/*****************************************************************************
 �� �� ��  : InsertDo
 ��������  : ����Do���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertDo()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+1, "@szLeft@    #")
    }
    PutBufLine(hbuf, sel.lnLast + val.nLineCount, "@szLeft@}while ( # );")    
//       SetBufIns (hbuf, sel.lnLast + val.nLineCount, strlen(szLeft)+8)
    InsBufLine(hbuf, ln, "@szLeft@do")    
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertWhile
 ��������  : ����While���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertWhile()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@while ( # )")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
    SetBufIns (hbuf, ln, strlen(szLeft)+7)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertFor
 ��������  : ����for���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFor()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln,"@szLeft@for ( # ; # ; # )")
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
    sel.lnFirst = ln
    sel.lnLast = ln 
    sel.ichFirst = 0
    sel.ichLim = 0
    SetWndSel(hwnd, sel)
    SearchForward()
    szVar = ask("������ѭ������")
    PutBufLine(hbuf,ln, "@szLeft@for ( @szVar@ = # ; @szVar@ # ; @szVar@++ )")
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertIf
 ��������  : ����If���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertIf()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@if ( # )")    
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
//       SetBufIns (hbuf, ln, strlen(szLeft)+4)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : MergeString
 ��������  : ���������е����ϲ���һ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro MergeString()
{
    hbuf = newbuf("clip")
    if(hbuf == hNil)
        return       
    SetCurrentBuf(hbuf)
    PasteBufLine (hbuf, 0)
    
    //�����������û�����ݣ��򷵻�
    lnMax = GetBufLineCount(hbuf )
    if( lnMax == 0 )
    {
        closebuf(hbuf)
        return ""
    }
    lnLast =  0
    if(lnMax > 1)
    {
        lnLast = lnMax - 1
         i = lnMax - 1
    }
    while ( i > 0) 
    {
        szLine = GetBufLine(hbuf , i-1)
        szLine = TrimLeft(szLine)
        nLen = strlen(szLine)
        if(szLine[nLen - 1] == "-")
        {
              szLine = strmid(szLine,0,nLen - 1)
        }
        nLen = strlen(szLine)
        if( (szLine[nLen - 1] != " ") && (AsciiFromChar (szLine[nLen - 1])  <= 160))
        {
              szLine = cat(szLine," ") 
        }
        SetBufIns (hbuf, lnLast, 0)
        SetBufSelText(hbuf,szLine)
        i = i - 1
    }
    szLine = GetBufLine(hbuf,lnLast)
    closebuf(hbuf)
    return szLine
}

/*****************************************************************************
 �� �� ��  : ClearPrombleNo
 ��������  : ������ⵥ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ClearPrombleNo()
{
   SetReg ("PNO", "")
}

/*****************************************************************************
 �� �� ��  : AddPromblemNo
 ��������  : �������ⵥ��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AddPromblemNo()
{
    szQuestion = ASK("Please Input problem number ");
    if(szQuestion == "#")
    {
       szQuestion = ""
       SetReg ("PNO", "")
    }
    else
    {
       SetReg ("PNO", szQuestion)
    }
    return szQuestion
}

/*
this macro convet selected  C++ coment block to C comment block 
for example:
  line "  // aaaaa "
  convert to  /* aaaaa */
*/
/*macro ComentCPPtoC()
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnLast = GetWndSelLnLast( hwnd )

    lnCurrent = lnFirst
    fIsEnd = 1
    while ( lnCurrent <= lnLast )
    {
        fIsEnd = CmtCvtLine( lnCurrent,fIsEnd )
        lnCurrent = lnCurrent + 1;
    }
}*/

/*****************************************************************************
 �� �� ��  : ComentCPPtoC
 ��������  : ת��C++ע��ΪCע��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��7��02��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���,֧�ֿ�ע��

*****************************************************************************/
macro ComentCPPtoC()
{
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    lnFirst = GetWndSelLnFirst( hwnd )
    lnCurrent = lnFirst
    lnLast = GetWndSelLnLast( hwnd )
    ch_comment = CharFromAscii(47)   
    isCommentEnd = 1
    isCommentContinue = 0

        szMyName = getreg(MYNAME)
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day    
    while ( lnCurrent <= lnLast )
    {

        ich = 0
        szLine = GetBufLine(hbuf,lnCurrent)
        ilen = strlen(szLine)
        while ( ich < ilen )
        {
            if( (szLine[ich] != " ") && (szLine[ich] != "\t") )
            {
                break
            }
            ich = ich + 1
        }
        /*����ǿ��У���������*/
        if(ich == ilen)
        {         
            lnCurrent = lnCurrent + 1
            szOldLine = szLine
            continue 
        }
        
        /*�������ֻ��һ���ַ�*/
        if(ich > ilen - 2)
        {
            if( isCommentContinue == 1 )
            {
                szOldLine = cat(szOldLine,", @szMyName@, @sz@/@sz1@/@sz3@ */")
                PutBufLine(hbuf,lnCurrent-1,szOldLine)
                isCommentContinue = 0
            }
            lnCurrent = lnCurrent + 1
            szOldLine = szLine
            continue 
        }       
        if( isCommentEnd == 1 )
        {
            /*���������ע������*/
            if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
            {
                /* ȥ���м�Ƕ�׵�ע�� */
                nIdx = ich + 2
                while ( nIdx < ilen -1 )
                {
                    if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                         ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                    {
                        szLine[nIdx] = " "
                        szLine[nIdx+1] = " "
                    }
                    nIdx = nIdx + 1
                }
                
                if( isCommentContinue == 1 )
                {
                    /* �����������ע��*/
                    szLine[ich] = " "
                    szLine[ich+1] = " "
                }
                else
                {
                    /*�������������ע��������ע�͵Ŀ�ʼ*/
                    szLine[ich] = "/"
                    szLine[ich+1] = "*"
                }
                if ( lnCurrent == lnLast )
                {
                    /*��������һ��������β���ӽ���ע�ͷ�*/
                    szLine = cat(szLine,", @szMyName@, @sz@/@sz1@/@sz3@ */")
                    isCommentContinue = 0
                }
                /*���¸���*/
                PutBufLine(hbuf,lnCurrent,szLine)
                isCommentContinue = 1
                szOldLine = szLine
                lnCurrent = lnCurrent + 1
                continue 
            }
            else
            {   
                /*������е���ʼ����//ע��*/
                if( isCommentContinue == 1 )
                {
                    szOldLine = cat(szOldLine,", @szMyName@, @sz@/@sz1@/@sz3@ */")
                    PutBufLine(hbuf,lnCurrent-1,szOldLine)
                    isCommentContinue = 0
                }
            }
        }
        while ( ich < ilen - 1 )
        {
            //�����/*ע�����������ö�
            if( (isCommentEnd == 0) || (szLine[ich] == "/" && szLine[ich+1] == "*"))
            {
                isCommentEnd = 0
                while(ich < ilen - 1 )
                {
                    if(szLine[ich] == "*" && szLine[ich+1] == "/")
                    {
                        ich = ich + 1 
                        isCommentEnd = 1
                        break
                    }
                    ich = ich + 1 
                }
                if(ich >= ilen - 1)
                {
                    break
                }
            }
            
            if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
            {
                /* �����//ע��*/
                isCommentContinue = 1
                nIdx = ich
                //ȥ���ڼ��/* �� */ע�ͷ��������ע��Ƕ�״���
                while ( nIdx < ilen -1 )
                {
                    if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                         ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                    {
                        szLine[nIdx] = " "
                        szLine[nIdx+1] = " "
                    }
                    nIdx = nIdx + 1
                }
                szLine[ich+1] = "*"
//                szLine = cat(szLine,"  */")
                PutBufLine(hbuf,lnCurrent,szLine)
                break
            }
            ich = ich + 1
        }
        szOldLine = szLine
        lnCurrent = lnCurrent +1
        if((isCommentContinue==1)&&(lnCurrent > lnLast))
        {
           szLine = cat(szLine,", @szMyName@, @sz@/@sz1@/@sz3@ */")
           PutBufLine(hbuf,lnCurrent-1,szLine)
           isCommentContinue = 0            
        }
        
    }
}


/*****************************************************************************
 �� �� ��  : CmtCvtLine
 ��������  : ��//ת����/*ע��
 �������  : lnCurrent  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 
    ��    ��   : 
    �޸�����   : 

  2.��    ��   : 2002��7��02��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸���ע��Ƕ��������������?

*****************************************************************************/
macro CmtCvtLine(lnCurrent, isCommentEnd)
{
    hbuf = GetCurrentBuf()
    szLine = GetBufLine(hbuf,lnCurrent)
    ch_comment = CharFromAscii(47)   
    ich = 0
    ilen = strlen(szLine)
    
    fIsEnd = 1
    iIsComment = 0;
    
    while ( ich < ilen - 1 )
    {
        //�����/*ע�����������ö�
        if( (isCommentEnd == 0) || (szLine[ich] == "/" && szLine[ich+1] == "*"))
        {
            fIsEnd = 0
            while(ich < ilen - 1 )
            {
                if(szLine[ich] == "*" && szLine[ich+1] == "/")
                {
                    ich = ich + 1 
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                ich = ich + 1 
            }
            if(ich >= ilen - 1)
            {
                break
            }
        }
        if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
        {
            nIdx = ich
            while ( nIdx < ilen -1 )
            {
                if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                     ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                {
                    szLine[nIdx] = " "
                    szLine[nIdx+1] = " "
                }
                nIdx = nIdx + 1
            }
            szLine[ich+1] = "*"
            szLine = cat(szLine,"  */")
            DelBufLine(hbuf,lnCurrent)
            InsBufLine(hbuf,lnCurrent,szLine)
            return fIsEnd
        }
        ich = ich + 1
    }
    return fIsEnd
}

/*****************************************************************************
 �� �� ��  : GetFileNameExt
 ��������  : �õ��ļ���չ��
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileNameExt(sz)
{
    i = 1
    j = 0
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
         szExt = strmid(sz,j + 1,iLen)
         return szExt
      }
      i = i + 1
    }
    return ""
}

/*****************************************************************************
 �� �� ��  : GetFileNameNoExt
 ��������  : �õ�������û����չ��
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileNameNoExt(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    j = iLen 
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
      }
      if( sz[iLen-i] == "\\" )
      {
         szName = strmid(sz,iLen-i+1,j)
         return szName
      }
      i = i + 1
    }
    szName = strmid(sz,0,j)
    return szName
}

/*****************************************************************************
 �� �� ��  : GetFileName
 ��������  : �õ�����չ�����ļ���
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileName(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == "\\")
      {
        szName = strmid(sz,iLen-i+1,iLen)
        break
      }
      i = i + 1
    }
    return szName
}

/*****************************************************************************
 �� �� ��  : InsIfdef
 ��������  : ����#ifdef���
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsIfdef()
{
    sz = Ask("Enter #ifdef condition:")
    if (sz != "")
        IfdefStr(sz);
}

/*****************************************************************************
 �� �� ��  : InsIfndef
 ��������  : ��ifndef���Բ������ڵ��ú�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsIfndef()
{
    sz = Ask("Enter #ifndef condition:")
    if (sz != "")
        IfndefStr(sz);
}

/*****************************************************************************
 �� �� ��  : InsertCPP
 ��������  : ��buf�в���C���Ͷ���
 �������  : hbuf  
             ln    
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCPP(hbuf,ln)
{
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "#endif /* __cplusplus */")
    InsBufLine(hbuf, ln, "#endif")
    InsBufLine(hbuf, ln, "extern \"C\"{")
    InsBufLine(hbuf, ln, "#if __cplusplus")
    InsBufLine(hbuf, ln, "#ifdef __cplusplus")
    InsBufLine(hbuf, ln, "")
    
    iTotalLn = GetBufLineCount (hbuf)            
    InsBufLine(hbuf, iTotalLn, "")
    InsBufLine(hbuf, iTotalLn, "#endif /* __cplusplus */")
    InsBufLine(hbuf, iTotalLn, "#endif")
    InsBufLine(hbuf, iTotalLn, "}")
    InsBufLine(hbuf, iTotalLn, "#if __cplusplus")
    InsBufLine(hbuf, iTotalLn, "#ifdef __cplusplus")
    InsBufLine(hbuf, iTotalLn, "")
}

/*****************************************************************************
 �� �� ��  : ReviseCommentProc
 ��������  : ���ⵥ�޸������
 �������  : hbuf      
             ln        
             szCmd     
             szMyName  
             szLine1   
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReviseCommentProc(hbuf,ln,szCmd,szMyName,szLine1)
{
    if (szCmd == "ap")
    {   
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* �� �� ��: @szQuestion@     �޸���:@szMyName@,   ʱ��:@sz@/@sz1@/@sz3@ ");
        szContent = Ask("�޸�ԭ��")
        szLeft = cat(szLine1,"   �޸�ԭ��: ");
        if(strlen(szLeft) > 70)
        {
            Msg("The right margine is small, Please use a new line")
            stop 
        }
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day
        
        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ */");        
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        
        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln + 0)
        InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified for ���ⵥ��:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
}

/*****************************************************************************
 �� �� ��  : InsertReviseAdd
 ��������  : ���������޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseAdd()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Added for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ */");        
    }

    if(sel.lnLast < lnMax - 1)
    {
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Added for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
    }
    else
    {
        if(strlen(szQuestion)>0)
        {
            AppendBufLine(hbuf, "@szLeft@/* END:   Added for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        else
        {
            AppendBufLine(hbuf, "@szLeft@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");                                
        }
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : InsertReviseDel
 ��������  : ����ɾ���޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseDel()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Deleted for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");        
    }

    if(sel.lnLast < lnMax - 1)
    {
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Deleted for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");            
        }
        else
        {
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");            
        }

    }
    else
    {
        if(strlen(szQuestion)>0)
        {
            AppendBufLine(hbuf, "@szLeft@/* END:   Deleted for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");                        
        }
        else
        {
            AppendBufLine(hbuf, "@szLeft@/* END:   Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");                        
        }

    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : InsertReviseMod
 ��������  : �����޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseMod()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )    
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Modified for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");        
    }

	if(sel.lnLast < lnMax - 1)
	 {
		 if(strlen(szQuestion)>0)
		 {
			 InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Modified for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");			  
		 }
		 else
		 {
			 InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");			  
		 }

	 }
	 else
	 {
		 if(strlen(szQuestion)>0)
		 {
			 AppendBufLine(hbuf, "@szLeft@/* END:   Modified for PN:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");						 
		 }
		 else
		 {
			 AppendBufLine(hbuf, "@szLeft@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");						 
		 }

	 }

//    if(sel.lnLast < lnMax - 1)
//    "{"
//       InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");            
//    "}"
//    else
//    "{"
//        AppendBufLine(hbuf, "@szLeft@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");                        
//    "}"
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

// Wrap ifdef <sz> .. endif around the current selection
macro IfdefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#ifdef @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : IfndefStr
 ��������  : ���룣ifndef����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro IfndefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#ifndef @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}


/*****************************************************************************
 �� �� ��  : InsertPredefIf
 ��������  : ���룣if���Ե���ڵ��ú�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertPredefIf()
{
    sz = Ask("Enter #if condition:")
    PredefIfStr(sz)
}

/*****************************************************************************
 �� �� ��  : PredefIfStr
 ��������  : ��ѡ����ǰ����룣if����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro PredefIfStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )    
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
     
    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* #if @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* #if @sz@ */")
    }
    else 
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* #if @sz@ */")
    }    
    InsBufLine(hbuf, lnFirst, "@szLeft@#if  @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}


/*****************************************************************************
 �� �� ��  : HeadIfdefStr
 ��������  : ��ѡ����ǰ�����#ifdef����
 �������  : sz  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro HeadIfdefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    hbuf = GetCurrentBuf()
    InsBufLine(hbuf, lnFirst, "")
    InsBufLine(hbuf, lnFirst, "#define @sz@")
    InsBufLine(hbuf, lnFirst, "#ifndef @sz@")
    iTotalLn = GetBufLineCount (hbuf)                
    InsBufLine(hbuf, iTotalLn, "#endif /* @sz@ */")
    InsBufLine(hbuf, iTotalLn, "")
}

/*****************************************************************************
 �� �� ��  : GetSysTime
 ��������  : ȡ��ϵͳʱ�䣬ֻ��V2.1ʱ����
 �������  : a  
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��24��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetSysTime(a)
{
    //��sidateȡ��ʱ��
    RunCmd ("sidate")
    SysTime=""
    SysTime.Year=getreg(Year)
    if(strlen(SysTime.Year)==0)
    {
        setreg(Year,"2002")
        setreg(Month,"05")
        setreg(Day,"02")
        SysTime.Year="2002"
        SysTime.month="05"
        SysTime.day="20"
        SysTime.Date="2002��05��20��"
    }
    else
    {
        SysTime.Month=getreg(Month)
        SysTime.Day=getreg(Day)
        SysTime.Date=getreg(Date)
   /*         SysTime.Date=cat(SysTime.Year,"��")
        SysTime.Date=cat(SysTime.Date,SysTime.Month)
        SysTime.Date=cat(SysTime.Date,"��")
        SysTime.Date=cat(SysTime.Date,SysTime.Day)
        SysTime.Date=cat(SysTime.Date,"��")*/
    }
    return SysTime
}

/*****************************************************************************
 �� �� ��  : HeaderFileCreate
 ��������  : ����ͷ�ļ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro HeaderFileCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }

   CreateFunctionDef(hbuf,szMyName,language)
}

/*****************************************************************************
 �� �� ��  : FunctionHeaderCreate
 ��������  : ���ɺ���ͷ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FunctionHeaderCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nVer = GetVersion()
    lnMax = GetBufLineCount(hbuf)
    if(ln != lnMax)
    {
        szNextLine = GetBufLine(hbuf,ln)
        if( (FindInStr(szNextLine,"(") != 0xffffffff) || (nVer != 2 ))
        {
            symbol = GetCurSymbol()
            if(strlen(symbol) != 0)
            {  
                if(language == 0)
                {
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0)
                }
                else
                {                
                    FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)
                }
                return
            }
        }
    }
    if(language == 0 )
    {
        szFuncName = Ask("�����뺯������:")
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else
    {
        szFuncName = Ask("Please input function name")
           FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    
    }
}

/*****************************************************************************
 �� �� ��  : GetVersion
 ��������  : �õ�Si�İ汾��
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetVersion()
{
   Record = GetProgramInfo ()
   return Record.versionMajor
}

/*****************************************************************************
 �� �� ��  : GetProgramInfo
 ��������  : ��ó�����Ϣ��V2.1����
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetProgramInfo ()
{   
    Record = ""
    Record.versionMajor     = 2
    Record.versionMinor    = 1
    return Record
}

/*****************************************************************************
 �� �� ��  : FileHeaderCreate
 ��������  : �����ļ�ͷ
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FileHeaderCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    ln = 0
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
       SetBufIns (hbuf, 0, 0)
    if(language == 0)
    {
        InsertFileHeaderCN( hbuf,ln, szMyName,"" )
    }
    else
    {
        ln = InsertFileHeaderEN( hbuf,ln, szMyName,"" )
        TQPInsertFileHeaderEN( hbuf, ln)
    }
}

/*****************************************************************************
 �� �� ��  : ShowHelp
 ��������  : �г���Quicker��֧�ֵĿ������
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2006��11��22��
    ��    ��   : ͯ��ƽ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ShowHelp(hbuf, ln)
{
    var i
    
    i = 0
    
    DelBufLine(hbuf, ln)
    
    InsBufLine(hbuf, ln + i, "/*==============================================*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *====== List Quicker supports commands ========*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *----------------------------------------------*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  /*             auto fill comment according to standard C format")       
    i = i+1
    InsBufLine(hbuf, ln + i, " *  {              auto add right curly bace")       
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  if             auto insert if condition statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  ef             auto insert else if condition statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  ife            auto insert if/else condition statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  ifs            auto insert if/else if/else condition statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  else/ei        auto insert else statements template")       
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  switch/sw      auto insert switch/case statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  case/ca        auto insert case/break statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  for            auto insert for loop statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  fo             auto insert for loop statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  while/wh       auto insert while loop statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  do             auto insert do/while loop statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  func/fu        auto insert function header description template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  file/fi        auto insert file header description template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  hi             auto insert new history record in history comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  struct/st      auto insert typedef struct statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  enum/en        auto insert typedef enum statements template")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  ap             auto insert problem number and description comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *  pn             set problem number used by below command")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *  ab             auto insert add begin description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  ae             auto insert add end description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  db             auto insert delete begin description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  de             auto insert delete end description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  mb             auto insert modify begin description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  me             auto insert modify end description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  abg            auto insert add begin and end description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  mbg            auto insert modify begin and end description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  dbg            auto insert delete begin and end description for assigned PN comment")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  hd             auto create .h header file for current .c file")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  hdn            auto create new .h header file for current .c file")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  key            list Source Insight default shortcut keys")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  cmd/help       list Quicker supports commands just this showed")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  #if            auto insert #if statements template")       
    i = i+1
    InsBufLine(hbuf, ln + i, " *  #ifd/#ifdef    auto insert #ifdef statements template")       
    i = i+1
    InsBufLine(hbuf, ln + i, " *  #ifn/#ifndef   auto insert #inndef statements template")       
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  cpp            auto insert extern C statements template")       
    i = i+1
    InsBufLine(hbuf, ln + i, " *  tab            auto expand tab to assigned spaces")
    i = i+1

    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *----------------------------------------------*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *======= End Quicker supports commands ========*")    
    i = i+1
    InsBufLine(hbuf, ln + i, " *==============================================*/")
    
}

/*****************************************************************************
 �� �� ��  : ShowShortKey
 ��������  : �г�Source Insight��Ĭ�Ͽ�ݼ�
 �������  : ��
 �� �� ֵ  : 
 ���ú���  : 
 ��������  : 
 
 �޸���ʷ      :
  1.��    ��   : 2006��11��22��
    ��    ��   : ͯ��ƽ
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ShowShortKey(hbuf, ln)
{
    var i
    
    i = 0
    
    DelBufLine(hbuf, ln)
    
    InsBufLine(hbuf, ln + i, "/*==============================================*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *== List Source Insight default shortcut keys =*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *----------------------------------------------*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Macro: AutoExpand                         :  Ctrl+Enter, Shift+Enter")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Macro: ComentCPPtoC                       :  Alt+C     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Macro: Review_Add_Comment                 :  F11       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Custom Cmd: SI-PC-LINT                    :  Alt+Z     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Search: Incremental Search...             :  F12       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Search: Replace Files...                  :  Ctrl+Shift+H      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Search: Search Backward                   :  F3        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Search: Search Backward for Selection     :  Shift+F3  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Search: Search Files...                   :  Ctrl+Shift+F      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Search: Search Forward                    :  F4        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Search: Search Forward for Selection      :  Shift+F4  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Search: Search...                         :  Ctrl+F    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Symbol: Browse Local File Symbols...      :  F8        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Symbol: Browse Project Symbols...         :  F7, Alt+G ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Symbol: Jump To Base Type                 :  Alt+0     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Symbol: Jump To Definition                :  Ctrl+=, Ctrl+L Click (select), Ctrl+Double L Click        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Symbol: Lookup References...              :  Ctrl+/    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Symbol: Symbol Info...                    :  Alt+/, Ctrl+R Click (select)      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *  View: Highlight Word                      :  Shift+F8  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  View: Symbol Window                       :  Alt+F8    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Windows: Close Window                     :  Alt+F6, Ctrl+F4   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Windows: Last Window                      :  Ctrl+Tab, Ctrl+Shift+Tab  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Windows: New Window                       :  Alt+F5    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Windows: Select Next Window               :  F2, Shift+F2, Ctrl+F6     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Windows: Select Previous Window           :  Shift+F1  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Windows: Tile Two Windows                 :  F6        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Windows: Zoom Window                      :  Alt+F10, Ctrl+F10 ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Navigation: Activate Symbol Window        :  Alt+L     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Beginning Of Selection        :  Ctrl+Alt+[        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Block Down                    :  Ctrl+Shift+]      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Block Up                      :  Ctrl+Shift+[      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Bookmark...                   :  Ctrl+M    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Bottom Of File                :  Ctrl+End, Ctrl+(KeyPad) End       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: End Of Selection              :  Ctrl+Alt+]        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Function Down                 :  (KeyPad) +        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Function Up                   :  (KeyPad) -        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Navigation: Go Back                       :  Alt+,, Thumb 1 Click      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Go Back Toggle                :  Alt+M     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Go Forward                    :  Alt+., Thumb 2 Click      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Go To Line...                 :  F5, Ctrl+G        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Go To Next Change             :  Alt+(KeyPad) +    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Go To Next Link               :  Shift+F9, Ctrl+Shift+L    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Go To Previous Change         :  Alt+(KeyPad) -    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Navigation: Jump To Link                  :  Ctrl+L    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Jump To Match                 :  Alt+]     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Make Column Selection         :  Alt+L Click       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Paren Left                    :  Ctrl+9    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Paren Right                   :  Ctrl+0    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Edit: Back Tab                            :  Shift+Tab ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Complete Symbol                     :  Ctrl+E    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Copy                                :  Ctrl+C, L+R Click ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Copy Line                           :  Ctrl+K    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Copy Line Right                     :  Ctrl+Shift+K      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Copy To Clip...                     :  Ctrl+Del  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Cut                                 :  Ctrl+X, Shift+Del ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Cut Line                            :  Ctrl+U    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Cut Line Right                      :  Ctrl+;    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Cut To Clip...                      :  Ctrl+Shift+X      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Cut Word                            :  Ctrl+,    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Edit: Indent Left                         :  F9        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Indent Right                        :  F10       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Insert Line                         :  Ctrl+I    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Insert Line Before Next             :  Ctrl+Space        ")
//    i = i+1
//    InsBufLine(hbuf, ln + i, " *  Edit: Insert New Line                     :  Ctrl+Enter        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Join Lines                          :  Ctrl+J    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Paste                               :  Ctrl+V, Shift+Ins ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Paste From Clip...                  :  Ctrl+Ins  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Paste Line                          :  Ctrl+P    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Edit: Play Recording                      :  Ctrl+F3   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Redo                                :  Ctrl+Y    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Renumber...                         :  Ctrl+R    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Repeat Typing                       :  Ctrl+\    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Replace...                          :  Ctrl+H    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Simple Tab                          :  Ctrl+Alt+Tab      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Smart Rename...                     :  Ctrl+'    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Start Recording                     :  Ctrl+F1   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Stop Recording                      :  Ctrl+F2   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Edit: Undo                                :  Ctrl+Z, Alt+BackSpace     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *  File: Close                               :  Ctrl+W    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: Close All                           :  Ctrl+Shift+W      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: New                                 :  Ctrl+N    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: Next File...                        :  Ctrl+Shift+N      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: Open...                             :  Ctrl+O    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: Reload File                         :  Ctrl+Shift+O      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: Save                                :  Ctrl+S    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: Save All                            :  Ctrl+A    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: Save As...                          :  Ctrl+Shift+S      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  File: Show File Status                    :  Shift+F10 ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Help: Help...                             :  F1        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Help: SDK Help...                         :  Alt+F1    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *  Application: Draft View                   :  Alt+F12   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Application: Exit                         :  Alt+F4    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Application: Redraw Screen                :  Ctrl+Alt+Space    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Navigation: Scroll Half Page Down         :  Ctrl+PgDn, Ctrl+(KeyPad) PgDn, (KeyPad) * ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Scroll Half Page Up           :  Ctrl+PgUp, Ctrl+(KeyPad) PgUp, (KeyPad) / ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Scroll Left                   :  Alt+Left  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Scroll Line Down              :  Alt+Down  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Scroll Line Up                :  Alt+Up    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Scroll Right                  :  Alt+Right ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Block                  :  Ctrl+-    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Char Left              :  Shift+Left        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Char Right             :  Shift+Right       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Line                   :  Shift+F6  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Line Down              :  Shift+Down        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Line Up                :  Shift+Up  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Match                  :  Alt+=     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Page Down              :  Shift+PgDn, Shift+(KeyPad) PgDn   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Page Up                :  Shift+PgUp, Shift+(KeyPad) PgUp   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1

    InsBufLine(hbuf, ln + i, " *  Navigation: Select Sentence               :  Shift+F7, Ctrl+.  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select To                     :  Shift+L Click     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select To End Of File         :  Ctrl+Shift+End    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select To End Of Line         :  Shift+End ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select To Start Of Line       :  Shift+Home        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select To Top Of File         :  Ctrl+Shift+Home   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Word                   :  Shift+F5  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Word Left              :  Ctrl+Shift+Left   ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Select Word Right             :  Ctrl+Shift+Right  ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Selection History...          :  Ctrl+Shift+M      ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Top Of File                   :  Ctrl+Home, Ctrl+(KeyPad) Home     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Top Of Window                 :  (KeyPad) Home     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Word Left                     :  Ctrl+Left ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Navigation: Word Right                    :  Ctrl+Right        ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *  Options: Document Options...              :  Alt+T     ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Options: Sort Symbol Window               :  Alt+F7    ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *  Project: Add File...                      :  Alt+Shift+A       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Project: Close Project                    :  Alt+Shift+W       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Project: New Project...                   :  Alt+Shift+N       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Project: Open Project...                  :  Alt+Shift+P       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Project: Remove File...                   :  Alt+Shift+R       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *  Project: Synchronize Files...             :  Alt+Shift+S       ")
    i = i+1
    InsBufLine(hbuf, ln + i, " *")              
    i = i+1
    
    InsBufLine(hbuf, ln + i, " *----------------------------------------------*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *== End Source Insight default shortcut keys ==*")
    i = i+1
    InsBufLine(hbuf, ln + i, " *==============================================*/")
    
}


