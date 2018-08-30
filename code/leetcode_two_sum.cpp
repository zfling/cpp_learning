#include "leetcode_two_sum.h"

vector<int> twoSum(vector<int>& nums, int target) {
	int numsLen = nums.size();
	vector<int> result;
	
	for (int index = 0; index < numsLen; index++) {
		for (int order = index + 1; order < numsLen; order++) {
			if (target == nums[index]+nums[order]) {
				result.push_back(index); 
				result.push_back(order);
				break;
			}
		}
	}
	return result;
}
