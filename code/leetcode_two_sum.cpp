#include "leetcode_two_sum.h"

/** 
 * @brief Given an array of integers, 
 *        return indices of the two numbers such that they add up to a specific target.
 *  	  You may assume that each input would have exactly one solution, 
 *		  and you may not use the same element twice.
 * @note  Given nums = [2, 7, 11, 15], target = 9,
 *		  Because nums[0] + nums[1] = 2 + 7 = 9,
 *		  return [0, 1].
 * @param nums		vector<int> 引用，给定的数组
 * @param target	给定的目标和
 *
 * @return vector<int>，返回两个元素的索引值
 */
vector<int> twoSumA(vector<int>& nums, int target) {
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

