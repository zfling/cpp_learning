/*****************************************************************************
 函 数 名  : AutoExpand
 功能描述  : 扩展命令入口函数
 输出参数  : 无
 返 回 值  : 
 调用函数  : 
 被调函数  : 
 
 修改历史      :

  3.日    期   : 2018年8月31日
    作    者   : 钟福林
    修改内容   : 修改为适合开发习惯的个人定制
	
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
    
    nVer = 0
    nVer = GetVersion()
    /*取得用户名*/
/*
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
*/
	szMyName = "zhongfulin";
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
	ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
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
		DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln + 0, "//---------------------------------------------------------------------------")
		szNoteContent = toupper(Ask("请输入注释说明:"))
		InsBufLine(hbuf, ln + 1, "//  @szNoteContent@")
		InsBufLine(hbuf, ln + 2, "//---------------------------------------------------------------------------")
		InsBufLine(hbuf, ln + 3, "")
		SetBufIns (hbuf, ln + 3, 0)
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
	else if(szCmd == "/**")
	{
		DelBufLine(hbuf, ln)
		szNoteContent = Ask("请输入注释说明:")
		InsBufLine(hbuf, ln + 0, "/** " # "@szNoteContent@" # ". */")
		InsBufLine(hbuf, ln + 1, "")
		SetBufIns (hbuf, ln + 1, 0)
		return
	}
	else if(szCmd == "he" || szCmd == "header")
	{
		DelBufLine(hbuf, ln)
		InsBufLine(hbuf, ln + 0, "/*****************************************************************************")
		InsBufLine(hbuf, ln + 1, "*                                                                            *")
		InsBufLine(hbuf, ln + 2, "*  Copyright (C) 2018 zfling  460342522@@qq.com.                              *")
		InsBufLine(hbuf, ln + 3, "*                                                                            *")
		szHeader = GetFileName(GetBufName(hbuf))
		InsBufLine(hbuf, ln + 4, "*  @@file   : " # "@szHeader@")
		szBrief = Ask("请输入头文件简要说明:")
		InsBufLine(hbuf, ln + 5, "*  @@brief  : @szBrief@")
		InsBufLine(hbuf, ln + 6, "*                                                                            *")
		InsBufLine(hbuf, ln + 7, "*  @@author : @szMyName@")
		InsBufLine(hbuf, ln + 8, "*  @@email  : 460342522@@qq.com")
		InsBufLine(hbuf, ln + 9, "*  @@version: 1.0.0")
		SysTime = GetSysTime(1)
        szYear=SysTime.Year
        szMonth=SysTime.month
        szDay=SysTime.day
		InsBufLine(hbuf, ln + 10, "*  @@date   : @szYear@-@szMonth@-@szDay@")
		InsBufLine(hbuf, ln + 11, "*  Details : ")
		InsBufLine(hbuf, ln + 12, "*                                                                            *")
		InsBufLine(hbuf, ln + 13, "*****************************************************************************/")
		InsBufLine(hbuf, ln + 14, "")
		SetBufIns (hbuf, ln + 14, 0)
		return
	}
	else if(szCmd == "fu" || szCmd == "func")
	{
		DelBufLine(hbuf, ln)
		InsBufLine(hbuf, ln + 0, "/**")
		szBrief = Ask("请输入函数简要说明:")
		InsBufLine(hbuf, ln + 1, " *@@brief  :@szBrief@")
		InsBufLine(hbuf, ln + 2, " *")
		InsBufLine(hbuf, ln + 3, " *@@note   :")
		InsBufLine(hbuf, ln + 4, " *")
		InsBufLine(hbuf, ln + 5, " *@@params :")
		InsBufLine(hbuf, ln + 6, " *")
		InsBufLine(hbuf, ln + 7, " *@@return :")
		InsBufLine(hbuf, ln + 8, " *")
		InsBufLine(hbuf, ln + 9, " *@@author : @szMyName@")
		InsBufLine(hbuf, ln + 10, " *@@email  : 460342522@@qq.com")
		SysTime = GetSysTime(1)
        szYear=SysTime.Year
        szMonth=SysTime.month
        szDay=SysTime.day
		InsBufLine(hbuf, ln + 11, " *@@date   : @szYear@-@szMonth@-@szDay@")
		InsBufLine(hbuf, ln + 12, " *")
		InsBufLine(hbuf, ln + 13, " */")
		InsBufLine(hbuf, ln + 14, "")
		SetBufIns (hbuf, ln + 14, 0)
		return
	}
	else if(szCmd == "ifn" || szCmd == "ifndef")
	{
		DelBufLine(hbuf, ln)
		szDefine = Ask("请输入define内容:")
		InsBufLine(hbuf, ln + 0, "#ifndef @szDefine@")
		InsBufLine(hbuf, ln + 1, "#define @szDefine@")
		InsBufLine(hbuf, ln + 2, "")
		InsBufLine(hbuf, ln + 3, "#endif")
		SetBufIns (hbuf, ln + 2, 0)
		return
	}
	 else if (szCmd == "wh" || szCmd == "while")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if( szCmd == "el" || szCmd == "else")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if( szCmd == "de" || szCmd == "define")
    {
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln + 0, "#define ");
        InsBufLine(hbuf, ln + 1, "");
        SetBufIns (hbuf, ln + 0, 9)
        return
    }else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " (  )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@"  # ";");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "");
        SetBufIns (hbuf, ln + 0, 5)
        return
    }else if (szCmd == "for")
    {
        SetBufSelText(hbuf, " ( # ;   ;   )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@"  # ";")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
        szVar = ask("请输入循环变量")
        newsel = sel
        newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " ( @szVar@ = # ; @szVar@ ; ++@szVar@)")
    }
    else if (szCmd == "sw" || szCmd == "switch")
    {
        nSwitch = ask("请输入case数量")
        SetBufSelText(hbuf, " (  )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
		nIdx = 0
	    while(nIdx < nSwitch)
	    {
	        //ln = ln + 4
	        InsBufLine(hbuf, ln + 2 + 4 * nIdx, "@szLine1@    " # "case  :")
	        InsBufLine(hbuf, ln + 3 + 4 * nIdx, "@szLine1@    " # "    " # ";")
	        InsBufLine(hbuf, ln + 4 + 4 * nIdx, "@szLine1@    " # "    " # "break;")
	        InsBufLine(hbuf, ln + 5 + 4 * nIdx, "")
	        nIdx = nIdx + 1
	    }
	    
	    InsBufLine(hbuf, ln + 2 + 4 * nIdx, "@szLine1@    " # "default:")
	    InsBufLine(hbuf, ln + 3 + 4 * nIdx, "@szLine1@    " # "    " # ";")
	    InsBufLine(hbuf, ln + 4 + 4 * nIdx, "@szLine1@    " # "    " # "break;")
	    InsBufLine(hbuf, ln + 5 + 4 * nIdx, "@szLine1@" # "}")
	    InsBufLine(hbuf, ln + 6 + 4 * nIdx, "");
        SetBufIns (hbuf, ln + 0, 9)
	    //SetWndSel(hwnd, 1)
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