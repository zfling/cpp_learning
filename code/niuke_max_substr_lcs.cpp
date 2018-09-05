#include "niuke_max_substr_lcs.h"
#include <map>
/**
 *@brief  :链接：https://www.nowcoder.com/questionTerminal/c996bbb77dd447d681ec6907ccfb488a来源：牛客网
           对于两个字符串，请设计一个高效算法，求他们的最长公共子序列的长度，
           这里的最长公共子序列定义为有两个序列U1,U2,U3...Un和V1,V2,V3...Vn,其中Ui&ltUi+1，Vi&ltVi+1。且A[Ui] == B[Vi]。
           给定两个字符串A和B，同时给定两个串的长度n和m，请返回最长公共子序列的长度。保证两串长度均小于等于300
 *
 *@note   :测试样例：
 		   "1A2C3D4B56",10,"B1D23CA45B6A",12
 		   返回：6
 *
 *@params : string A  字符串A
 			int n     A的长度
 			string B  字符串B
 			int m     B的长度
 *
 *@return :
 *
 *@author : zhongfulin
 *@email  : 460342522@qq.com
 *@date   : 2018-9-5
 *
 */
int findLCSA(string A, int n, string B, int m) 
{
    // write code here
    map<int, map<int,int> > mapAB;
	for ( int loop = 0 ; loop <=n ; loop++)
	{
	    for ( int index = 0 ; index<=m ; index++)
	    {
	        if ( 0 == index || 0 == loop)
	        {
	            mapAB[loop][index] = 0;
				continue;
	        }
			if ( A[loop-1] == B[index-1] )
			{
			    mapAB[loop][index] = mapAB[loop-1][index-1] + 1;
			}else if ( mapAB[loop-1][index] > mapAB[loop][index-1] )
			{
			    mapAB[loop][index] =  mapAB[loop-1][index];
			}else
			{
			    mapAB[loop][index] =  mapAB[loop][index-1];
			}
	    }
	}
	return  mapAB[n][m];
}



