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


## Chapter 3

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


