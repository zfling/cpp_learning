#include "niuke_max_substr_lcs.h"
#include "gtest/gtest.h"

TEST(TEST_CASE_NIUKE_MAX_SUBSTR_LCS, MAX_SUBSTR_LCS_A)
{
	string A = "1A2C3D4B56";
	int A_len = 10;
	string B = "B1D23CA45B6A";
	int B_len = 12;

	int max_len = findLCSA(A, A_len, B, B_len);
	EXPECT_EQ(6, max_len);
}