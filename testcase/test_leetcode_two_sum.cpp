#include "leetcode_two_sum.h"
#include "gtest/gtest.h"

TEST(TEST_CASE_LEETCODE_TWO_SUM, LEETCODE_TWO_SUM_A)
{
	vector<int> nums;
	nums.push_back(2);
	nums.push_back(7);
	nums.push_back(11);
	nums.push_back(15);
	int target = 18;
	vector<int> results;
	results.push_back(0);
	results.push_back(1);
	
	vector<int> re;
	re = twoSumA(nums, target);
	EXPECT_EQ(1, re[0]);
	EXPECT_EQ(2, re[1]);
}