---
title: leetcode
date: 2021-01-05 15:16:30
tags: 算法
toc: true
---


### leetCode

#### 二进制中1的个数
输入一个整数（以二进制串形式），输出该数二进制表示中 1 的个数。例如，把 9 表示成二进制是 1001，有 2 位是 1。因此，如果输入 9，则该函数输出 2。

```js
const n = 0b00000000000000000000000000001011;


var hammingWeight = function (n) {
	let bits = 0;
	let mask = 1;

	for(let i = 0; i < 32; i ++) {
		if ( (mask & n) !== 0) {
			bits ++;
		}
		mask <<= 1;
	}

	return bits;
}


console.log(hammingWeight(n))
```

#### 环形链表

给定一个链表，判断链表中是否有环。

如果链表中有某个节点，可以通过连续跟踪 next 指针再次到达，则链表中存在环。 为了表示给定链表中的环，我们使用整数 pos 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 pos 是 -1，则在该链表中没有环。注意：pos 不作为参数进行传递，仅仅是为了标识链表的实际情况。

如果链表中存在环，则返回 true 。 否则，返回 false 。

```javascript
/**
 * Definition for singly-linked list.
 * function ListNode(val) {
 *     this.val = val;
 *     this.next = null;
 * }
 */

/**
 * @param {ListNode} head
 * @return {boolean}
 */
var hasCycle = function(head) {
	if (head === null) {return false}
	let fast = head.next;
	let low = head;
	while(fast !== null && fast.next !== null) {
		if (fast === low) {
			return true;
		}

		fast = fast.next.next;
		low = low.next;
	}
	return false;
};
```

#### 环形链表 II

leetcode 142 中等

给定一个链表，返回链表开始入环的第一个节点。 如果链表无环，则返回 null。

说明：不允许修改给定的链表。

你是否可以使用 O(1) 空间解决此题？

```javascript
/**
 * Definition for singly-linked list.
 * function ListNode(val) {
 *     this.val = val;
 *     this.next = null;
 * }
 */

/**
 * @param {ListNode} head
 * @return {ListNode}
 */
var detectCycle = function(head) {
	if (head === null || head.next === null) return null;
	let fast = head.next;
	let low = head;
	while(fast !== null && fast.next !== null) {
		if (fast === low) {
			console.log(low.value)
			// 当快慢指针重合时，此时定义一个新的指针pre指向第一个节点，low指针同时向后移动，pre和low重合点即入环节点
			let pre = head;
			low = low.next;
			while(low !== pre) {
				low = low.next;
				pre = pre.next;
			}
			return pre;

		}

		fast = fast.next.next;
		low = low.next;
	}
	return null;
};
```

