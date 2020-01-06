### 场景
刚写的scala处理bmp文件的实验, 打了jar包让java调用一下, 结果发生这个错误.
```java
package org.tanglizi.bmp.demo;

import org.tanglizi.bmp.image.BmpImage;
import scala.Tuple3;

public class Application {

    public static void main(String[] args) {
        BmpImage image = BmpImage.create(200, 100);
        image = image.fill(new Tuple3<>(127, 0, 100));
        image.save("example.bmp");
    }
}

```

```
Exception in thread "main" java.lang.ClassCastException: java.lang.Integer cannot be cast to java.lang.Short
	at scala.runtime.BoxesRunTime.unboxToShort(BoxesRunTime.java:96)
	at org.tanglizi.bmp.image.BmpWriter$.$anonfun$toBytes$2(BmpWriter.scala:14)
	at scala.collection.immutable.List.foreach(List.scala:312)
	at org.tanglizi.bmp.image.BmpWriter$.$anonfun$toBytes$1(BmpWriter.scala:13)
	at org.tanglizi.bmp.image.BmpWriter$.$anonfun$toBytes$1$adapted(BmpWriter.scala:12)
	at scala.collection.immutable.List.foreach(List.scala:312)
	at org.tanglizi.bmp.image.BmpWriter$.toBytes(BmpWriter.scala:12)
	at org.tanglizi.bmp.image.BmpImage.save(BmpImage.scala:18)
	at org.tanglizi.bmp.image.BmpImage.save(BmpImage.scala:14)
	at org.tanglizi.bmp.demo.Application.main(Application.java:11)

Process finished with exit code 1

```

### 解决方法
范型问题, `Tuple3<>`应该为`Tuple3<Short, Short, Short>`
为了简化代码, 改为`new Tuple3<>((short)127, ...)`
