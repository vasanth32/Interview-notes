# JavaScript Basics - Interview Questions & Answers

## How to Use This File

This file is for JavaScript interview preparation. Each topic starts with a simple explanation, then adds examples and deeper interview points.

### Study Order

1. Understand the answer in plain English.
2. Read the code example slowly.
3. Practice explaining the answer without looking.
4. Learn the deeper points for follow-up interview questions.
5. Type the small program at the end by yourself.

---

## 1. What is JavaScript?

### Answer

JavaScript is a programming language mainly used to make web pages interactive. It can run in the browser and also on the server using Node.js.

Beginner-friendly meaning: HTML gives structure, CSS gives design, and JavaScript gives behavior.

### Example

```javascript
console.log("Hello JavaScript");
```

### Where JavaScript Is Used

- Browser applications
- Backend APIs using Node.js
- Mobile apps using frameworks like React Native
- Desktop apps using Electron
- Automation scripts

### Interview Deep Point

JavaScript is a high-level, interpreted, dynamically typed, single-threaded language with asynchronous capabilities.

Meaning:

- High-level: easier to write than low-level machine code.
- Interpreted: usually executed directly by a JavaScript engine.
- Dynamically typed: variable types are decided at runtime.
- Single-threaded: one main execution thread handles JavaScript code.
- Asynchronous: can handle tasks like API calls without blocking the main thread.

---

## 2. What are variables in JavaScript?

### Answer

A variable is a named container used to store data.

JavaScript has three main ways to declare variables:

- `var`
- `let`
- `const`

### Example

```javascript
let name = "Ravi";
const age = 25;
var city = "Chennai";

console.log(name);
console.log(age);
console.log(city);
```

### Difference Between `var`, `let`, and `const`

| Keyword | Reassign Allowed | Scope          | Recommended Use            |
| ------- | ---------------- | -------------- | -------------------------- |
| `var`   | Yes              | Function scope | Avoid in modern JavaScript |
| `let`   | Yes              | Block scope    | Use when value changes     |
| `const` | No               | Block scope    | Use by default             |

### Interview Deep Point

Prefer `const` first. Use `let` only when the value needs to change. Avoid `var` because it can create confusing scope and hoisting behavior.

```javascript
const country = "India";
let score = 10;

score = 20; // allowed
country = "USA"; // error
```

---

## 3. What are data types in JavaScript?

### Answer

Data types define the kind of value stored in a variable.

JavaScript has primitive and non-primitive data types.

### Primitive Data Types

- `string`
- `number`
- `boolean`
- `undefined`
- `null`
- `bigint`
- `symbol`

### Non-Primitive Data Types

- `object`
- `array`
- `function`

### Example

```javascript
const name = "Anu"; // string
const age = 30; // number
const isActive = true; // boolean
let address; // undefined
const salary = null; // null
const user = { id: 1 }; // object
const numbers = [1, 2, 3]; // array

console.log(typeof name); // string
console.log(typeof age); // number
console.log(typeof isActive); // boolean
console.log(typeof address); // undefined
console.log(typeof user); // object
```

### Interview Deep Point

`typeof null` returns `object`. This is a long-standing JavaScript behavior.

```javascript
console.log(typeof null); // object
```

In interviews, explain that `null` means intentional empty value, while `undefined` means a variable has been declared but no value has been assigned.

---

## 4. What is the difference between `null` and `undefined`?

### Answer

`undefined` means JavaScript has not received a value yet. `null` means the developer intentionally assigned an empty value.

### Example

```javascript
let userName;
let selectedUser = null;

console.log(userName); // undefined
console.log(selectedUser); // null
```

### Interview Deep Point

Use `null` when you want to clearly say "there is no value now".

```javascript
let loggedInUser = null;

if (loggedInUser === null) {
  console.log("No user is logged in");
}
```

---

## 5. What is the difference between `==` and `===`?

### Answer

`==` compares values after type conversion. `===` compares both value and type.

Beginner-friendly meaning: `===` is stricter and safer.

### Example

```javascript
console.log(5 == "5"); // true
console.log(5 === "5"); // false
```

### Interview Deep Point

In real projects, prefer `===` because it avoids unexpected type conversion bugs.

```javascript
const userId = 10;

if (userId === "10") {
  console.log("Matched");
} else {
  console.log("Not matched");
}
```

Output:

```text
Not matched
```

---

## 6. What is type coercion?

### Answer

Type coercion means JavaScript automatically converts one data type into another during an operation.

### Example

```javascript
console.log("5" + 2); // "52"
console.log("5" - 2); // 3
```

### Explanation

In `"5" + 2`, JavaScript treats `2` as a string and joins both values.

In `"5" - 2`, JavaScript treats `"5"` as a number and subtracts.

### Interview Deep Point

Type coercion can be useful, but it can also create confusing bugs. Use explicit conversion when clarity matters.

```javascript
const price = "100";
const quantity = 2;

const total = Number(price) * quantity;

console.log(total); // 200
```

---

## 7. What are functions in JavaScript?

### Answer

A function is a reusable block of code that performs a task.

### Function Declaration

```javascript
function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}

console.log(add(10, 20)); // 30
```

### Function Expression

```javascript
const multiply = function (firstNumber, secondNumber) {
  return firstNumber * secondNumber;
};

console.log(multiply(5, 4)); // 20
```

### Arrow Function

```javascript
const subtract = (firstNumber, secondNumber) => firstNumber - secondNumber;

console.log(subtract(20, 5)); // 15
```

### Interview Deep Point

Function declarations are hoisted, so they can be called before they are defined. Function expressions and arrow functions assigned to `const` or `let` cannot be used before initialization.

```javascript
sayHello();

function sayHello() {
  console.log("Hello");
}
```

This works because function declarations are hoisted.

---

## 8. What is scope in JavaScript?

### Answer

Scope decides where a variable can be accessed.

Main types of scope:

- Global scope
- Function scope
- Block scope

### Example

```javascript
const globalMessage = "I am global";

function showMessage() {
  const functionMessage = "I am inside function";

  if (true) {
    const blockMessage = "I am inside block";
    console.log(blockMessage);
  }

  console.log(functionMessage);
}

showMessage();
console.log(globalMessage);
```

### Interview Deep Point

`let` and `const` are block-scoped. `var` is function-scoped.

```javascript
if (true) {
  var oldValue = "var value";
  let newValue = "let value";
}

console.log(oldValue); // works
console.log(newValue); // error
```

---

## 9. What is hoisting?

### Answer

Hoisting means JavaScript moves declarations to the top of their scope during execution preparation.

### Example With `var`

```javascript
console.log(name); // undefined
var name = "Kumar";
```

JavaScript understands it like this:

```javascript
var name;
console.log(name);
name = "Kumar";
```

### Example With `let` and `const`

```javascript
console.log(age); // error
let age = 25;
```

### Interview Deep Point

`let` and `const` are also hoisted, but they stay in the temporal dead zone until the line where they are declared is executed.

Simple interview answer: JavaScript knows about `let` and `const` before execution, but you cannot use them before declaration.

---

## 10. What are arrays in JavaScript?

### Answer

An array stores multiple values in a single variable.

### Example

```javascript
const fruits = ["apple", "banana", "orange"];

console.log(fruits[0]); // apple
console.log(fruits.length); // 3
```

### Common Array Methods

```javascript
const numbers = [10, 20, 30];

numbers.push(40);
console.log(numbers); // [10, 20, 30, 40]

numbers.pop();
console.log(numbers); // [10, 20, 30]
```

### Interview Deep Point

Arrays are objects in JavaScript.

```javascript
const items = [1, 2, 3];

console.log(typeof items); // object
console.log(Array.isArray(items)); // true
```

Use `Array.isArray()` to check if a value is an array.

---

## 11. Explain `map`, `filter`, and `reduce`.

### Answer

These are common array methods used to transform, select, and calculate data.

### `map` - Transform Each Item

```javascript
const numbers = [1, 2, 3];
const doubledNumbers = numbers.map((number) => number * 2);

console.log(doubledNumbers); // [2, 4, 6]
```

### `filter` - Select Matching Items

```javascript
const numbers = [10, 15, 20, 25];
const evenNumbers = numbers.filter((number) => number % 2 === 0);

console.log(evenNumbers); // [10, 20]
```

### `reduce` - Convert Array Into One Value

```javascript
const numbers = [10, 20, 30];
const total = numbers.reduce((sum, number) => sum + number, 0);

console.log(total); // 60
```

### Interview Deep Point

Use:

- `map` when output array length should usually stay the same.
- `filter` when output array length may become smaller.
- `reduce` when you need one final result, such as sum, average, grouped object, or count.

---

## 12. What are objects in JavaScript?

### Answer

An object stores data as key-value pairs.

### Example

```javascript
const user = {
  id: 1,
  name: "Priya",
  email: "priya@example.com",
};

console.log(user.name);
console.log(user["email"]);
```

### Adding and Updating Properties

```javascript
const product = {
  name: "Laptop",
  price: 50000,
};

product.price = 48000;
product.inStock = true;

console.log(product);
```

### Interview Deep Point

Objects are reference types. When you assign an object to another variable, both variables point to the same object.

```javascript
const firstUser = { name: "Arun" };
const secondUser = firstUser;

secondUser.name = "Vijay";

console.log(firstUser.name); // Vijay
```

---

## 13. What is the difference between primitive and reference types?

### Answer

Primitive values are copied by value. Objects and arrays are copied by reference.

### Primitive Example

```javascript
let firstNumber = 10;
let secondNumber = firstNumber;

secondNumber = 20;

console.log(firstNumber); // 10
console.log(secondNumber); // 20
```

### Reference Example

```javascript
const firstPerson = { name: "Meena" };
const secondPerson = firstPerson;

secondPerson.name = "Divya";

console.log(firstPerson.name); // Divya
```

### Interview Deep Point

To copy objects safely, create a new object.

```javascript
const originalUser = { name: "Kiran", age: 28 };
const copiedUser = { ...originalUser };

copiedUser.name = "Naveen";

console.log(originalUser.name); // Kiran
console.log(copiedUser.name); // Naveen
```

The spread operator creates a shallow copy, not a deep copy.

---

## 14. What is a callback function?

### Answer

A callback is a function passed as an argument to another function. It is called later.

### Example

```javascript
function greetUser(name, callback) {
  console.log("Hello " + name);
  callback();
}

function sayDone() {
  console.log("Greeting completed");
}

greetUser("Sita", sayDone);
```

### Interview Deep Point

Callbacks are commonly used in asynchronous operations, event handlers, and array methods.

```javascript
const numbers = [1, 2, 3];

numbers.forEach(function (number) {
  console.log(number);
});
```

---

## 15. What is a closure?

### Answer

A closure happens when an inner function remembers variables from its outer function even after the outer function has finished execution.

Beginner-friendly meaning: a function carries its surrounding data with it.

### Example

```javascript
function createCounter() {
  let count = 0;

  return function () {
    count++;
    return count;
  };
}

const counter = createCounter();

console.log(counter()); // 1
console.log(counter()); // 2
console.log(counter()); // 3
```

### Interview Deep Point

Closures are useful for:

- Data privacy
- Function factories
- Maintaining state
- Event handlers

The variable `count` is not directly accessible outside `createCounter`, but the returned function can still use it.

---

## 16. What is `this` in JavaScript?

### Answer

`this` refers to the object that is currently calling the function.

### Example

```javascript
const user = {
  name: "Rahul",
  showName: function () {
    console.log(this.name);
  },
};

user.showName(); // Rahul
```

### Interview Deep Point

The value of `this` depends on how a function is called, not only where it is written.

Arrow functions do not have their own `this`. They use `this` from the surrounding scope.

```javascript
const user = {
  name: "Rahul",
  normalFunction: function () {
    console.log(this.name);
  },
  arrowFunction: () => {
    console.log(this.name);
  },
};

user.normalFunction(); // Rahul
user.arrowFunction(); // usually undefined
```

---

## 17. What is the DOM?

### Answer

DOM stands for Document Object Model. It is a tree-like structure created by the browser from HTML.

JavaScript can use the DOM to read, update, add, and remove elements from a web page.

### Example

```html
<h1 id="title">Old Title</h1>

<script>
  const title = document.getElementById("title");
  title.textContent = "New Title";
</script>
```

### Interview Deep Point

DOM manipulation can be expensive if done too often. Modern frameworks like React, Angular, and Vue help manage UI updates more efficiently.

---

## 18. What are events in JavaScript?

### Answer

Events are actions that happen in the browser, such as clicking a button, typing in an input, or loading a page.

### Example

```html
<button id="saveButton">Save</button>

<script>
  const button = document.getElementById("saveButton");

  button.addEventListener("click", function () {
    console.log("Button clicked");
  });
</script>
```

### Interview Deep Point

Events usually travel through the DOM in phases:

- Capturing phase
- Target phase
- Bubbling phase

Most beginner code uses event bubbling by default.

---

## 19. What is asynchronous JavaScript?

### Answer

Asynchronous JavaScript allows long-running tasks to happen without blocking the rest of the code.

Examples:

- API calls
- Timers
- File operations in Node.js
- Database calls in backend JavaScript

### Example

```javascript
console.log("Start");

setTimeout(function () {
  console.log("Timer finished");
}, 1000);

console.log("End");
```

Output:

```text
Start
End
Timer finished
```

### Interview Deep Point

JavaScript uses the event loop to handle asynchronous tasks. The main thread does not wait for `setTimeout` to finish. It continues executing the next line.

---

## 20. What is a Promise?

### Answer

A Promise represents a value that may be available now, later, or never.

A Promise has three states:

- Pending
- Fulfilled
- Rejected

### Example

```javascript
const promise = new Promise(function (resolve, reject) {
  const success = true;

  if (success) {
    resolve("Data received");
  } else {
    reject("Something went wrong");
  }
});

promise
  .then(function (result) {
    console.log(result);
  })
  .catch(function (error) {
    console.log(error);
  });
```

### Interview Deep Point

Promises avoid deeply nested callback code, often called callback hell.

---

## 21. What is `async` and `await`?

### Answer

`async` and `await` make Promise-based code easier to read.

### Example

```javascript
function getUser() {
  return Promise.resolve({ id: 1, name: "Ramesh" });
}

async function showUser() {
  const user = await getUser();
  console.log(user.name);
}

showUser();
```

### Interview Deep Point

`await` can only be used inside an `async` function, except in modern JavaScript modules where top-level await is supported.

Always handle errors using `try...catch`.

```javascript
async function loadUser() {
  try {
    const response = await fetch(
      "https://jsonplaceholder.typicode.com/users/1",
    );
    const user = await response.json();
    console.log(user.name);
  } catch (error) {
    console.log("Failed to load user", error);
  }
}
```

---

## 22. What is the event loop?

### Answer

The event loop is the mechanism that allows JavaScript to handle asynchronous tasks while still being single-threaded.

### Simple Explanation

JavaScript runs normal code first. Asynchronous callbacks wait in queues. The event loop checks when the call stack is empty and then moves waiting callbacks for execution.

### Example

```javascript
console.log("A");

setTimeout(function () {
  console.log("B");
}, 0);

console.log("C");
```

Output:

```text
A
C
B
```

### Interview Deep Point

Even with `0` milliseconds, `setTimeout` does not run immediately. It waits until the current call stack is empty.

---

## 23. What is error handling in JavaScript?

### Answer

Error handling means managing errors without crashing the application unexpectedly.

### Example

```javascript
try {
  const result = 10 / 0;
  console.log(result);
} catch (error) {
  console.log("Error occurred", error.message);
} finally {
  console.log("This always runs");
}
```

### Better Example

```javascript
function parseUser(jsonText) {
  try {
    return JSON.parse(jsonText);
  } catch (error) {
    return null;
  }
}

const user = parseUser('{ "name": "Latha" }');

if (user !== null) {
  console.log(user.name);
}
```

### Interview Deep Point

Use error handling around code that can fail, such as JSON parsing, API calls, and external input processing.

---

## 24. What are template literals?

### Answer

Template literals allow you to build strings using backticks and `${}` placeholders.

### Example

```javascript
const name = "Vikram";
const age = 29;

const message = `My name is ${name} and I am ${age} years old.`;

console.log(message);
```

### Interview Deep Point

Template literals support multi-line strings and expressions.

```javascript
const firstNumber = 10;
const secondNumber = 20;

console.log(`Total: ${firstNumber + secondNumber}`);
```

---

## 25. What are spread and rest operators?

### Answer

The spread operator expands values. The rest operator collects values.

Both use `...`, but their meaning depends on where they are used.

### Spread Example

```javascript
const firstArray = [1, 2];
const secondArray = [3, 4];

const combinedArray = [...firstArray, ...secondArray];

console.log(combinedArray); // [1, 2, 3, 4]
```

### Rest Example

```javascript
function addAll(...numbers) {
  return numbers.reduce((sum, number) => sum + number, 0);
}

console.log(addAll(10, 20, 30)); // 60
```

### Interview Deep Point

Spread is useful for copying arrays and objects, but it creates only a shallow copy.

```javascript
const user = { name: "Deepa", address: { city: "Pune" } };
const copiedUser = { ...user };

copiedUser.address.city = "Mumbai";

console.log(user.address.city); // Mumbai
```

Because `address` is a nested object, both objects still share it.

---

## 26. What is destructuring?

### Answer

Destructuring is a short way to extract values from arrays or objects.

### Object Destructuring

```javascript
const user = {
  name: "Sanjay",
  role: "Developer",
};

const { name, role } = user;

console.log(name);
console.log(role);
```

### Array Destructuring

```javascript
const colors = ["red", "green", "blue"];
const [firstColor, secondColor] = colors;

console.log(firstColor); // red
console.log(secondColor); // green
```

### Interview Deep Point

Destructuring is heavily used in React, Node.js, and modern JavaScript code.

```javascript
function printUser({ name, email }) {
  console.log(`${name} - ${email}`);
}

printUser({ name: "Nisha", email: "nisha@example.com" });
```

---

## 27. What are modules in JavaScript?

### Answer

Modules allow code to be split into separate files and reused.

### Export Example

```javascript
// math.js
export function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}
```

### Import Example

```javascript
// app.js
import { add } from "./math.js";

console.log(add(10, 20));
```

### Interview Deep Point

Modules help keep code organized. Modern JavaScript uses ES modules with `import` and `export`. Node.js also supports CommonJS using `require`, but ES modules are the modern standard.

---

## 28. What is JSON?

### Answer

JSON stands for JavaScript Object Notation. It is a text format used to send and receive data.

### Example JSON

```json
{
  "id": 1,
  "name": "Asha",
  "isActive": true
}
```

### Convert Object to JSON String

```javascript
const user = { id: 1, name: "Asha" };
const jsonText = JSON.stringify(user);

console.log(jsonText);
```

### Convert JSON String to Object

```javascript
const jsonText = '{ "id": 1, "name": "Asha" }';
const user = JSON.parse(jsonText);

console.log(user.name);
```

### Interview Deep Point

JSON keys and string values must use double quotes. JSON cannot directly store functions.

---

## 29. What is the difference between synchronous and asynchronous code?

### Answer

Synchronous code runs line by line. Each line waits for the previous line to finish.

Asynchronous code allows slow tasks to finish later while other code continues running.

### Synchronous Example

```javascript
console.log("First");
console.log("Second");
console.log("Third");
```

### Asynchronous Example

```javascript
console.log("First");

setTimeout(function () {
  console.log("Second");
}, 1000);

console.log("Third");
```

Output:

```text
First
Third
Second
```

### Interview Deep Point

JavaScript itself is single-threaded, but the browser and Node.js provide APIs that help handle asynchronous work.

---

## 30. What are truthy and falsy values?

### Answer

In JavaScript, values behave like `true` or `false` inside conditions.

Falsy values are:

- `false`
- `0`
- `""`
- `null`
- `undefined`
- `NaN`

Everything else is usually truthy.

### Example

```javascript
const name = "";

if (name) {
  console.log("Name exists");
} else {
  console.log("Name is empty");
}
```

### Interview Deep Point

Be careful when checking numbers because `0` is falsy.

```javascript
const count = 0;

if (count) {
  console.log("Count exists");
} else {
  console.log("Count is zero or missing");
}
```

If `0` is a valid value, check more explicitly.

```javascript
if (count !== null && count !== undefined) {
  console.log("Count value is available");
}
```

---

## Small Program Example: Student Marks Analyzer

### Requirement

Create a small JavaScript program that:

1. Stores student marks.
2. Calculates total marks.
3. Calculates average marks.
4. Finds pass or fail status.
5. Prints a clear result.

### Program

```javascript
const student = {
  name: "Arjun",
  marks: [80, 75, 90, 60, 85],
};

function calculateTotal(marks) {
  return marks.reduce((total, mark) => total + mark, 0);
}

function calculateAverage(total, subjectCount) {
  return total / subjectCount;
}

function getResultStatus(average) {
  if (average >= 40) {
    return "Pass";
  }

  return "Fail";
}

function printStudentResult(student) {
  const total = calculateTotal(student.marks);
  const average = calculateAverage(total, student.marks.length);
  const status = getResultStatus(average);

  console.log(`Student Name: ${student.name}`);
  console.log(`Total Marks: ${total}`);
  console.log(`Average Marks: ${average}`);
  console.log(`Result: ${status}`);
}

printStudentResult(student);
```

### Output

```text
Student Name: Arjun
Total Marks: 390
Average Marks: 78
Result: Pass
```

### What This Program Teaches

- Object usage with `student`
- Array usage with `marks`
- Function creation
- `reduce` method
- Conditional logic with `if`
- Template literals
- Code organization using small functions

### Interview Follow-Up Questions From This Program

#### 1. Why did we use `reduce`?

Because `reduce` is useful when we want to convert an array into one final value. Here, we convert all marks into one total.

#### 2. Why did we create separate functions?

Separate functions make the code easier to read, test, and maintain.

#### 3. What happens if the marks array is empty?

The total will be `0`, but average calculation will become `0 / 0`, which returns `NaN`.

Better version:

```javascript
function calculateAverage(total, subjectCount) {
  if (subjectCount === 0) {
    return 0;
  }

  return total / subjectCount;
}
```

#### 4. How can we find the highest mark?

```javascript
const highestMark = Math.max(...student.marks);

console.log(highestMark); // 90
```

#### 5. How can we count failed subjects?

```javascript
const failedSubjects = student.marks.filter((mark) => mark < 40);

console.log(failedSubjects.length);
```

---

## Quick Revision Checklist

Before an interview, make sure you can explain:

- Difference between `var`, `let`, and `const`
- Difference between `==` and `===`
- Primitive vs reference types
- `null` vs `undefined`
- Functions and arrow functions
- Scope and hoisting
- Arrays and objects
- `map`, `filter`, and `reduce`
- Callback functions
- Closures
- `this`
- DOM and events
- Promises
- `async` and `await`
- Event loop
- Error handling
- JSON

---

## Practice Tasks

1. Write a function to check whether a number is even or odd.
2. Write a function to reverse a string.
3. Create an array of employees and filter employees with salary greater than 50000.
4. Create an object for a product and print its name and price.
5. Write a Promise that resolves after 2 seconds.
6. Use `async` and `await` to call a public API.
7. Write a closure-based counter.
8. Use `map` to convert an array of names to uppercase.
9. Use `reduce` to calculate total cart price.
10. Create a button in HTML and handle its click event using JavaScript.
