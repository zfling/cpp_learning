#include "zfl_core_dump.h"
#include <iostream>

using namespace std;
/**
 *@brief  : 探索core dump，开启core dump，gdb查看core文件检查代码问题
 *
 *@note   : 造成segment fault诸多原因
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
 *@date   : 2018-10-20
 *
 */
	
int CoreDumpNullPoint(void)

{

	cout<<"hello world! dump core for set value to NULL pointer"<<endl;

	*(char *)0 = 0;

	return 0;
}


