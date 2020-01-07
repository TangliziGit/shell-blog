
<!-- vim-markdown-toc Marked -->

* [Scala Learning Notes](#scala-learning-notes)
    * [Chapter 1](#chapter-1)
    * [Chapter 2](#chapter-2)
    * [Chapter 3 - Array](#chapter-3---array)
    * [Chapter 4 - Map and Tuple](#chapter-4---map-and-tuple)
    * [Chapter 5 - Class](#chapter-5---class)

<!-- vim-markdown-toc -->

# Scala Learning Notes
Simply take some notes.

## Chapter 1
None


## Chapter 2

1. **Lazy Value**, the base of lazy value data structure, usage:
    ```scala
    lazy val words = io.Source.fromFile("words.txt").mkString
    ```
    The difference among `val`, `lazy` and `def`:
   - `val`: evaluated when defined.
   - `lazy`: evaluated when first used.
   - `def`:  evaluated every time used.
2. **Exceptions**
    1. same as java, but you not **never have to declare `throws`**.
    2. the type of `throw new Exception()` is `Nothing`, global sub class.
    3. use pattern-matching to catch it.
        ```scala
        try {
            process(new URL("http://horstmann.com/fred-tiny.gif"))
        } catch {
            case _: MalformedURLException => println("Bad URL: " + url)
            case ex: IOException => ex.printStackTrace()
        }
        ```


## Chapter 3 - Array

1. container design thought:
    The parameters of class constructor should be the size of it,
    and parameters of object constructor should be the contents;
2. about **`ArrayBuffer`**:
    1. `Array<Int>` is `int[]` in jvm.
    2. `ArrayBuffer` usage:
        - `arr += (1, 2, 3)`: appending elements.
        - `arr ++= Array(1, 2, 3)`: addAll elements in another container.
        - `arr.toArray`
        - `arr.sortWith(_ > _)`: a common operation. To sort a container, the elements should be with **`Ordered` trait**.
3. traversing: to visit every two elements, `0 until (10, 2)`


## Chapter 4 - Map and Tuple

1. about **`Map`**:
    - `(x -> y)` is a `Tuple`
    - `val map = mutable.HashMap[String, Int]("One" -> 1)`
    - `map + ("One" -> 1, "Two" -> 2)`: add a `Tuple` element into it.
    - `map - "One"`: remove a maping.
    - `map ++ Array[(String, Int)]("One" -> 1)`: add all.
    - `for ((k, v) <- map) ...`: iterating.
2. about **`Tuple`**:
    - `val t: (String, Int) = ("a", 1)`
    - `t._1`: visit the first element.
    - `val (first, second) = t`: declare variables using pattern-matching.
    - `keys.zip(values).toMap`: **convert BiTuple to Map**


## Chapter 5 - Class

1. you can call a parameterless method (constructor) without parentheses.
2. **Fields** in scala: Scala provides **getter and setter** methods for every field.
    |annotation|field|getter|setter|
    |:-:|:-:|:-:|:-:|
    |None|private|public|public|
    |private|private|private|private|
    |val|private final|public|None|
    |private[this]|private|None|None|

    - all fields must be initialized, you can write `var xxx = _` to init it.
    - `private[this]` provides more serious visibility.
    - `private[OuterClass]` for nest class field, can be visited by outer class.
    - getter is compiled to a method named `xxx`, and setter is `xxx_=`
    - `@BeanProperty var xxx` will generate 4 methods: `xxx`, `xxx_=`, `getXxx`, `setXxx`.
        this annotation can be used to interoperate with java.
3. **Auxiliary Constructors**
    - all constructor are called `this()`
    - each auxiliary constructor must start with a call to a previously defined auxiliary constructor
or the primary constructor.
    ```scala 
    def this(name: String) { // An auxiliary constructor
        this() // Calls primary constructor
        this.name = name
    }

    def this(name: String, age: Int) { // Another auxiliary constructor
        this(name) // Calls previous auxiliary constructor
        this.age = age
    }
    ```
4. **Primary Constructor**
   - parameters of the primary constructor turn into fields that are initialized with the construction
parameters.
   - primary constructor executes all statements in the class definition.
   - if a parameter without val or var is used inside at least one method, it becomes a field.
5. **Nested Classes**
    - each instance has its own inner class, they are different. but in java, inner class belongs to outer class.
    ```scala
    // in scala
    new outer.Inner()
    ```
    ```java 
    // in java
    outer.new Inner();
    ```
    - if you do not want they be different, you can define `InnerClass` in `object`, or use `type projection`(Outer#Inner).
    - in java you can use `Outer.this` to access outer instance. And in scala, you cam do this to access them:
    ```scala
    class Outer { outer =>
        class Inner {
            def description = "outer name is " + outer.name
        }
    }
    ```

    
