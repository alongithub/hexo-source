---
title: 数据结构与算法
date: 2020-5-28 10:43:40
tags: [
    数据结构,
    算法
]
description: 数据结构与算法整理，概念与练习
toc: true
---

## 数据结构与算法

### 线性表

#### 栈

#### 队列

#### 数组

数组在内存中是连续存放的，数组内的数据，可以通过索引值直接取出得到（只要记录该数组头部的第一个数据位置，然后累加空间位置即可）	

##### 数组与链表的区别

- 链表的长度是可变的，数组的长度是固定的。
- 链表不会根据有序位置存储，进行插入数据元素时，可以用指针来充分利用内存空间。数组的空间是连续的，可能导致空间无法使用。另外如果数组长度发生改变,可能需要重新开辟连续内存。

数组更适合在数据数量确定，即较少甚至不需要使用新增数据、删除数据操作的场景下使用，这样就有效地规避了数组天然的劣势。在数据对位置敏感的场景下，比如需要高频根据索引位置查找数据时，数组就是个很好的选择了。

##### 操作

- 新增：数组中插入元素需要对之后的元素进行后移操作，时间复杂度O(n)
- 删除：数组中删除元素需要对之后的元素进行前移操作，时间复杂度O(n)
- 基于索引的查找：通过索引直接访问，时间复杂度O(1)
- 基于条件查找索引：需要类似链表一样遍历数组，时间复杂度O(n)

#### 字符串

- 空串，含有零个字符的串
- 空格串，只包含空格的串，可以包含一个或多个空格
- 子串、主串（原串），目标串中任意连续字符组成的串称为该串的子串，目标串为子串的主串

##### 实现
- 字符串可以用订场数组来实现
- 也可以使用链式存储实现

##### 操作
- 新增: 字符串中插入字符需要对之后字符进行后移操作，时间复杂度O(n);
- 删除: 删除操作需要对之后字符进行前移，时间复杂度为O(n);
- 查找(字符串匹配), 在符串A（长度n）中查找字符串B（长度m）(n >= m),则A是主串，B是模式串。时间复杂度为O(mn)
  1. 首先从主串的第一个字符开始，判断模式串的第一个字符是否与其相等
  2. 如果不相等,继续判断主串的后续字符是否相等，如果相等判断后续的字符是否依次与子串中的后续字符相等
  3. 如果存在不相等重新回到之前的步骤，判断第一个字符。如果持续相等直到模式串的最后一个字符，则匹配成功

##### 算法案例
###### 找出两个字符串的最大公共子串
假设有且仅有 1 个最大公共子串。比如，输入 a = "13452439"， b = "123456"。由于字符串 "345" 同时在 a 和 b 中出现，且是同时出现在 a 和 b 中的最长子串。因此输出 "345"。

```js
var str1 = 'helloalong';
var str2 = 'wellcomelloalnn';

/**
* @name: 获取 两个字符串公共的最长子串
* @test: test font
* @msg: 
* @param {*} str1
* @param {*} str2
* @return {*}
*/
function getCommenStr(str1, str2) {
	let max_len = 0;
	let max_len_str = '';

	for (let i = 0 ; i < str1.length ; i ++ ) {
		for (let j = 0; j < str2.length ; j ++ ) {
			if (str1[i] === str2[j]) {
				let l = 1;
				let temp_length = 1;
				let temp_length_str = str2[j];
				while(l + i < str1.length && l + j < str2.length) {

					if (str1[i + l] === str2[j + l]) {
						temp_length ++;
						temp_length_str += str1[i + l];
					} else {
						break;
					}
					l ++;
				}

				if (temp_length > max_len) {
					max_len = temp_length;
					max_len_str = temp_length_str;
				}
			}
		}
	}

	console.log(`‘${str1}’与‘${str2}’的最大公共子串为‘${max_len_str}’,长度为${max_len}` );
}

getCommenStr(str1, str2); // ‘helloalong’与‘wellcomelloalnn’的最大公共子串为‘elloal’,长度为6
```

#### 树

- 父节点、子节点：A 结点是 B 结点和 C 结点的上级，则 A 就是 B 和 C 的父结点，B 和 C 是 A 的子结点。
- 兄弟节点: B、C 同时是A的孩子，B、C互为兄弟节点
- 根节点:没有父节点的节点
- 叶子节点: 没有子节点的节点
- 层：根节点为第一层，根节点的孩子为第二层，根节点孩子的孩子为第三层，以此类推
- 深度： 树中节点的最大层数

**二叉树**

- 满二叉树，定义为除了叶子结点外，所有结点都有 2 个子结点。
- 完全二叉树，定义为除了最后一层以外，其他层的结点个数都达到最大，并且最后一层的叶子结点都靠左排列。（完全二叉树的名称是从存储控件的利用率视角来看的。对于一棵完全二叉树而言，仅仅浪费了下标为 0 的存储位置。而如果是一棵非完全二叉树，则会浪费大量的存储空间）

二叉树的存储可以是基于指针的链式存储法，也可以基于数组顺序存储法
- 链式存储法，使用链表，每个节点有三个字段，一个存储数据，另外两个分别存储指向左右子节点的指针
- 照规律把结点存放在数组里，从数组下标为1的位置开始，按树层级从左到右依次存储树中的每个节点，顺序的存储法中，可以发现如果结点 X 的下标为 i，那么 X 的左子结点总是存放在 2 * i 的位置，X 的右子结点总是存放在 2 * i + 1 的位置

**树的操作**

- 删除：O(1)
- 查找：树数据的查找操作和链表一样，都需要遍历每一个数据去判断，所以时间复杂度是 O(n)
- 遍历: 前序遍历、中序遍历、后序遍历。这里的序指的是父结点的遍历顺序，前序就是先遍历父结点，中序就是中间遍历父结点，后序就是最后遍历父结点。遍历的时间复杂度为O(n)

```js
// 先序遍历
function traverse(root) {
	
}

// 中序遍历
function traverse(root) {
	traverse(root.left);
	console.log(root.data);
	traverse(root.right);
}

// 后序遍历
function traverse(root) {
	traverse(root.left);
	traverse(root.right);
	console.log(root.data);
}
```

**二叉查找树**
- 在二叉查找树中的任意一个结点，其左子树中的每个结点的值，都要小于这个结点的值
- 在二叉查找树中的任意一个结点，其右子树中每个结点的值，都要大于这个结点的值
- 在二叉查找树中，会尽可能规避两个结点数值相等的情况
- 对二叉查找树进行中序遍历，就可以输出一个从小到大的有序数据队列

**二叉查找树的操作**

- 查找，时间复杂度O(logn)
  - 首先判断根结点是否等于要查找的数据，如果是就返回
  - 如果根结点大于要查找的数据，就在左子树中递归执行查找动作，直到叶子结点
  - 如果根结点小于要查找的数据，就在右子树中递归执行查找动作，直到叶子结点
- 插入, 时间复杂度O(logn)
  - 从根结点开始，如果要插入的数据比根结点的数据大，且根结点的右子结点不为空，则在根结点的右子树中继续尝试执行插入操作。直到找到为空的子结点执行插入动作
- 删除，二叉查找树的删除比较复杂，可以分为三种情况
	1. 删除的节点是叶子节点，直接删除，将其父节点对应指针指向null即可
	2. 如果删除的节点只有一个子节点，只需要将父节点的指针指向删除节点的子节点
	3. 如果删除节点有两个子节点，有两种删除方法。
		- 第一种，找到要删除节点的左子树中的最大节点，替换要删除的节点。
		- 第二中，找到要删除节点的右子树中的最小节点，替换要删除的节点。


##### 算法案例

###### 实现一个二叉查找树

```js
// 树的节点
class Node {
	constructor (data, leftnode, rightnode) {
		this.data = data;
		this.leftNode = leftnode;
		this.rightNode = rightnode;
	}

	setLeft(node) {
		this.leftNode = node;
	}

	setRight(node) {
		this.rightNode = node;
	}
}

class Tree {
	constructor(array) {
		this.root = new Node();
		this.array = array;
		if (array instanceof Array && array.length > 0) {
			Tree.reduceArrayToTree.call(this, array)
		}

	}

	// 根据输入数组，输出二叉查找树，数组不含重复
	static reduceArrayToTree (array) {
		console.log(this)
		// 以第一个元素为根元素
		let i = 1;
		let root = new Node(array[0], null, null);
		while (i < array.length) {
			this.putNode(root, new Node(array[i]));
			i ++;
		}
		this.root = root;
	}

	// 向树上插入一个节点
	putNode(item, node) {
		if (node.data > item.data) {
			if (item.rightNode) {
				this.putNode(item.rightNode, node);
			} else {
				item.setRight(node)
			}
		} else {
			if (item.leftNode) {
				this.putNode(item.leftNode, node);
			} else {
				item.setLeft(node)
			}
		}
	}

	each(root, outputarray) {
		root.leftNode && this.each(root.leftNode, outputarray);
		outputarray.push(root.data);
		root.rightNode && this.each(root.rightNode, outputarray);
	}

	// 中序遍历二叉树
	middleEach() {
		let a = new Array();
		this.each(this.root, a);
		console.log(a);
	}
}

const tree = new Tree([3, 6, 1, 8, 33, 90]);
tree.middleEach();	
```

###### 字典树查找字符串

实现查找一组字符串中是否出现过某个字符串

目标字符串集合包含字符串个数为n, 平均长度为m

条件，不能直接判断两个字符串是否相等，需要一次对比两个串中的每个位置的字符。

这道题可以借助字符串双重遍历的查找方法来查找，但是，这种算法时间复杂度为O(mn);

可以通过树结构牺牲控件换时间的方法，具体实现思路

- 创建字典树
  - 根结点不包含字符
  - 根结点外每一个结点都只包含一个字符
  - 从根结点到某一叶子结点，路径上经过的字符连接起来，即为集合中的某个字符串
- 对于一个输入字符串，判断它能否在这个树结构中走到叶子结点。如果能，则出现过

```js
class Node {
	constructor(data) {
		this.data = data;
		this.child = [];
	}
	pushChild(node) {
		this.child.push(node);
	}
}

// 字典树类
class StrTree {
	constructor(array) {
		this.root = new Node();
		for (let i = 0; i < array.length; i ++) {
			this.addString(this.root, array[i]);
		}
	}

	// 添加字符串字典
	addString(parent, str) {
		let currentP = parent; // 保存上一个父节点
		for (let i = 0; i < str.length; i ++) {
			// 查找父节点是否存在子节点，且子节点的值为目标字符
			const item = currentP.child.find(l => {
				return l.data === str[i];
			})
			if (item) {
				// 如果存在，作为新的父节点
				currentP = item;
			} else {
				// 不存在添加这个字符的分支
				let current = new Node(str[i])
				currentP.pushChild(current);
				currentP = current;
			}
		}
	}

	find(str) {
		// 保存上一个父节点，一直向下查找，直查找到叶子节点并且查找到最后一个字符
		let parentnode = this.root;
		let i = 0;
		while (i < str.length) {
			let code = str[i++]; // 目标字符
			// 从当前父节点查找是否存在值为code的目标节点
			let node = parentnode.child.find(l => {
				return l.data === code;
			})
			console.log(node)
			if (node) {
				parentnode = node;
				// 如果查找到目标字符串的最后一个字符串，且当前父节点为叶子结点
				if (i === str.length && parentnode.child.length === 0) {
					return true;
				}
			}
		}
		return false;
	}
}

const array = ['hello', 'along', 'along', 'well'];
const tree = new StrTree(array);
console.log(tree.root)
console.log(tree.find('alonge')); // false
console.log(tree.find('along')); // true
```

###### 实现按层级输出树

```js
// 按层级遍历树
// 用数组模拟一个队列
class Inn {
	constructor(){
		this.arr = [];
	}
	pop() {
		if (this.arr.length > 0) {
			// 取出对头
			return this.arr.shift();
		} else {
			return false;
		}
	}
	push(node) {
		this.arr.push(node)
	}
}
let inn = new Inn();
function levelTraverse(node) {
	// 借助栈来实现
	inn.push(node);
	let popnode = inn.pop();
	while(popnode) {
		console.log(popnode.data)
		if (popnode.child.length > 0) {
			popnode.child.forEach(l => {
				inn.push(l);
			});
		}
		popnode = inn.pop();
	}
}

// 模拟一棵树
let root = {
	data: 1,
	child: [
		{data: 2, child: [
			{data: 4, child: []},
			{data: 5, child: [
				{data: 6, child: []},
			]},
		]},
		{data: 3, child: []},
	]
}

levelTraverse(root)
```

#### 哈希表（散列表）

数据数值条件的查找时，之前的数据结构，都需要对全部数据或者部分数据进行遍历；
哈希表的设计采用了函数映射的思想，将记录的存储位置与记录的关键字关联起来。这样的设计方式，能够快速定位到想要查找的记录，而且不需要与表中存在的记录的关键字比较后再来进行查找;

##### 实现思想

在数组中，可以通过索引快速的查找到数据，这是因为，数组实现了 **地址=f(下标)** 的映射关系，当我们去取某个索引的值时，可以在O(1)的时间复杂度内，返回实际内存地址存储的内容

> 哈希表的核心思想也是类似的，只要实现  __地址=f(关键字)__ 的 映射关系，就可以完成数值的快速查找了


- Hash函数: 地址与关键字的映射，其实就是Hash函数，Hash函数设计的好坏会直接影响到对哈希表的操作效率。hash函数可以将所有的关键字计算出对应的地址
- 哈希冲突: 由于关键字的不确定性，两个关键字计算的结果可能指向同一地址。这种情况称为哈希冲突。需要在设计哈希函数时进行规避，但是哈希冲突只能尽可能减少，不能完全避免

随着数据量变多、内存分布越来越多，哈希冲突的可能性也会变大。因此哈希表需要设计合理的哈希函数，并且对冲突有一套处理机制

**解决哈希冲突常见的方法**
- 开放寻址,常见的线性探测法
	如果发现数据地址重复，在重复地址向下查找，知道找到第一个未被使用的地址，插入数据
- 拉链法（链地址法）
	将统一地址的数据存储到一张线性链表中。

**哈希表的优缺点**
优点: 哈希表可以实现快速的插入、删除、查找操作
缺点: 哈希表中的数据是无序的,哈希表中的key不允许重复

##### 算法案例

###### 模拟哈希表的建立和关键字查找流程

将关键字序列 {7, 8, 30, 11, 18, 9, 14} 存储到哈希表中。哈希函数为： H (key) = (key * 3) % 7，处理冲突采用线性探测法

我们借助除留余数法实现Hash函数`H (key) = (key * 3) % 7`，通过一个数组模拟内存

```js

// 哈希表类
class Hash {
	constructor() {
		// 借助一个数组，模拟一段内存,初始长度为7
		this.addr = new Array(7);
	}

	// hash函数
	static H = key => (key * 3) % 7

	set(key, value) {
		let index = Hash.H(key); 
		// 如果内存已被占用，向下查找
		while(this.addr[index]) {
			index ++;
			if (index >= this.addr.length) {
				// 开拓双倍内存，赋值源内存数据
				let before = this.addr;
				this.addr = [...before, ...new Array(before.length)];
			}
		}
		this.addr[index] = {key: key, value: value};
	}

	get(key) {
		let index = Hash.H(key);
		while(this.addr[index]) {
			if (this.addr[index].key === key) {
				return this.addr[index].value
			}
			index ++;
		}
		return undefined;
	}

	// 辅助打印
	getAddlog(key) {
		let value = this.get(key);
		console.log(value);
		return value;
	}
}

// 测试
const hash = new Hash();

const array = [
	{key: 7, value: 'value7'}, 
	{key: 8, value: 'value8'}, 
	{key: 30, value: 'value30'}, 
	{key: 11, value: 'value11'}, 
	{key: 18, value: 'value18'}, 
	{key: 9, value: 'value9'}, 
	{key: 14, value: 'value14'}
]; // 目标数据

array.forEach(l => {
	hash.set(l.key, l.value);
});

console.log(hash.addr);

hash.getAddlog(9);
hash.getAddlog(30);
hash.getAddlog(18);
hash.getAddlog(6);
```


###### two sums， 获取数组中加和等于目标值的两个数

给定一个整数数组 arr 和一个目标值 target，请你在该数组中找出加和等于目标值的那两个整数，并返回它们的在数组中下标

可以假设，原数组中没有重复元素，而且有且只有一组答案。但是，数组中的元素只能使用一次。

这道题可以借助哈希表提高时间效率，这里我直接使用js中的对象作为哈希表使用。

```js
function twosums(array, target) {
	const hash = {};
	for(let i = 0; i < array.length; i ++) {
		const item = array[i];
		if (item < target) {
			if(hash.hasOwnProperty(item)) {
				return [hash[item], i] 
			} else {
				hash[target - item] = i; // 保存互补数值的下标
			}
		}
	}
	return undefined;
}

twosums( [1, 2, 3, 4, 5, 6] , 4); // [0, 2]
```



### 算法

#### 递归

递归的应用非常广泛，很多数据结构和算法的编码实现都要用到递归，例如分治策略、快速排序

> 递归的基本思想就是把规模大的问题转化为规模小的相同的子问题来解决。

递归需要满足的两个条件

- 可以拆解为除了数据规模以外，求解思路完全相同的子问题
- 存在终止条件

##### 案例

###### 汉诺塔问题

汉诺塔问题是源于印度一个古老传说的益智玩具。大梵天创造世界的时候做了三根金刚石柱子，在一根柱子上从下往上按照大小顺序摞着 64 片黄金圆盘。大梵天命令婆罗门把圆盘从下面开始按大小顺序重新摆放在另一根柱子上，并且规定，在小圆盘上不能放大圆盘，在三根柱子之间一次只能移动一个圆盘。

1. 问题分解 将n个圆片从x => z
   - 首先，将 n-1 个从小到大的圆片 x => y, 再将最大的x => z，此时就完成了最大的圆片移动到z
   - 接下来问题就转变成了将 n-1 个从小到大的圆片 y => z, 开始新一轮递归
2. 终止条件， n = 1时, 直接将目标移动到z

```js
// 将n个圆片从 x 移动到 z
function hanio(n, x, y, z) {
	if (n === 1) {
		console.log("移动: " + x + " -> " + z)
		return ;
	}
	hanio(n-1, x, z, y)
	console.log("移动: " + x + " -> " + z)
	hanio(n - 1, y, x, z)
}

hanio(3, 'x', 'y', 'z');

// 移动: x -> z
// 移动: x -> y
// 移动: z -> y
// 移动: x -> z
// 移动: y -> x
// 移动: y -> z
// 移动: x -> z
```

###### 找到第x个斐波那契数

斐波那契数列是：0，1，1，2，3，5，8，13，21，34，55，89，144……。你会发现，这个数列中元素的性质是，某个数等于它前面两个数的和；也就是 a[n+2] = a[n+1] + a[n]。至于起始两个元素，则分别为 0 和 1。在这个数列中的数字，就被称为斐波那契数。

现在的问题是，写一个函数，输入 x，输出斐波那契数列中第 x 位的元素。例如，输入 4，输出 2；输入 9，输出 21。要求：需要用递归的方式来实现

1. 问题分解
   - 获取第x位置的数值，只需要知道 第 x - 1 和 第x- 2 个位置的数值，求和即可
   - 问题转化为 获取 第 x - 1, 和 第 x-2 个位置的数值。进入递归体
2. 终止条件
   - 当x = 1,返回 0， 当x = 2 返回 1

```js
function Fibonacci(x) {
	if (x === 1) {
		return 0;
	} else  if (x === 2) {
		return 1;
	} else {
		return Fibonacci(x - 1) + Fibonacci(x - 2)
	}
};

Fibonacci(4) // 2
Fibonacci(9) // 21
```


#### 分治

分治法的核心思想就是分而治之，将一个难以直接解决的大问题，分割成一些可以直接解决的小问题。如果分割后的问题仍然无法直接解决，那么就继续递归地分割，直到每个小问题都可解

这些子问题具备互相独立、形式相同的特点。这样，我们就可以采用同一种解法，递归地去解决这些子问题。最后，再将每个子问题的解合并，就得到了原问题的解

分治法解决问题需要具备以下特征

- **难度在降低**，难度跟数据的规模成正比
- **问题可分**，原问题可以分解为若干个规模较小的同类型问题
- **解可合并**，利用所有子问题的解，可合并出原问题的解
- **相互独立**，各个子问题之间相互独立，某个子问题的求解不会影响到另一个子问题

分治法在每轮递归上，都包含了分解问题、解决问题和合并结果这 3 个步骤

##### 算法案例

###### 二分查找

二分查找的思路

选择一个标志 i 将集合 L 分为二个子集合，一般可以使用中位数；

判断标志 L(i) 是否能与要查找的值 des 相等，相等则直接返回结果；

如果不相等，需要判断 L(i) 与 des 的大小；

基于判断的结果决定下步是向左查找还是向右查找。如果向某个方向查找的空间为 0，则返回结果未查到；

回到步骤 1。	

在数组 { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 } 中，查找 8 是否出现过

```js
// 从一个有序集合中找到某个元素
function search(arr, target) {
	let low = 0;
	let high = arr.length - 1;
	let middle = 0;
	while(low <= high) {	
		middle = (high + low) >> 1  ;
		const value = arr[middle]
		if (value === target) {
			return true;
		}
		else if (value < target) {
			low = middle + 1;
		}
		else if (value > target) {
			high = middle - 1;
		}
	}
	return false;
}
```

> 1. 二分查找的时间复杂度是 O(logn)，这也是分治法普遍具备的特性。当你面对某个代码题，而且约束了时间复杂度是 O(logn) 或者是 O(nlogn) 时，可以想一下分治法是否可行。
> 2. 二分查找的循环次数并不确定。一般是达到某个条件就跳出循环。因此，编码的时候，多数会采用 while 循环加 break 跳出的代码结构。
> 3. 二分查找处理的原问题必须是有序的。因此，当你在一个有序数据环境中处理问题时，可以考虑分治法。相反，如果原问题中的数据并不是有序的，则使用分治法的可能性就会很低了。

###### 查找第一个大于9的数

在一个有序数组中，查找出第一个大于 9 的数字，假设一定存在。例如，arr = { -1, 3, 3, 7, 10, 14, 14 }; 则返回 10。

```js
function search(arr, target) {
	let low = 0;
	let high = arr.length - 1;
	let middle = 0;
	while(low < high) {
		middle = (low + high) >> 1;
		if (arr[middle] <= target) {
			low = middle + 1;
		} else {
			if (middle === 0) {
				return arr[0];
			} else {
				if (arr[middle - 1] > target) {
					high = middle;
				} else {
					return arr[middle];
				}
			}
		}
	}
}
```

#### 排序
  
- 冒泡排序
  从第一个数据开始，依次比较相邻元素的大小。如果前者大于后者，则进行交换操作，把大的元素往后交换。通过多轮迭代，直到没有交换操作为止
  冒泡排序最好时间复杂度是 O(n)
  冒泡排序最坏时间复杂度会比较惨，是 O(n*n)
  冒泡排序不需要额外的空间，所以空间复杂度是 O(1)。冒泡排序过程中，当元素相同时不做交换，所以冒泡排序是稳定的排序算法

  ```js
  function sort(arr) {

	for (let i = arr.length; i > 1; i --) {
		for (let j = 0; j < i - 1; j ++) {
			if (arr[j] > arr[j + 1]) {
				let t = arr[j];
				arr[j] = arr[j + 1];
				arr[j + 1] = t;
			}
		}
	}

	console.log(arr);
  }
  ```
- 插入排序
  插入排序最好时间复杂度是 O(n)
  插入排序最坏时间复杂度则需要 O(n*n)
  插入排序不需要开辟额外的空间，所以空间复杂度是 O(1)
  插入排序是稳定的排序算法
  
  ```js
  // 从头元素开始依次将头元素插入到前面数组的合适位置
  function sort(arr) {
	for(let i = 1; i< arr.length; i ++) {
		for (let j = i; j > 0; j --) {
			if (arr[j] < arr[j - 1]) {
				let temp = arr[j];
				arr[j] = arr[j - 1];
				arr[j - 1] = temp;
			}
		}
	}

	console.log(arr);
  }
  ```


- 归并排序
  归并排序最好、最坏、平均时间复杂度都是 O(nlogn)
  空间复杂度方面，由于每次合并的操作都需要开辟基于数组的临时内存空间，所以空间复杂度为 O(n)
  归并是稳定的排序算法
  ```js
  // 它首先将数组不断地二分，直到最后每个部分只包含 1 个数据。然后再对每个部分分别进行排序，最后将排序好的相邻的两部分合并在一起，这样整个数组就有序了。
  function sort(arr) {
	if (arr.length === 1) { // 递归出口
		return arr;
	}
	const a = [];
	let middle = (arr.length) >> 1; // 用于当前数组折半
	let left = sort(arr.slice(0, middle));
	let right = sort(arr.slice(middle));
	merge(left, right, a); // 向上合并
	return a;
  }

  function merge(left, right, arr) {
	// 一次比较两个数组的头元素，将较小的元素放入目标数组中，如果其中一个数组元素全部取出，直接将另一个数组剩余元素依次放到目标数组中
	while(left.length && right.length) {
		if (left[0] <= right[0] ) {
			arr.push(left.shift())
		} else {
			arr.push(right.shift());
		}
	}

	while(left.length) {
		arr.push(left.shift())
	}

	while(right.length) {
		arr.push(right.shift())
	}

	return arr;
  } 
  ```

- 快速排序
  它的每轮迭代，会选取数组中任意一个数据作为分区点，将小于它的元素放在它的左侧，大于它的放在它的右侧。再利用分治思想，继续分别对左右两侧进行同样的操作，直至每个区间缩小为 1，则完成排序。
  在快排的最好时间的复杂度下，如果每次选取分区点时，都能选中中位数，把数组等分成两个，那么此时的时间复杂度和归并一样，都是 O(n*logn)。
  而在最坏的时间复杂度下，也就是如果每次分区都选中了最小值或最大值，得到不均等的两组。那么就需要 n 次的分区操作，每次分区平均扫描 n / 2 个元素，此时时间复杂度就退化为 O(n*n) 了。
  快速排序法在大部分情况下，统计上是很难选到极端情况的。因此它平均的时间复杂度是 O(n*logn)。
  快速排序法的空间方面，使用了交换法，因此空间复杂度为 O(1)。
  快排是不稳定的排序算法。
  ```js
  function sort(arr, left, right) {
	let length = arr.length;
	left = typeof left === 'number' ? left : 0;
	right = typeof right === 'number' ? right : length - 1;
	let middleindex;

	if (left < right) {
		middleindex = partition(arr, left, right);
		sort(arr, left, middleindex - 1);
		sort(arr, middleindex + 1, right);
	}

	return arr;

  }

  function partition(arr, left, right) {
	let index = left; // 基准线
	left = index + 1;

	while(left < right) {

		if (index < right) {
			if (arr[index] > arr[right]) {
				swap(arr, index, right)
				index = right;
			} else {
				right --;
			}
		} else if (index > left) {
			if (arr[index] < arr[left]) {
				swap(arr, index, left);
				index = left;
			} else {
				left ++
			}
		}
	}

	
	return index;
  }

  function swap(arr, x, y) {
	arr[y] = arr[x] ^ arr[y];   
	arr[x] = arr[x] ^ arr[y];
	arr[y] = arr[y] ^ arr[x];
  } 
  ```