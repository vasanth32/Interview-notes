# DSA Basics for .NET Full Stack Interview (20-80 Rule)

> **Focus**: Essential concepts that cover 80% of interview questions

---

## 📋 Table of Contents
1. [Time & Space Complexity](#1-time--space-complexity)
2. [Core Data Structures](#2-core-data-structures)
3. [Essential Algorithms](#3-essential-algorithms)
4. [Problem-Solving Patterns](#4-problem-solving-patterns)
5. [Common Interview Questions](#5-common-interview-questions)

---

## 1. Time & Space Complexity

### What is Big O Notation? (Simple Explanation)

**Big O** tells us how fast an algorithm runs as the input size grows.

**Think of it like this:**
- If you have 10 items, how many steps does your code take?
- If you have 100 items, how many steps does it take?
- If you have 1000 items, how many steps does it take?

**Real-world analogy:**
- **O(1)**: Finding a book by its exact shelf number (always 1 step)
- **O(n)**: Finding a book by checking each shelf one by one (10 shelves = 10 steps)
- **O(n²)**: Comparing every book with every other book (10 books = 100 comparisons)

---

### O(1) - Constant Time ⚡ (FASTEST)

**Meaning:** No matter how big the input, it always takes the same amount of time.

**Example:**
```csharp
// Get the first element - always 1 step, regardless of array size
int GetFirst(int[] arr) => arr[0];

// Examples:
int[] small = {1, 2, 3};           // Takes 1 step
int[] medium = new int[1000];      // Takes 1 step
int[] huge = new int[1000000];     // Takes 1 step - SAME TIME!
```

**Step-by-step:**
1. Array has 10 elements → Access arr[0] → 1 operation
2. Array has 1,000,000 elements → Access arr[0] → 1 operation
3. **Time doesn't change!**

**Other O(1) operations:**
```csharp
// Adding to end of List (usually)
list.Add(5);

// Dictionary lookup
dict["key"];

// Stack/Queue operations
stack.Push(1);
queue.Dequeue();
```

---

### O(n) - Linear Time 📈

**Meaning:** Time increases proportionally with input size. If input doubles, time doubles.

**Example:**
```csharp
// Find maximum number - must check every element
int FindMax(int[] arr)
{
    int max = arr[0];                    // 1 operation
    
    // This loop runs 'n' times (n = arr.Length)
    for (int i = 1; i < arr.Length; i++)  // n-1 iterations
    {
        if (arr[i] > max)                 // 1 operation per iteration
            max = arr[i];                  // Sometimes 1 more operation
    }
    return max;
}
```

**Step-by-step breakdown:**
```
Array: [5, 2, 8, 1, 9]  (n = 5)

Step 1: max = 5, check arr[1] = 2  → max stays 5
Step 2: max = 5, check arr[2] = 8  → max becomes 8
Step 3: max = 8, check arr[3] = 1  → max stays 8
Step 4: max = 8, check arr[4] = 9  → max becomes 9

Total: 4 comparisons (n-1 operations)
```

**Time comparison:**
- Array with 10 elements → ~10 operations
- Array with 100 elements → ~100 operations
- Array with 1000 elements → ~1000 operations
- **Time grows linearly!**

**Visual representation:**
```
n=1:  █
n=5:  █████
n=10: ██████████
```

**Other O(n) operations:**
```csharp
// Searching for an element
bool Contains(int[] arr, int target)
{
    foreach (int num in arr)  // Must check all n elements
        if (num == target) return true;
    return false;
}

// Summing all elements
int Sum(int[] arr)
{
    int total = 0;
    foreach (int num in arr)  // Must visit all n elements
        total += num;
    return total;
}
```

---

### O(n²) - Quadratic Time 🐌 (SLOW)

**Meaning:** Time grows by the square of input size. If input doubles, time quadruples!

**Example:**
```csharp
// Print all pairs - nested loops
void PrintPairs(int[] arr)
{
    // Outer loop: runs n times
    for (int i = 0; i < arr.Length; i++)
    {
        // Inner loop: runs (n-1), (n-2), ... times
        for (int j = i + 1; j < arr.Length; j++)
        {
            Console.WriteLine($"{arr[i]}, {arr[j]}");
        }
    }
}
```

**Step-by-step breakdown:**
```
Array: [1, 2, 3]  (n = 3)

i=0: Compare with j=1, j=2  → (1,2), (1,3)  = 2 pairs
i=1: Compare with j=2        → (2,3)         = 1 pair
i=2: No comparisons          →                = 0 pairs

Total: 2 + 1 = 3 pairs = n(n-1)/2 ≈ n²/2 operations
```

**Time comparison:**
- Array with 10 elements → ~45 operations (10×9/2)
- Array with 100 elements → ~4,950 operations (100×99/2)
- Array with 1000 elements → ~499,500 operations (1000×999/2)
- **Time grows quadratically!**

**Visual representation:**
```
n=1:  █
n=5:  ████████████████████████ (25)
n=10: ████████████████████████████████████████████████████████████████████████ (100)
```

**When you see nested loops, think O(n²):**
```csharp
// Bubble Sort - O(n²)
for (int i = 0; i < n; i++)
    for (int j = 0; j < n - i - 1; j++)
        if (arr[j] > arr[j + 1])
            Swap(arr, j, j + 1);
```

---

### O(log n) - Logarithmic Time 🔍 (VERY FAST)

**Meaning:** Time grows slowly. Each step eliminates half of the remaining work.

**Real-world analogy:** Like finding a word in a dictionary:
- Open to middle → eliminates half
- Check if word is before/after → eliminate half again
- Repeat until found

**Example:**
```csharp
// Binary Search - array MUST be sorted
int BinarySearch(int[] arr, int target)
{
    int left = 0;
    int right = arr.Length - 1;
    
    while (left <= right)
    {
        int mid = left + (right - left) / 2;  // Find middle
        
        if (arr[mid] == target) 
            return mid;                        // Found!
        
        if (arr[mid] < target) 
            left = mid + 1;                    // Search right half
        else 
            right = mid - 1;                   // Search left half
    }
    return -1;  // Not found
}
```

**Step-by-step breakdown:**
```
Sorted Array: [1, 3, 5, 7, 9, 11, 13, 15]  (n = 8)
Looking for: 7

Step 1: Check middle (index 3) = 7 → Found! ✅
        Only took 1 step!

Looking for: 3

Step 1: Check middle (index 3) = 7 → Too big, search left [1,3,5]
Step 2: Check middle (index 1) = 3 → Found! ✅
        Took 2 steps!

Looking for: 13

Step 1: Check middle (index 3) = 7 → Too small, search right [9,11,13,15]
Step 2: Check middle (index 5) = 11 → Too small, search right [13,15]
Step 3: Check middle (index 6) = 13 → Found! ✅
        Took 3 steps!
```

**Time comparison:**
- Array with 8 elements → ~3 steps (log₂8 = 3)
- Array with 16 elements → ~4 steps (log₂16 = 4)
- Array with 32 elements → ~5 steps (log₂32 = 5)
- Array with 1,000,000 elements → ~20 steps (log₂1,000,000 ≈ 20)
- **Time grows very slowly!**

**Visual representation:**
```
n=8:     ███
n=16:    ████
n=32:    █████
n=1024:  ████████
```

**Key point:** Binary search only works on **sorted** arrays!

---

### O(n log n) - Linearithmic Time

**Meaning:** Between O(n) and O(n²). Common in efficient sorting algorithms.

**Example:** Merge Sort, Quick Sort (average case)

**Time comparison:**
- n=10 → ~33 operations
- n=100 → ~664 operations
- n=1000 → ~9,966 operations

**Why it happens:** 
- Divide array in half: log n levels
- At each level, process n elements
- Total: n × log n

---

### Complexity Comparison Chart

```
Input Size (n) | O(1) | O(log n) | O(n) | O(n log n) | O(n²)   | O(2ⁿ)
---------------|------|----------|------|------------|---------|-------
10             | 1    | 3        | 10   | 33         | 100     | 1024
100            | 1    | 7        | 100  | 664        | 10,000  | 1.27×10³⁰
1,000          | 1    | 10       | 1K   | 9,966      | 1M      | (huge!)
1,000,000      | 1    | 20       | 1M   | 20M        | 1T      | (impossible!)
```

**Order from fastest to slowest:**
```
O(1) < O(log n) < O(n) < O(n log n) < O(n²) < O(2ⁿ)
```

---

### How to Identify Complexity (Quick Guide)

**Count the loops:**

```csharp
// No loop = O(1)
int GetFirst(int[] arr) => arr[0];

// Single loop = O(n)
for (int i = 0; i < n; i++) { }

// Nested loops = O(n²)
for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j++) { }

// Loop that halves each time = O(log n)
while (n > 0) { n = n / 2; }
```

**Common patterns:**
- Array access: `arr[i]` → O(1)
- Dictionary lookup: `dict[key]` → O(1) average
- Single loop: → O(n)
- Nested loops: → O(n²)
- Binary search: → O(log n)
- Sorting: → O(n log n)

---

### Space Complexity (Quick Note)

**Space complexity** is similar but measures **memory** instead of time.

```csharp
// O(1) space - uses constant memory
int Sum(int[] arr)
{
    int total = 0;  // Only 1 variable, regardless of array size
    foreach (int num in arr)
        total += num;
    return total;
}

// O(n) space - uses memory proportional to input
int[] CopyArray(int[] arr)
{
    int[] copy = new int[arr.Length];  // New array of size n
    Array.Copy(arr, copy, arr.Length);
    return copy;
}
```

**For interviews:** Usually focus on **time complexity** first, then mention space if asked.

---

## 2. Core Data Structures

### 2.1 Arrays & Lists

```csharp
// Array - Fixed size, O(1) access
int[] arr = new int[5];
arr[0] = 10; // O(1)

// List<T> - Dynamic size, O(1) amortized access
List<int> list = new List<int>();
list.Add(10);      // O(1) amortized
list.Insert(0, 5); // O(n) - shifts elements
list[0] = 20;      // O(1)
```

**Key Points:**
- Arrays: Fixed size, contiguous memory
- Lists: Dynamic, uses array internally, doubles capacity when full

### 2.2 Dictionary/HashMap

```csharp
// Dictionary<TKey, TValue> - O(1) average, O(n) worst case
Dictionary<string, int> dict = new Dictionary<string, int>();
dict["key"] = 100;        // O(1) average
bool exists = dict.ContainsKey("key"); // O(1) average
int value = dict["key"];  // O(1) average

// Common use: Frequency counting
Dictionary<int, int> frequency = new Dictionary<int, int>();
foreach (var num in nums)
    frequency[num] = frequency.GetValueOrDefault(num, 0) + 1;
```

**Key Points:**
- Hash-based, average O(1) operations
- Perfect for lookups, frequency counting, caching

### 2.3 Stack & Queue

```csharp
// Stack<T> - LIFO (Last In First Out)
Stack<int> stack = new Stack<int>();
stack.Push(1);     // O(1)
stack.Push(2);
int top = stack.Peek();  // O(1) - returns 2
int popped = stack.Pop(); // O(1) - returns 2

// Queue<T> - FIFO (First In First Out)
Queue<int> queue = new Queue<int>();
queue.Enqueue(1);  // O(1)
queue.Enqueue(2);
int front = queue.Peek();    // O(1) - returns 1
int dequeued = queue.Dequeue(); // O(1) - returns 1
```

**Common Uses:**
- Stack: Parentheses matching, DFS, expression evaluation
- Queue: BFS, task scheduling, level-order traversal

### 2.4 Trees

```csharp
// Binary Tree Node
public class TreeNode
{
    public int val;
    public TreeNode left;
    public TreeNode right;
    public TreeNode(int val = 0, TreeNode left = null, TreeNode right = null)
    {
        this.val = val;
        this.left = left;
        this.right = right;
    }
}

// Tree Traversal - O(n) time, O(h) space (h = height)
// Inorder: Left -> Root -> Right
void Inorder(TreeNode root)
{
    if (root == null) return;
    Inorder(root.left);
    Console.WriteLine(root.val);
    Inorder(root.right);
}

// Preorder: Root -> Left -> Right
void Preorder(TreeNode root)
{
    if (root == null) return;
    Console.WriteLine(root.val);
    Preorder(root.left);
    Preorder(root.right);
}

// Postorder: Left -> Right -> Root
void Postorder(TreeNode root)
{
    if (root == null) return;
    Postorder(root.left);
    Postorder(root.right);
    Console.WriteLine(root.val);
}

// Level Order (BFS) - O(n) time, O(n) space
List<List<int>> LevelOrder(TreeNode root)
{
    var result = new List<List<int>>();
    if (root == null) return result;
    
    var queue = new Queue<TreeNode>();
    queue.Enqueue(root);
    
    while (queue.Count > 0)
    {
        int levelSize = queue.Count;
        var level = new List<int>();
        
        for (int i = 0; i < levelSize; i++)
        {
            var node = queue.Dequeue();
            level.Add(node.val);
            if (node.left != null) queue.Enqueue(node.left);
            if (node.right != null) queue.Enqueue(node.right);
        }
        result.Add(level);
    }
    return result;
}
```

**Key Points:**
- Binary Tree: Each node has at most 2 children
- Binary Search Tree (BST): Left < Root < Right
- Balanced BST: O(log n) search, insert, delete

---

## 3. Essential Algorithms

### 3.1 Sorting Algorithms

```csharp
// Quick Sort - O(n log n) average, O(n²) worst case
void QuickSort(int[] arr, int low, int high)
{
    if (low < high)
    {
        int pi = Partition(arr, low, high);
        QuickSort(arr, low, pi - 1);
        QuickSort(arr, pi + 1, high);
    }
}

int Partition(int[] arr, int low, int high)
{
    int pivot = arr[high];
    int i = low - 1;
    
    for (int j = low; j < high; j++)
    {
        if (arr[j] < pivot)
        {
            i++;
            Swap(arr, i, j);
        }
    }
    Swap(arr, i + 1, high);
    return i + 1;
}

void Swap(int[] arr, int i, int j)
{
    int temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
}

// Merge Sort - O(n log n) always, O(n) space
void MergeSort(int[] arr, int left, int right)
{
    if (left < right)
    {
        int mid = left + (right - left) / 2;
        MergeSort(arr, left, mid);
        MergeSort(arr, mid + 1, right);
        Merge(arr, left, mid, right);
    }
}

void Merge(int[] arr, int left, int mid, int right)
{
    int n1 = mid - left + 1;
    int n2 = right - mid;
    
    int[] leftArr = new int[n1];
    int[] rightArr = new int[n2];
    
    Array.Copy(arr, left, leftArr, 0, n1);
    Array.Copy(arr, mid + 1, rightArr, 0, n2);
    
    int i = 0, j = 0, k = left;
    while (i < n1 && j < n2)
    {
        if (leftArr[i] <= rightArr[j])
            arr[k++] = leftArr[i++];
        else
            arr[k++] = rightArr[j++];
    }
    
    while (i < n1) arr[k++] = leftArr[i++];
    while (j < n2) arr[k++] = rightArr[j++];
}

// In .NET, use built-in: Array.Sort() or LINQ OrderBy()
int[] sorted = arr.OrderBy(x => x).ToArray(); // O(n log n)
```

**Key Points:**
- Quick Sort: Fast average case, in-place
- Merge Sort: Stable, predictable O(n log n)
- For interviews: Know one well, mention built-in for production

### 3.2 Searching Algorithms

```csharp
// Linear Search - O(n)
int LinearSearch(int[] arr, int target)
{
    for (int i = 0; i < arr.Length; i++)
        if (arr[i] == target) return i;
    return -1;
}

// Binary Search - O(log n) - Array must be sorted
int BinarySearch(int[] arr, int target)
{
    int left = 0, right = arr.Length - 1;
    
    while (left <= right)
    {
        int mid = left + (right - left) / 2; // Prevents overflow
        
        if (arr[mid] == target) return mid;
        if (arr[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}

// Binary Search in .NET
int index = Array.BinarySearch(arr, target);
```

### 3.3 Recursion

```csharp
// Fibonacci - O(2ⁿ) naive, O(n) with memoization
int Fibonacci(int n)
{
    if (n <= 1) return n;
    return Fibonacci(n - 1) + Fibonacci(n - 2);
}

// Memoized Fibonacci - O(n) time, O(n) space
Dictionary<int, int> memo = new Dictionary<int, int>();
int FibonacciMemo(int n)
{
    if (n <= 1) return n;
    if (memo.ContainsKey(n)) return memo[n];
    
    memo[n] = FibonacciMemo(n - 1) + FibonacciMemo(n - 2);
    return memo[n];
}

// Factorial
int Factorial(int n)
{
    if (n <= 1) return 1;
    return n * Factorial(n - 1);
}
```

**Key Points:**
- Base case: When to stop
- Recursive case: How to break down problem
- Memoization: Cache results to avoid recomputation

---

## 4. Problem-Solving Patterns

### 4.1 Two Pointers

```csharp
// Find pair with sum in sorted array - O(n)
bool TwoSum(int[] arr, int target)
{
    int left = 0, right = arr.Length - 1;
    
    while (left < right)
    {
        int sum = arr[left] + arr[right];
        if (sum == target) return true;
        if (sum < target) left++;
        else right--;
    }
    return false;
}

// Remove duplicates from sorted array - O(n)
int RemoveDuplicates(int[] nums)
{
    if (nums.Length == 0) return 0;
    
    int slow = 0;
    for (int fast = 1; fast < nums.Length; fast++)
    {
        if (nums[fast] != nums[slow])
        {
            slow++;
            nums[slow] = nums[fast];
        }
    }
    return slow + 1;
}
```

### 4.2 Sliding Window

```csharp
// Maximum sum of subarray of size k - O(n)
int MaxSumSubarray(int[] arr, int k)
{
    int maxSum = 0;
    int windowSum = 0;
    
    // Calculate sum of first window
    for (int i = 0; i < k; i++)
        windowSum += arr[i];
    
    maxSum = windowSum;
    
    // Slide the window
    for (int i = k; i < arr.Length; i++)
    {
        windowSum = windowSum - arr[i - k] + arr[i];
        maxSum = Math.Max(maxSum, windowSum);
    }
    
    return maxSum;
}

// Longest substring without repeating characters - O(n)
int LengthOfLongestSubstring(string s)
{
    var charSet = new HashSet<char>();
    int left = 0, maxLength = 0;
    
    for (int right = 0; right < s.Length; right++)
    {
        while (charSet.Contains(s[right]))
        {
            charSet.Remove(s[left]);
            left++;
        }
        charSet.Add(s[right]);
        maxLength = Math.Max(maxLength, right - left + 1);
    }
    
    return maxLength;
}
```

### 4.3 Hash Map Pattern

```csharp
// Two Sum - O(n)
int[] TwoSum(int[] nums, int target)
{
    var map = new Dictionary<int, int>();
    
    for (int i = 0; i < nums.Length; i++)
    {
        int complement = target - nums[i];
        if (map.ContainsKey(complement))
            return new int[] { map[complement], i };
        
        map[nums[i]] = i;
    }
    return new int[0];
}

// Group Anagrams - O(n * k log k) where k is avg string length
List<List<string>> GroupAnagrams(string[] strs)
{
    var groups = new Dictionary<string, List<string>>();
    
    foreach (var str in strs)
    {
        char[] chars = str.ToCharArray();
        Array.Sort(chars);
        string key = new string(chars);
        
        if (!groups.ContainsKey(key))
            groups[key] = new List<string>();
        
        groups[key].Add(str);
    }
    
    return groups.Values.ToList();
}
```

### 4.4 Fast & Slow Pointers (Floyd's Cycle Detection)

```csharp
// Detect cycle in linked list - O(n)
public class ListNode
{
    public int val;
    public ListNode next;
    public ListNode(int val = 0, ListNode next = null)
    {
        this.val = val;
        this.next = next;
    }
}

bool HasCycle(ListNode head)
{
    if (head == null) return false;
    
    ListNode slow = head;
    ListNode fast = head;
    
    while (fast != null && fast.next != null)
    {
        slow = slow.next;
        fast = fast.next.next;
        
        if (slow == fast) return true;
    }
    
    return false;
}

// Find middle of linked list
ListNode FindMiddle(ListNode head)
{
    ListNode slow = head;
    ListNode fast = head;
    
    while (fast != null && fast.next != null)
    {
        slow = slow.next;
        fast = fast.next.next;
    }
    
    return slow;
}
```

### 4.5 BFS & DFS

```csharp
// BFS - Level order traversal (already shown in Trees section)
// Uses Queue, finds shortest path in unweighted graph

// DFS - Preorder/Inorder/Postorder (already shown in Trees section)
// Uses Stack (or recursion), explores deep before wide

// DFS for Graph
void DFS(Dictionary<int, List<int>> graph, int node, HashSet<int> visited)
{
    visited.Add(node);
    Console.WriteLine(node);
    
    foreach (var neighbor in graph[node])
    {
        if (!visited.Contains(neighbor))
            DFS(graph, neighbor, visited);
    }
}
```

---

## 5. Common Interview Questions

### Easy Level

**1. Reverse a String**
```csharp
string Reverse(string s)
{
    char[] chars = s.ToCharArray();
    Array.Reverse(chars);
    return new string(chars);
}
// Or: return new string(s.Reverse().ToArray());
```

**2. Check if Palindrome**
```csharp
bool IsPalindrome(string s)
{
    int left = 0, right = s.Length - 1;
    while (left < right)
    {
        if (s[left] != s[right]) return false;
        left++;
        right--;
    }
    return true;
}
```

**3. Find Maximum in Array**
```csharp
int FindMax(int[] arr) => arr.Max(); // O(n)
// Or manually: arr.Aggregate((a, b) => a > b ? a : b);
```

**4. Valid Parentheses**
```csharp
bool IsValid(string s)
{
    var stack = new Stack<char>();
    var pairs = new Dictionary<char, char>
    {
        { ')', '(' },
        { '}', '{' },
        { ']', '[' }
    };
    
    foreach (char c in s)
    {
        if (pairs.ContainsValue(c))
            stack.Push(c);
        else if (pairs.ContainsKey(c))
        {
            if (stack.Count == 0 || stack.Pop() != pairs[c])
                return false;
        }
    }
    
    return stack.Count == 0;
}
```

### Medium Level

**5. Longest Substring Without Repeating Characters** (Sliding Window - shown above)

**6. Container With Most Water**
```csharp
int MaxArea(int[] height)
{
    int left = 0, right = height.Length - 1;
    int maxArea = 0;
    
    while (left < right)
    {
        int area = Math.Min(height[left], height[right]) * (right - left);
        maxArea = Math.Max(maxArea, area);
        
        if (height[left] < height[right]) left++;
        else right--;
    }
    
    return maxArea;
}
```

**7. Merge Two Sorted Lists**
```csharp
ListNode MergeTwoLists(ListNode list1, ListNode list2)
{
    var dummy = new ListNode();
    var current = dummy;
    
    while (list1 != null && list2 != null)
    {
        if (list1.val < list2.val)
        {
            current.next = list1;
            list1 = list1.next;
        }
        else
        {
            current.next = list2;
            list2 = list2.next;
        }
        current = current.next;
    }
    
    current.next = list1 ?? list2;
    return dummy.next;
}
```

**8. Best Time to Buy and Sell Stock**
```csharp
int MaxProfit(int[] prices)
{
    int minPrice = int.MaxValue;
    int maxProfit = 0;
    
    foreach (int price in prices)
    {
        minPrice = Math.Min(minPrice, price);
        maxProfit = Math.Max(maxProfit, price - minPrice);
    }
    
    return maxProfit;
}
```

### Hard Level (Less Common for 8 YOE)

**9. Merge K Sorted Lists** (Priority Queue)
```csharp
ListNode MergeKLists(ListNode[] lists)
{
    var pq = new PriorityQueue<ListNode, int>();
    
    foreach (var list in lists)
        if (list != null)
            pq.Enqueue(list, list.val);
    
    var dummy = new ListNode();
    var current = dummy;
    
    while (pq.Count > 0)
    {
        var node = pq.Dequeue();
        current.next = node;
        current = current.next;
        
        if (node.next != null)
            pq.Enqueue(node.next, node.next.val);
    }
    
    return dummy.next;
}
```

---

## 🎯 Quick Reference Cheat Sheet

### Time Complexities
| Operation | Array | List | Dictionary | Stack/Queue |
|-----------|-------|------|------------|--------------|
| Access    | O(1)  | O(1) | O(1) avg   | N/A          |
| Search    | O(n)  | O(n) | O(1) avg   | O(n)         |
| Insert    | O(n)  | O(1)*| O(1) avg   | O(1)         |
| Delete    | O(n)  | O(n) | O(1) avg   | O(1)         |

*Amortized for List.Add()

### Space Complexities
- Recursion: O(h) where h = height (call stack)
- BFS: O(w) where w = max width
- DFS: O(h) where h = max depth

### Pattern Selection Guide
- **Two Pointers**: Sorted array, palindrome, pair sum
- **Sliding Window**: Subarray/substring problems
- **HashMap**: Frequency, grouping, caching
- **Stack**: Parentheses, parsing, DFS
- **Queue**: BFS, level-order
- **Fast/Slow Pointers**: Cycle detection, middle element

---

## 📚 Practice Strategy

1. **Focus Areas** (80% of questions):
   - Arrays & Strings
   - Hash Maps
   - Two Pointers
   - Sliding Window
   - Basic Tree Traversal

2. **Practice Platforms**:
   - LeetCode (Easy & Medium)
   - HackerRank
   - CodeSignal

3. **Interview Tips**:
   - Clarify requirements first
   - Think out loud
   - Start with brute force, then optimize
   - Consider edge cases
   - Test with examples

---

## 🔥 Most Important Concepts Summary

1. **Big O Notation** - Understand time/space complexity
2. **Hash Maps** - Most versatile data structure
3. **Two Pointers** - Very common pattern
4. **Sliding Window** - Subarray/substring problems
5. **Tree Traversal** - BFS & DFS
6. **Recursion** - Base case + recursive case
7. **Sorting** - Know one algorithm well
8. **Binary Search** - Works on sorted arrays

---

**Remember**: For 8 YOE interviews, focus on problem-solving approach and communication. You don't need to know every algorithm, but you should be able to reason through problems and implement solutions efficiently.

