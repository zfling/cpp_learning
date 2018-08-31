
/*****************************************************************************
 函 数 名  : AutoExpand
 功能描述  : 扩展命令入口函数
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :

  2.日    期   : 2006年9月18日
    作    者   : 童巧平
    修改内容   : 修改默认语言为英文，增强快捷命令功能
 
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 修改

*****************************************************************************/
macro AutoExpand()
{
    //配置信息
    // get window, sel, and buffer handles
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.lnFirst != sel.lnLast) 
    {
        /*块命令处理*/
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
    /*取得用户名*/
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

    /*自动完成简化命令的匹配显示*/
    wordinfo.szWord = RestoreCommand(hbuf,wordinfo.szWord)
    sel = GetWndSel(hwnd)
    if (wordinfo.szWord == "pn") /*问题单号的处理*/
    {
        DelBufLine(hbuf, ln)
        AddPromblemNo()
        return
    }
    /*配置命令执行*/
    else if (wordinfo.szWord == "config" || wordinfo.szWord == "co")
    {
        DelBufLine(hbuf, ln)
        ConfigureSystem()
        return
    }
    /*修改历史记录更新*/
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
 函 数 名  : ExpandProcEN
 功能描述  : 英文说明的扩展命令处理
 输入参数  : szMyName  用户名
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
  
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    /*英文注释*/
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

        /*生成不要文件名的新头文件*/
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
 函 数 名  : ExpandProcCN
 功能描述  : 中文说明的扩展命令
 输入参数  : szMyName  
             wordinfo  
             szLine    
             szLine1   
             nVer      
             ln        
             sel       
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)

    //中文注释
    if (szCmd == "/*")
    {   
        if(wordinfo.ichLim > 70)
        {
            Msg("右边空间太小,请用新的行")
            stop 
        }        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        /*注释只能在行尾，避免注释掉有用代码*/
        while(wordinfo.ichLim + kk < lineLen)
        {
            if(szCurLine[wordinfo.ichLim + kk] != " ")
            {
                msg("只能在行尾插入");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("请输入注释的内容")
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
        szVar = ask("请输入循环变量")
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
        nSwitch = ask("请输入case的个数")
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
        szStructName = toupper(Ask("请输入结构名:"))
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
        //提示输入枚举名并转换为大写
        szStructName = toupper(Ask("请输入枚举名:"))
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
        /*生成文件头说明*/
        InsertFileHeaderCN( hbuf,0, szMyName,"" )
        return
    }
    else if (szCmd == "hd")
    {
        DelBufLine(hbuf, ln)
        /*生成C语言的头文件*/
        CreateFunctionDef(hbuf,szMyName,0)
        return
    }
    else if (szCmd == "hdn")
    {
        DelBufLine(hbuf, ln)
        /*生成不要文件名的新头文件*/
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
            /*对于2.1版的si如果是非法symbol就会中断执行，故该为以后一行
              是否有‘（’来判断是否是新函数*/
            if( (FindInStr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                /*是已经存在的函数*/
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {  
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0)
                    return
                }
            }
        }
        szFuncName = Ask("请输入函数名称:")
        /*是新函数*/
        FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else if (szCmd == "tab") /*将tab扩展为空格*/
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
        InsBufLine(hbuf, ln, "@szLine1@/* 问 题 单: @szQuestion@     修改人:@szMyName@,   时间:@sz@/@sz1@/@sz3@ ");
        szContent = Ask("修改原因")
        szLeft = cat(szLine1,"   修改原因: ");
        if(strlen(szLeft) > 70)
        {
            Msg("右边空间太小,请用新的行")
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
            InsBufLine(hbuf, ln, "@szLine1@/* END:   Added for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
		InsBufLine(hbuf, ln, "@szLine1@/* END:  Deleted for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
		InsBufLine(hbuf, ln, "@szLine1@/* END:  Modified for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
 函 数 名  : BlockCommandProc
 功能描述  : 块命令处理函数
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        InsertWhile()   /*插入while*/
    }
    else if(szLine == "do")
    {
        InsertDo()   //插入do while语句
    }
    else if(szLine == "for")
    {
        InsertFor()  //插入for语句
    }
    else if(szLine == "if")
    {
        InsertIf()   //插入if语句
    }
    else if(szLine == "el" || szLine == "else")
    {
        InsertElse()  //插入else语句
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifd") || (szLine == "#ifdef"))
    {
        InsIfdef()        //插入#ifdef
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifn") || (szLine == "#ifndef"))
    {
        InsIfndef()        //插入#ifdef
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
 函 数 名  : RestoreCommand
 功能描述  : 缩略命令恢复函数
 输入参数  : hbuf   
             szCmd  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : SearchForward
 功能描述  : 向前搜索#
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro SearchForward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Forward
}

/*****************************************************************************
 函 数 名  : SearchBackward
 功能描述  : 向后搜索#
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro SearchBackward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Backward
}

/*****************************************************************************
 函 数 名  : InsertFuncName
 功能描述  : 在当前位置插入但前函数名
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : FindInStr
 功能描述  : 字符串匹配查询函数
 输入参数  : str1  源串
             str2  待匹配子串
 输出参数  : 无
 返 回 值  : 0xffffffff为没有找到匹配字符串，V2.1不支持-1故采用该值
             其它为匹配字符串的起始位置
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertTraceInfo
 功能描述  : 在函数的入口和出口插入打印,不支持一行有多条语句的情况
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertTraceInCurFunction
 功能描述  : 在函数的入口和出口插入打印,不支持一行有多条语句的情况
 输入参数  : hbuf
             symbol
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        
        /*剔除其中的注释语句*/
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //查找是否有return语句
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
        //获得左边空白大小
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
        //查找是否有return语句
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
    
    //只要前面的return后有一个"}"了说明函数的结尾没有返回，需要再加一个出口打印
    if(fIsNeedPrt == 1)
    {
        InsBufLine(hbuf, ln,  "    VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---: @nExitCount@ \");")        
        InsBufLine(hbuf, ln,  "")        
    }
}

/*****************************************************************************
 函 数 名  : GetFirstWord
 功能描述  : 取得字符串的第一个单词
 输入参数  : szLine
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : AutoInsertTraceInfoInBuf
 功能描述  : 自动当前文件的全部函数出入口加入打印，只能支持C++
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
                        
                        //去掉注释的干扰
                        RetVal = SkipCommentFromString(szLine,fIsEnd)
                                szNew = RetVal.szContent
                                fIsEnd = RetVal.fIsEnd
                        if(isCodeBegin == 1)
                        {
                            szNew = TrimLeft(szNew)
                            //检测是否是可执行代码开始
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
                                //查找到函数的开始
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
                    
                    //去掉注释的干扰
                    RetVal = SkipCommentFromString(szLine,fIsEnd)
                        szNew = RetVal.szContent
                        fIsEnd = RetVal.fIsEnd
                    if(isCodeBegin == 1)
                    {
                        szNew = TrimLeft(szNew)
                        //检测是否是可执行代码开始
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
                        //查找到函数的开始
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
 函 数 名  : CheckIsCodeBegin
 功能描述  : 是否为函数的第一条可执行代码
 输入参数  : szLine 左边没有空格和注释的字符串
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : AutoInsertTraceInfoInPrj
 功能描述  : 自动当前工程全部文件的全部函数出入口加入打印，只能支持C++
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //自动保存打开文件，可根据需要打开
/*        if( IsBufDirty (hbuf) )
        {
            SaveBuf (hbuf)
        }
        CloseBuf(hbuf)*/
        ifile = ifile + 1
    }
}

/*****************************************************************************
 函 数 名  : RemoveTraceInfo
 功能描述  : 删除该函数的出入口打印
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        
        /*剔除其中的注释语句*/
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
 函 数 名  : RemoveCurBufTraceInfo
 功能描述  : 从当前的buf中删除添加的出入口打印信息
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : RemovePrjTraceInfo
 功能描述  : 删除工程中的全部加入的函数的出入口打印
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //自动保存打开文件，可根据需要打开
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
 函 数 名  : InsertFileHeaderEN
 功能描述  : 插入英文文件头描述
 输入参数  : hbuf       
             ln         行号
             szName     作者名
             szContent  功能描述内容
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    
    //插入函数列表
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
    
    //如果没有功能描述内容则提示输入
    szContent = Ask("Description")
    SetBufIns(hbuf,nlnDesc + 14,0)
    DelBufLine(hbuf,nlnDesc +10)
    
    //注释输出处理,自动换行
    CommentContent(hbuf,nlnDesc + 10,"*  Description   : ",szContent,0)
    return ln+17
}


/*****************************************************************************
 函 数 名  : InsertFileHeaderCN
 功能描述  : 插入中文描述文件头说明
 输入参数  : hbuf       
             ln         
             szName     
             szContent  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    InsBufLine(hbuf, ln + 2,  "                  版权所有 (C), 2001-2011, 华为技术有限公司")
    InsBufLine(hbuf, ln + 3,  "")
    InsBufLine(hbuf, ln + 4,  " ******************************************************************************")
    sz = GetFileName(GetBufName (hbuf))
    InsBufLine(hbuf, ln + 5,  "  文 件 名   : @sz@")
    InsBufLine(hbuf, ln + 6,  "  版 本 号   : 初稿")
    InsBufLine(hbuf, ln + 7,  "  作    者   : @szName@")
    SysTime = GetSysTime(1)
    szTime = SysTime.Date
    InsBufLine(hbuf, ln + 8,  "  生成日期   : @szTime@")
    InsBufLine(hbuf, ln + 9,  "  最近修改   :")
    iLen = strlen (szContent)
    nlnDesc = ln
    szTmp = "  功能描述   : "
    InsBufLine(hbuf, ln + 10, "  功能描述   : @szContent@")
    InsBufLine(hbuf, ln + 11, "  函数列表   :")
    
    //插入函数列表
    ln = InsertFileList(hbuf,hnewbuf,ln + 12) - 12
    closebuf(hnewbuf)
    InsBufLine(hbuf, ln + 12, "  修改历史   :")
    InsBufLine(hbuf, ln + 13, "  1.日    期   : @szTime@")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln + 14, "    作    者   : @szName@")
    }
    else
    {
       InsBufLine(hbuf, ln + 14, "    作    者   : #")
    }
    InsBufLine(hbuf, ln + 15, "    修改内容   : 创建文件")    
    InsBufLine(hbuf, ln + 16, "")
    InsBufLine(hbuf, ln + 17, "******************************************************************************/")
    InsBufLine(hbuf, ln + 18, "")
    InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 20, " * 外部变量说明                                 *")
    InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 22, "")
    InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 24, " * 外部函数原型说明                             *")
    InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 26, "")
    InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 28, " * 内部函数原型说明                             *")
    InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 30, "")
    InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 32, " * 全局变量                                     *")
    InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 34, "")
    InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 36, " * 模块级变量                                   *")
    InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 38, "")
    InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 40, " * 常量定义                                     *")
    InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 42, "")
    InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 44, " * 宏定义                                       *")
    InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 46, "")
    if(strlen(szContent) != 0)
    {
        return
    }
    
    //如果没有输入功能描述的话提示输入
    szContent = Ask("请输入文件功能描述的内容")
    SetBufIns(hbuf,nlnDesc + 14,0)
    DelBufLine(hbuf,nlnDesc +10)
    
    //自动排列显示功能描述
    CommentContent(hbuf,nlnDesc+10,"  功能描述   : ",szContent,0)
}

/*****************************************************************************
 函 数 名  : GetFunctionList
 功能描述  : 获得函数列表
 输入参数  : hbuf  
             hnewbuf    
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetFunctionList(hbuf,hnewbuf)
{
    isymMax = GetBufSymCount (hbuf)
    isym = 0
    //依次取出全部的但前buf符号表中的全部符号
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
                //取出类型是函数和宏的符号
                symname = symbol.Symbol
                //将符号插入到新buf中这样做是为了兼容V2.1
                AppendBufLine(hnewbuf,symname)
               }
           }
        isym = isym + 1
    }
}
/*****************************************************************************
 函 数 名  : InsertFileList
 功能描述  : 函数列表插入
 输入参数  : hbuf  
             ln    
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : CommentContent1
 功能描述  : 自动排列显示文本,因为msg对话框不能处理多行的情况，而且不能超过255
             个字符，作为折中，采用了从简帖板取数据的办法，如果如果的数据是剪
             贴板中内容的前部分的话就认为用户是拷贝的内容，这样做虽然有可能有
             误，但这种概率非常低。与CommentContent不同的是它将剪贴板中的内容
             合并成一段来处理，可以根据需要选择这两种方式
 输入参数  : hbuf       
             ln         行号
             szPreStr   首行需要加入的字符串
             szContent  需要输入的字符串内容
             isEnd      是否需要在末尾加入'*'和'/'
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro CommentContent1 (hbuf,ln,szPreStr,szContent,isEnd)
{
    //将剪贴板中的多段文本合并
    szClip = MergeString()
    //去掉多余的空格
    szTmp = TrimString(szContent)
    //如果输入窗口中的内容是剪贴板中的内容说明是剪贴过来的
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
                //如果是中文必须成对处理
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
 函 数 名  : CommentContent
 功能描述  : 自动排列显示文本,因为msg对话框不能处理多行的情况，而且不能超过255
             个字符，作为折中，采用了从简帖板取数据的办法，如果如果的数据是剪
             贴板中内容的前部分的话就认为用户是拷贝的内容，这样做虽然有可能有
             误，但这种概率非常低
 输入参数  : hbuf       
             ln         行号
             szPreStr   首行需要加入的字符串
             szContent  需要输入的字符串内容
             isEnd      是否需要在末尾加入'*'和'/'
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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

    //判断如果剪贴板是0行时对于有些版本会有问题，要排除掉
    if(lnMax != 0)
    {
        szLine = GetBufLine(hNewBuf , 0)
            ret = FindInStr(szLine,szTmp)
            if(ret == 0)
            {
                /*如果输入窗输入的内容是剪贴板的一部分说明是剪贴过来的取剪贴板中的内
                  容*/
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
            //以每行75个字符处理
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
                    //如果是中文字符只能成对处理
                    while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                    {
                        n = n + 1
                        if((n >= 3) ||(i + j + n >= iLen))
                             break;
                        iNum = szContent[i + j + n]
                    }
                    if(n < 3)
                    {
                        //分段后只有小于3个的字符留在下段则将其以上去
                        j = j + n 
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)                
                    }
                    else
                    {
                        //大于3个字符的加连字符分段
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
 函 数 名  : FormatLine
 功能描述  : 将一行长文本进行自动分行
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro FormatLine()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.ichFirst > 70)
    {
        Msg("选择太靠右了")
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
 函 数 名  : CreateBlankString
 功能描述  : 产生几个空格的字符串
 输入参数  : nBlankCount  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : TrimLeft
 功能描述  : 去掉字符串左边的空格
 输入参数  : szLine  
 输出参数  : 去掉左空格后的字符串
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : TrimRight
 功能描述  : 去掉字符串右边的空格
 输入参数  : szLine  
 输出参数  : 去掉右空格后的字符串
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : TrimString
 功能描述  : 去掉字符串左右空格
 输入参数  : szLine  
 输出参数  : 去掉左右空格后的字符串
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
}


/*****************************************************************************
 函 数 名  : GetFunctionDef
 功能描述  : 将分成多行的函数参数头合并成一行
 输入参数  : hbuf    
             symbol  函数符号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //去掉被注释掉的内容
        RetVal = SkipCommentFromString(szLine,fIsEnd)
                szLine = RetVal.szContent
                szLine = TrimString(szLine)
                fIsEnd = RetVal.fIsEnd
        //如果是'{'表示函数参数头结束了
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
 函 数 名  : GetWordFromString
 功能描述  : 从字符串中取得以某种方式分割的字符串组
 输入参数  : hbuf         生成分割后字符串的buf
             szLine       字符串
             nBeg         开始检索位置
             nEnd         结束检索位置
             chBeg        开始的字符标志
             chSeparator  分割字符
             chEnd        结束字符标志
 输出参数  : 最大字符长度
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetWordFromString(hbuf,szLine,nBeg,nEnd,chBeg,chSeparator,chEnd)
{
    if((nEnd > strlen(szLine) || (nBeg > nEnd))
    {
        return 0
    }
    nMaxLen = 0
    nIdx = nBeg
    //先定位到开始字符标记处
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chBeg)
        {
            break
        }
        nIdx = nIdx + 1
    }
    nBegWord = nIdx + 1
    
    //用于检测chBeg和chEnd的配对情况
    iCount = 0
    
    nEndWord = 0
    //以分隔符为标记进行搜索
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
 函 数 名  : FuncHeadCommentCN
 功能描述  : 生成中文的函数头注释
 输入参数  : hbuf      
             ln        行号
             szFunc    函数名
             szMyName  作者名
             newFunc   是否新函数
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
            //将文件参数头整理成一行并去掉了注释
            szLine = GetFunctionDef(hbuf,symbol)            
            iBegin = symbol.ichName 
            //取出返回值定义
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
                //对于宏返回值特殊处理
                szRet = ""
            }
            //从函数头分离出函数参数
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
        InsBufLine(hbuf, ln+1, " 函 数 名  : @szFunc@")
    }
    else
    {
        InsBufLine(hbuf, ln+1, " 函 数 名  : #")
    }
    oldln = ln
    InsBufLine(hbuf, ln+2, " 功能描述  : ")
    szIns = " 输入参数  : "
    if(newFunc != 1)
    {
        //对于已经存在的函数插入函数参数
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
            InsBufLine(hbuf, ln+2, " 输入参数  : 无")
    }
    InsBufLine(hbuf, ln+3, " 输出参数  : 无")
    InsBufLine(hbuf, ln+4, " 返 回 值  : @szRet@")
    InsBufLine(hbuf, ln+5, " 调用函数  : ")
    InsBufLine(hbuf, ln+6, " 被调函数  : ")
    InsbufLIne(hbuf, ln+7, " ");
    InsBufLine(hbuf, ln+8, " 修改历史      :")
    SysTime = GetSysTime(1);
    szTime = SysTime.Date

    InsBufLine(hbuf, ln+9, "  1.日    期   : @szTime@")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln+10, "    作    者   : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln+10, "    作    者   : #")
    }
    InsBufLine(hbuf, ln+11, "    修改内容   : 新生成函数")    
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
    szContent = Ask("请输入函数功能描述的内容")
    setWndSel(hwnd,sel)
    DelBufLine(hbuf,oldln + 2)

    //显示输入的功能描述内容
    newln = CommentContent(hbuf,oldln+2," 功能描述  : ",szContent,0) - 2
    ln = ln + newln - oldln
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        isFirstParam = 1
            
        //提示输入新函数的返回值
        szRet = Ask("请输入返回值类型")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+4, " 返 回 值  : @szRet@")            
            PutBufLine(hbuf, ln+14, "@szRet@ @szFunc@(   )")
            SetbufIns(hbuf,ln+14,strlen(szRet)+strlen(szFunc) + 3
        }
        szFuncDef = ""
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 3
        sel.ichLim = sel.ichFirst + 1
        //循环输入参数
        while (1)
        {
            szParam = ask("请输入函数参数名")
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
 函 数 名  : FuncHeadCommentEN
 功能描述  : 函数头英文说明
 输入参数  : hbuf      
             ln        
             szFunc    
             szMyName  
             newFunc   
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
                
            //将文件参数头整理成一行并去掉了注释
            szLine = GetFunctionDef(hbuf,symbol)
            iBegin = symbol.ichName
            
            //取出返回值定义
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
                //对于宏返回值特殊处理
                szRet = ""
            }
            
            //从函数头分离出函数参数
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
        //对于已经存在的函数输出输入参数表
        i = 0
        while ( i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)
            nLen = strlen(szTmp);
            
            //对齐参数后面的空格，实际是对齐后面的参数的说明
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
        //提示输入函数返回值名
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

        //循环输入新函数的参数
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
 函 数 名  : InsertHistory
 功能描述  : 插入修改历史记录
 输入参数  : hbuf      
             ln        行号
             language  语种
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertHistory(hbuf,ln,language)
{
    iHistoryCount = 1
    isLastLine = ln
    i = 0
    while(ln+i>0)
    {
        szCurLine = GetBufLine(hbuf, ln+i);
        iBeg1 = FindInStr(szCurLine,"日    期")
        iBeg2 = FindInStr(szCurLine,"Date")
        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
        {
            iHistoryCount = iHistoryCount + 1
            i = i + 1
            continue
        }
/****** modify by Tong Qiaoping *************        
        iBeg1 = FindInStr(szCurLine,"作    者")
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
 函 数 名  : UpdateFunctionList
 功能描述  : 更新函数列表
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        
        //以文件头说明中前有大于10个空格的为函数列表记录
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

    //插入函数列表
    InsertFileList( hbuf,hnewbuf,ln )
    closebuf(hnewbuf)
 }

/*****************************************************************************
 函 数 名  : InsertHistoryContentCN
 功能描述  : 插入历史修改记录中文说明
 输入参数  : hbuf           
             ln             
             iHostoryCount  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro  InsertHistoryContentCN(hbuf,ln,iHostoryCount)
{
    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    szMyName = getreg(MYNAME)

    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln + 1, "  @iHostoryCount@.日    期   : @szTime@")

    if( strlen(szMyName) > 0 )
    {
       InsBufLine(hbuf, ln + 2, "    作    者   : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln + 2, "    作    者   : #")
    }
       szContent = Ask("请输入修改的内容")
       CommentContent(hbuf,ln + 3,"    修改内容   : ",szContent,0)
}


/*****************************************************************************
 函 数 名  : InsertHistoryContentEN
 功能描述  : 插入历史修改记录英文说明
 输入参数  : hbuf           当前buf
             ln             当前行号
             iHostoryCount  修改记录的编号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : CreateFunctionDef
 功能描述  : 生成C语言头文件
 输入参数  : hbuf      
             szName    
             language  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro CreateFunctionDef(hbuf, szName, language)
{
    ln = 0

    //获得当前没有后缀的文件名
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        sz = ask("请输入头文件名")
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
    //搜索符号表取得函数名
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
        szContent = cat(szContent," 的头文件")
        //插入文件头说明
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")
        //插入文件头说明
        InsertFileHeaderEN(hOutbuf,0,szName,szContent)        
    }
}


/*****************************************************************************
 函 数 名  : GetLeftWord
 功能描述  : 取得左边的单词
 输入参数  : szLine    
             ichRight 开始取词位置
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月05日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : CreateClassPrototype
 功能描述  : 生成Class的定义
 输入参数  : hbuf      当前文件
             hOutbuf   输出文件
             ln        输出行号
             symbol    符号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月05日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    //去掉注释的干扰
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
                    //函数参数头结束
                    isLastLine = 1  
                    //去掉最后多余的字符
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
            //函数参数头还没有结束再取一行
            szLine = GetBufLine (hbuf, sline)
            //去掉注释的干扰
            RetVal = SkipCommentFromString(szLine,fIsEnd)
                szNew = RetVal.szContent
                fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}

/*****************************************************************************
 函 数 名  : CreateFuncPrototype
 功能描述  : 生成C函数原型定义
 输入参数  : hbuf      当前文件
             hOutbuf   输出文件
             ln        输出行号
             szType    原型类型
             symbol    符号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月05日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro CreateFuncPrototype(hbuf,ln,szType,symbol)
{
    isLastLine = 0
    hOutbuf = GetCurrentBuf()
    szLine = GetBufLine (hbuf,symbol.lnName)
    //去掉注释的干扰
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
                    //函数参数头结束
                    isLastLine = 1  
                    //去掉最后多余的字符
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
            //函数参数头还没有结束再取一行
            szLine = GetBufLine (hbuf, sline)
            szLine = cat("         ",szLine)
            //去掉注释的干扰
            RetVal = SkipCommentFromString(szLine,fIsEnd)
                szNew = RetVal.szContent
                fIsEnd = RetVal.fIsEnd
        }                    
    }
    return ln
}


/*****************************************************************************
 函 数 名  : CreateNewHeaderFile
 功能描述  : 生成一个新的头文件，文件名可输入
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    //获得当前没有后缀的文件名
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
        szContent = cat(szContent," 的头文件")

        //插入文件头说明
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")

        //插入文件头说明
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
    //搜索符号表取得函数名
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
        //只提取字符和'#','{','/','*'作为命令
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
 函 数 名  : ReplaceBufTab
 功能描述  : 替换tab为空格
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ReplaceBufTab()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    iTotalLn = GetBufLineCount (hbuf)
    nBlank = Ask("一个Tab替换几个空格")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)
    ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
}

/*****************************************************************************
 函 数 名  : ReplaceTabInProj
 功能描述  : 在整个工程内替换tab为空格
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ReplaceTabInProj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    nBlank = Ask("一个Tab替换几个空格")
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
 函 数 名  : ReplaceInBuf
 功能描述  : 替换tab为空格,只在2.1中有效
 输入参数  : hbuf             
             chOld            
             chNew            
             nBeg             
             nEnd             
             fMatchCase       
             fRegExp          
             fWholeWordsOnly  
             fConfirm         
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ConfigureSystem
 功能描述  : 配置系统
 输入参数  : 无
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : GetLeftBlank
 功能描述  : 得到字符串左边的空格字符数
 输入参数  : szLine  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ExpandBraceLittle
 功能描述  : 小括号扩展
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ExpandBraceMid
 功能描述  : 中括号扩展
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ExpandBraceLarge
 功能描述  : 大括号扩展
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月18日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //对于没有块选择的情况，直接插入{}即可
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
        //对于有块选择的情况还得考虑将块选择区分开了
        
        //检查选择区内是否大括号配对，如果嫌太慢则注释掉下面的判断
        RetVal= CheckBlockBrace(hbuf)
        if(RetVal.iCount != 0)
        {
            msg("Invalidated brace number")
            stop
        }
        
        //取出选中区前的内容
        szOld = strmid(szLine,0,sel.ichFirst)
        if(sel.lnFirst != sel.lnLast)
        {
            //对于多行的情况
            
            //第一行的选中部分
            szMid = strmid(szLine,sel.ichFirst,strlen(szLine))
            szMid = TrimString(szMid)
            szLast = GetBufLine(hbuf,sel.lnLast)
            if( sel.ichLim > strlen(szLast) )
            {
                //如果选择区长度大于改行的长度，最大取该行的长度
                szLineselichLim = strlen(szLast)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            
            //得到最后一行选择区为的字符
            szRight = strmid(szLast,szLineselichLim,strlen(szLast))
            szRight = TrimString(szRight)
        }
        else
        {
            //对于选择只有一行的情况
             if(sel.ichLim >= strlen(szLine))
             {
                 sel.ichLim = strlen(szLine)
             }
             
             //获得选中区的内容
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
             
             //同样得到选中区后的内容
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
                //对于最后一行应该是选中区内的内容后移四位
                szCurLine = strmid(szCurLine,0,szLineselichLim + 4)
                PutBufLine(hbuf,nIdx+1,szCurLine)                    
            }
            else
            {
                //其它情况是整行的内容后移四位
                PutBufLine(hbuf,nIdx+1,szCurLine)
            }
            nIdx = nIdx + 1
        }
        if(strlen(szRight) != 0)
        {
            //最后插入最后一行没有被选择的内容
            InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@@szRight@")        
        }
        InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@}")        
        nlineCount = nlineCount + 1
        if(nLeft < sel.ichFirst)
        {
            //如果选中区前的内容不是空格，则要保留该部分内容
            PutBufLine(hbuf,ln,szOld)
            InsBufLine(hbuf, ln+1, "@szLeft@{")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }
        else
        {
            //如果选中区前没有内容直接删除该行
            DelBufLine(hbuf,ln)
            InsBufLine(hbuf, ln, "@szLeft@{")
        }
        if(strlen(szMid) > 0)
        {
            //插入第一行选择区的内容
            InsBufLine(hbuf, ln+1, "@szLeft@    @szMid@")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }        
    }
    retVal.szLeft = szLeft
    retVal.nLineCount = nlineCount
    //返回行数和左边的空白
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
 函 数 名  : DelCompoundStatement
 功能描述  : 删除一个复合语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //查找复合语句的开始
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
            //查找对应的大括号
            
            //使用自己编写的代码速度太慢
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
            
            //使用Si的大括号配对方法，但V2.1时在注释嵌套时可能有误
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
 函 数 名  : CheckBlockBrace
 功能描述  : 检测定义块中的大括号配对情况
 输入参数  : hbuf  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : SearchCompoundEnd
 功能描述  : 查找一个复合语句的结束点
 输入参数  : hbuf    
             ln      查询起始行
             ichBeg  查询起始点
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        
        //如果nCount=0则说明"{""}"是配对的
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
 函 数 名  : CheckBrace
 功能描述  : 检测括号的配对情况
 输入参数  : szLine       输入字符串
             ichBeg       检测起始
             ichEnd       检测结束
             chBeg        开始字符(左括号)
             chEnd        结束字符(右括号)
             nCheckCount  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        //如果是/*注释区，跳过该段
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
        //如果是//注释则停止查找
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
 函 数 名  : InsertElse
 功能描述  : 插入else语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertCase
 功能描述  : 插入case语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertSwitch
 功能描述  : 插入swich语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    nSwitch = ask("请输入case的个数")
    InsertMultiCaseProc(hbuf,szLeft,nSwitch)
    SearchForward()    
}

/*****************************************************************************
 函 数 名  : InsertMultiCaseProc
 功能描述  : 插入多个case
 输入参数  : hbuf     
             szLeft   
             nSwitch  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
            //先去掉代码中注释的内容
            RetVal = SkipCommentFromString(szLine,fIsEnd)
            szLine = RetVal.szContent
            fIsEnd = RetVal.fIsEnd
//            nLeft = GetLeftBlank(szLine)
            //从剪贴板中取得case值
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
 函 数 名  : GetSwitchVar
 功能描述  : 从枚举、宏定义取得case值
 输入参数  : szLine  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : SkipCommentFromString
 功能描述  : 去掉注释的内容，将注释内容清为空格
 输入参数  : szLine        输入行的内容
             isCommentEnd  是否但前行的开始已经是注释结束了
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro SkipCommentFromString(szLine,isCommentEnd)
{
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)
    nIdx = 0
    while(nIdx < nLen )
    {
        //如果当前行开始还是被注释，或遇到了注释开始的变标记，注释内容改为空格?
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
                
                //如果是倒数第二个则最后一个也肯定是在注释内
//                if(nIdx == nLen -2 )
//                "{"
//                    szLine[nIdx + 1] = " "
//                "}"
                nIdx = nIdx + 1 
            }    
            
            //如果已经到了行尾终止搜索
            if(nIdx == nLen)
            {
                break
            }
        }
        
        //如果遇到的是//来注释的说明后面都为注释
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
 函 数 名  : InsertDo
 功能描述  : 插入Do语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertWhile
 功能描述  : 插入While语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertFor
 功能描述  : 插入for语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
    szVar = ask("请输入循环变量")
    PutBufLine(hbuf,ln, "@szLeft@for ( @szVar@ = # ; @szVar@ # ; @szVar@++ )")
    SearchForward()
}

/*****************************************************************************
 函 数 名  : InsertIf
 功能描述  : 插入If语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : MergeString
 功能描述  : 将剪贴板中的语句合并成一行
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro MergeString()
{
    hbuf = newbuf("clip")
    if(hbuf == hNil)
        return       
    SetCurrentBuf(hbuf)
    PasteBufLine (hbuf, 0)
    
    //如果剪贴板中没有内容，则返回
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
 函 数 名  : ClearPrombleNo
 功能描述  : 清除问题单号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro ClearPrombleNo()
{
   SetReg ("PNO", "")
}

/*****************************************************************************
 函 数 名  : AddPromblemNo
 功能描述  : 添加问题单号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ComentCPPtoC
 功能描述  : 转换C++注释为C注释
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年7月02日
    作    者   : 卢胜文
    修改内容   : 新生成函数,支持块注释

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
        /*如果是空行，跳过该行*/
        if(ich == ilen)
        {         
            lnCurrent = lnCurrent + 1
            szOldLine = szLine
            continue 
        }
        
        /*如果该行只有一个字符*/
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
            /*如果不是在注释区内*/
            if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
            {
                /* 去掉中间嵌套的注释 */
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
                    /* 如果是连续的注释*/
                    szLine[ich] = " "
                    szLine[ich+1] = " "
                }
                else
                {
                    /*如果不是连续的注释则是新注释的开始*/
                    szLine[ich] = "/"
                    szLine[ich+1] = "*"
                }
                if ( lnCurrent == lnLast )
                {
                    /*如果是最后一行则在行尾添加结束注释符*/
                    szLine = cat(szLine,", @szMyName@, @sz@/@sz1@/@sz3@ */")
                    isCommentContinue = 0
                }
                /*更新该行*/
                PutBufLine(hbuf,lnCurrent,szLine)
                isCommentContinue = 1
                szOldLine = szLine
                lnCurrent = lnCurrent + 1
                continue 
            }
            else
            {   
                /*如果该行的起始不是//注释*/
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
            //如果是/*注释区，跳过该段
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
                /* 如果是//注释*/
                isCommentContinue = 1
                nIdx = ich
                //去掉期间的/* 和 */注释符以免出现注释嵌套错误
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
 函 数 名  : CmtCvtLine
 功能描述  : 将//转换成/*注释
 输入参数  : lnCurrent  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 
    作    者   : 
    修改内容   : 

  2.日    期   : 2002年7月02日
    作    者   : 卢胜文
    修改内容   : 修改了注释嵌套所产生的问题?

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
        //如果是/*注释区，跳过该段
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
 函 数 名  : GetFileNameExt
 功能描述  : 得到文件扩展名
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : GetFileNameNoExt
 功能描述  : 得到函数名没有扩展名
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : GetFileName
 功能描述  : 得到带扩展名的文件名
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsIfdef
 功能描述  : 插入#ifdef语句
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro InsIfdef()
{
    sz = Ask("Enter #ifdef condition:")
    if (sz != "")
        IfdefStr(sz);
}

/*****************************************************************************
 函 数 名  : InsIfndef
 功能描述  : ＃ifndef语句对插入的入口调用宏
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro InsIfndef()
{
    sz = Ask("Enter #ifndef condition:")
    if (sz != "")
        IfndefStr(sz);
}

/*****************************************************************************
 函 数 名  : InsertCPP
 功能描述  : 在buf中插入C类型定义
 输入参数  : hbuf  
             ln    
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ReviseCommentProc
 功能描述  : 问题单修改命令处理
 输入参数  : hbuf      
             ln        
             szCmd     
             szMyName  
             szLine1   
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        InsBufLine(hbuf, ln, "@szLine1@/* 问 题 单: @szQuestion@     修改人:@szMyName@,   时间:@sz@/@sz1@/@sz3@ ");
        szContent = Ask("修改原因")
        szLeft = cat(szLine1,"   修改原因: ");
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified for 问题单号:@szQuestion@ by @szMyName@, @sz@/@sz1@/@sz3@ */");
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
 函 数 名  : InsertReviseAdd
 功能描述  : 插入添加修改注释对
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertReviseDel
 功能描述  : 插入删除修改注释对
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertReviseMod
 功能描述  : 插入修改注释对
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : IfndefStr
 功能描述  : 插入＃ifndef语句对
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : InsertPredefIf
 功能描述  : 插入＃if语句对的入口调用宏
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro InsertPredefIf()
{
    sz = Ask("Enter #if condition:")
    PredefIfStr(sz)
}

/*****************************************************************************
 函 数 名  : PredefIfStr
 功能描述  : 在选择行前后插入＃if语句对
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : HeadIfdefStr
 功能描述  : 在选择行前后插入#ifdef语句对
 输入参数  : sz  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : GetSysTime
 功能描述  : 取得系统时间，只在V2.1时有用
 输入参数  : a  
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月24日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetSysTime(a)
{
    //从sidate取得时间
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
        SysTime.Date="2002年05月20日"
    }
    else
    {
        SysTime.Month=getreg(Month)
        SysTime.Day=getreg(Day)
        SysTime.Date=getreg(Date)
   /*         SysTime.Date=cat(SysTime.Year,"年")
        SysTime.Date=cat(SysTime.Date,SysTime.Month)
        SysTime.Date=cat(SysTime.Date,"月")
        SysTime.Date=cat(SysTime.Date,SysTime.Day)
        SysTime.Date=cat(SysTime.Date,"日")*/
    }
    return SysTime
}

/*****************************************************************************
 函 数 名  : HeaderFileCreate
 功能描述  : 生成头文件
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : FunctionHeaderCreate
 功能描述  : 生成函数头
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
        szFuncName = Ask("请输入函数名称:")
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else
    {
        szFuncName = Ask("Please input function name")
           FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    
    }
}

/*****************************************************************************
 函 数 名  : GetVersion
 功能描述  : 得到Si的版本号
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetVersion()
{
   Record = GetProgramInfo ()
   return Record.versionMajor
}

/*****************************************************************************
 函 数 名  : GetProgramInfo
 功能描述  : 获得程序信息，V2.1才用
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

*****************************************************************************/
macro GetProgramInfo ()
{   
    Record = ""
    Record.versionMajor     = 2
    Record.versionMinor    = 1
    return Record
}

/*****************************************************************************
 函 数 名  : FileHeaderCreate
 功能描述  : 生成文件头
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2002年6月19日
    作    者   : 卢胜文
    修改内容   : 新生成函数

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
 函 数 名  : ShowHelp
 功能描述  : 列出本Quicker所支持的快捷命令
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2006年11月22日
    作    者   : 童巧平
    修改内容   : 新生成函数

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
 函 数 名  : ShowShortKey
 功能描述  : 列出Source Insight的默认快捷键
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :
  1.日    期   : 2006年11月22日
    作    者   : 童巧平
    修改内容   : 新生成函数

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



