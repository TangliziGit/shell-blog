大家好嘞，今天闲着没事干开写写博客，记录一下Maven+SpringBoot的多模块设计和遇到的坑。

# 多模块设计

简单说明一下截止目前的需求：
- 需要RESTful API：对文章、标签、分类和评论等的CRUD
- 要前台展示： 首页、归档、文章具体页等
- 后台管理：添加文章、新增标签之类

简单分析可以简单设计一个模块来组织代码，比如就叫oyster-blog。

但显然有个问题，这么设计会让代码比较混乱，比如我不能在同一个类中处理所有的请求，也不能分成三个类分别实现这三个功能。
比较好的设计是分成三个包，然后各个包内细化各个功能。

这么做的话，不太方便团队开发。一堆人一起写一个模块，管理起来有些麻烦。
比如突然新增一个特性，牵扯一堆东西。大家一起写的话，最后合并代码说不定还会冲突。
所以我们来稿多模块吧。

但不方便的地方还是存在，比如突然有一天我的前台展示挂掉了。
这种情况下，老板或者我个人甚至想让api模块不受影响，继续运行。
这可咋整？

这种情况我们貌似可以做微服务了。（猜测这样多模块设计过渡到微服务是轻松的，还没想做这个呢）

那么就有一个多模块的设计：
- oyster-common
    *提供公共的访问数据库的接口，工具类（比如分析请求的工具，时间处理）*
- oyster-api
    *提供RESTful API*
- oyster-front
    *提供前台展示*
- oyster-back
    *后台管理*

# Maven多模块构建的细节

最终模块长这样：
![](https://img2018.cnblogs.com/blog/1225237/201905/1225237-20190506224814750-911683178.png)

首先新建一个maven工程，然后删除文件，只剩pom.xml。具体pom配置下来再说。
新建api、common和front模块：
    - 组织名就填组织名，例：org.tanglizi
    - artifact填项目名，例：oyster
    - 包名换成具体模块名，例：org.tanglizi.oyster.api

父模块oyster的pom.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.tanglizi</groupId>
    <artifactId>oyster</artifactId>
    <packaging>pom</packaging>
    <version>1.0-SNAPSHOT</version>

    <!-- 注意此处 -->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.4.RELEASE</version>
        <relativePath/>
    </parent>

    <!-- 注意此处 -->
    <modules>
        <module>oyster-common</module>
        <module>oyster-api</module>
        <module>oyster-front</module>
        <module>oyster-runner</module>
    </modules>


    <properties>
        <java.version>1.8</java.version>
    </properties>

    <build>
        <!-- plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins -->

        <!-- 注意此处 -->
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.1</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.22.1</version>
                <configuration>
                    <skipTests>true</skipTests>    <!--默认关掉单元测试 -->
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>
```

子模块oyster-api
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <!-- 注意此处 -->
    <parent>
        <groupId>org.tanglizi</groupId>
        <artifactId>oyster</artifactId>
        <version>1.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>
    <groupId>org.tanglizi</groupId>
    <artifactId>oyster-api</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>oyster-api</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.tanglizi</groupId>
            <artifactId>oyster-common</artifactId>
            <version>0.0.1-SNAPSHOT</version>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>2.0.1</version>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <!-- plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins -->
    </build>

</project>
```

子模块oyster-common
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <!-- 注意此处 -->
    <parent>
        <groupId>org.tanglizi</groupId>
        <artifactId>oyster</artifactId>
        <version>1.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>
    <groupId>org.tanglizi</groupId>
    <artifactId>oyster-common</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>oyster-common</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>2.0.1</version>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <!-- plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins -->
    </build>

</project>
```

oyster-front
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <!-- 注意此处 -->
    <parent>
        <groupId>org.tanglizi</groupId>
        <artifactId>oyster</artifactId>
        <version>1.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>
    <groupId>org.tanglizi</groupId>
    <artifactId>oyster-front</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>oyster-front</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.tanglizi</groupId>
            <artifactId>oyster-common</artifactId>
            <version>0.0.1-SNAPSHOT</version>
            <!-- scope>compile</scope -->
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>2.0.1</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>

        <dependency>
            <groupId>com.vladsch.flexmark</groupId>
            <artifactId>flexmark-all</artifactId>
            <version>0.42.6</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>druid</artifactId>
            <version>1.1.16</version>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <!-- plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>

                <executions>
                    <execution>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins -->
    </build>

</project>
```

oyster-runner
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <!-- 注意此处 -->
    <parent>
        <groupId>org.tanglizi</groupId>
        <artifactId>oyster</artifactId>
        <version>1.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>
    <groupId>org.tanglizi</groupId>
    <artifactId>oyster-runner</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>oyster-runner</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.tanglizi</groupId>
            <artifactId>oyster-front</artifactId>
            <version>0.0.1-SNAPSHOT</version>
        </dependency>
        <dependency>
            <groupId>org.tanglizi</groupId>
            <artifactId>oyster-api</artifactId>
            <version>0.0.1-SNAPSHOT</version>
        </dependency>
        <dependency>
            <groupId>org.tanglizi</groupId>
            <artifactId>oyster-common</artifactId>
            <version>0.0.1-SNAPSHOT</version>
            <!--scope>compile</scope-->
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>

                <!--
                注意此处

                 [ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.1:compile (default-compile) on project oyster-front: Compilation failure: Compilation failure:
[ERROR] /home/tanglizi/IdeaProjects/oyster/oyster-front/src/main/java/org/tanglizi/oyster/controllers/SearchController.java:[8,40] package org.tanglizi.oyster.dto.entities does not exist
                 -->
                <executions>
                    <execution>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

</project>

```

# Maven+SpringBoot多模块的细节

待续