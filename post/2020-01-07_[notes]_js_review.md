
<!-- vim-markdown-toc Marked -->

* [JS review](#js-review)
    * [Function & Method](#function-&-method)
        * [Function expression](#function-expression)
        * [Method Syntax (function expression)](#method-syntax-(function-expression))
            * [Generator method](#generator-method)
            * [Async method](#async-method)
            * [Getter and setter](#getter-and-setter)
    * [Class](#class)
        * [Class experssion & Class declaration](#class-experssion-&-class-declaration)
        * [Static Methods](#static-methods)
    * [Arrow functions](#arrow-functions)

<!-- vim-markdown-toc -->

# JS review

## Function & Method
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Method_definitions>

### Function expression
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/function>

函数表达式不被**提升**(hoisted), 相较与函数声明(function declarations).

```javascript
// function expression
var func = function () {...}
var func = { func: function() {...} }
var func = { func() {...} }

// function declaration, is hoisted
function func() {...}
```

### Method Syntax (function expression)

```javascript
const obj = {
  property( parameters… ) {},
  *generator( parameters… ) {},
  async property( parameters… ) {},
  async* generator( parameters… ) {},

  // with computed keys
  [property]( parameters… ) {},
  *[generator]( parameters… ) {},
  async [property]( parameters… ) {},

  // compare getter/setter syntax:
  get property() {},
  set property(value) {}
};
```

#### Generator method

contains `yield` keyword, use `G().next().value` to get next value.

#### Async method

contains `await` keyword
```javascript
await new Promise(resolve => {
    ...
})
```

#### Getter and setter
you can get the property without brackets, and set it with `=`, instead of call a method.


## Class
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes>

### Class experssion & Class declaration

二者具有相同的提升限制.
```javascript
class Class {...}               // class declaration
let Class = class {...}         // unnamed class expression
let Class = class Class2 {...}  // named class expression
```

### Static Methods

`to be continued`


## Arrow functions

Arrow functions don't have their own this value so they're handy when you want to preserve the this value from an outer method definition.
