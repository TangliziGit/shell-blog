# ASC Suplementary 3

## finetune & valid

...

### OOM

```
| WARNING: attempting to recover from OOM in forward/backward pass
| WARNING: OOM in all workers, skipping update
| OOM: Ran out of memory with exception: CUDA out of memory. Tried to allocate 62.00 MiB (GPU 0; 15.90 GiB total capacity; 14.59 GiB already allocated; 9.88 MiB free; 15.19 GiB reserved in total by PyTorch)
|===========================================================================|
|                  PyTorch CUDA memory summary, device ID 0                 |
|---------------------------------------------------------------------------|
|            CUDA OOMs: 58           |        cudaMalloc retries: 66        |
|===========================================================================|
|        Metric         | Cur Usage  | Peak Usage | Tot Alloc  | Tot Freed  |
|---------------------------------------------------------------------------|
| Allocated memory      |   14935 MB |   15377 MB |     995 GB |     980 GB |
|       from large pool |   14932 MB |   15374 MB |     995 GB |     980 GB |
|       from small pool |       2 MB |       3 MB |       0 GB |       0 GB |
|---------------------------------------------------------------------------|
| Active memory         |   14935 MB |   15377 MB |     995 GB |     980 GB |
|       from large pool |   14932 MB |   15374 MB |     995 GB |     980 GB |
|       from small pool |       2 MB |       3 MB |       0 GB |       0 GB |
|---------------------------------------------------------------------------|
| GPU reserved memory   |   15552 MB |   15560 MB |   51434 MB |   35882 MB |
|       from large pool |   15548 MB |   15556 MB |   51424 MB |   35876 MB |
|       from small pool |       4 MB |       4 MB |      10 MB |       6 MB |
|---------------------------------------------------------------------------|
| Non-releasable memory |  631465 KB |    1511 MB |  419075 MB |  418459 MB |
|       from large pool |  630420 KB |    1510 MB |  418768 MB |  418152 MB |
|       from small pool |    1044 KB |       2 MB |     307 MB |     306 MB |
|---------------------------------------------------------------------------|
| Allocations           |     728    |     831    |   33352    |   32624    |
|       from large pool |     406    |     489    |   25889    |   25483    |
|       from small pool |     322    |     342    |    7463    |    7141    |
|---------------------------------------------------------------------------|
| Active allocs         |     728    |     831    |   33352    |   32624    |
|       from large pool |     406    |     489    |   25889    |   25483    |
|       from small pool |     322    |     342    |    7463    |    7141    |
|---------------------------------------------------------------------------|
| GPU reserved segments |     172    |     193    |     590    |     418    |
|       from large pool |     170    |     191    |     585    |     415    |
|       from small pool |       2    |       2    |       5    |       3    |
|---------------------------------------------------------------------------|
| Non-releasable allocs |     125    |     152    |   18243    |   18118    |
|       from large pool |     121    |     149    |   15882    |   15761    |
|       from small pool |       4    |       5    |    2361    |    2357    |
|===========================================================================|

```

sulotion:
- reduce input sentences length, or number.

### result

| data format | update | LR update | LR    | batch size | accuracy |
|-------------|--------|-----------|-------|------------|----------|
| 3段式数据   | 3000   | 150       | 1e-05 | 16         | 0.2907   |


## automation scripts

### logging

```bash
function log(){
    filename=/home/asc20/data/zhangcx/ele/log/`date +%m%d_%H:%M.log`
    $@ 2>&1 | tee $filename
    echo "" >> $filename
    date +%m%d_%H:%M >> $filename
    python /home/asc20/data/zhangcx/ele/send_email.py $filename
}
```

Usage: `log bash finetune.sh` 

### training

set checkpoints step and directory

### valid

use `watchdog` to monitor new model files, to valid the accuray score.
