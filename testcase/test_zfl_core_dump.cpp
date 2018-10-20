#include "zfl_core_dump.h"
#include "gtest/gtest.h"

TEST(TEST_CASE_ZFL_CORE_DUMP, test_case_null_point)
{
	int ret = CoreDumpNullPoint();
	
	EXPECT_EQ(0, ret);
}