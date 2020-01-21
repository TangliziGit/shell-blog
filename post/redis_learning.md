# Redis Learning

学习Redis的使用

## Data Structure

- (key)
- `String`: 二进制字符串 
- `List`: 链表实现
- `Set`: 无序无重复集合
- `Hash`: 类似`Map<String, Object>`
- `ZSet`: 带分数的`Set`


## Operations


### Key

| Oper                | Comment                |
|---------------------|------------------------|
| `select (number)`   |                        |
| `move key (number)` |                        |
| `key *`             |                        |
| `exists key`        |                        |
| `type key`          |                        |
| `expire key sec`    | 过期删除key            |
| `ttl key`           | -1 永不过期, -2 已过期 |

### String

| Oper                      | Comment                 |
|---------------------------|-------------------------|
| `set`/`setnx`/`get`/`del` | setnx: set if not exist |
| `mset`/`mget`/`msetnx`    | 批添加 / 批查找         |
| `append`/`strlen`         |                         |
| `incr`/`decr`             |                         |
| `getrange`/`setrange`     |                         |

### the Rest

> 之后在学吧...
