
<!-- vim-markdown-toc Marked -->

* [ASC Supplementary 5](#asc-supplementary-5)
    * [Install](#install)
    * [Evaluate and Finetune](#evaluate-and-finetune)
        * [Evaluate](#evaluate)
        * [Finetune](#finetune)
    * [Analysis](#analysis)
        * [Analyse Evaluating Log](#analyse-evaluating-log)
            * [Statistic data](#statistic-data)
            * [Error type image](#error-type-image)
        * [Analyse Finetuning Log](#analyse-finetuning-log)
    * [Make New Dataset](#make-new-dataset)

<!-- vim-markdown-toc -->

# ASC Supplementary 5 

## Install

1. Download the source code.
    ```bash 
    git clone https://gitee.com/TangliziGit/ASC20-ELE ele
    cd ele 
    ```
2. Copy data from `202.117.249.199`.
    ```bash
    scp -r asc20@202.117.249.199:~/data/zhangcx/ele/data .
    scp -r asc20@202.117.249.199:~/data/zhangcx/ele/data-bin .
    scp -r asc20@202.117.249.199:~/data/zhangcx/ele/checkpoints .
    ```
3. Install `fairseq`, it will install the packages and `fairseq`.
    ```bash
    pip install --editable .
    ```

    Below is the packages this project directly depends on:
    > requests==2.19.1  
    > sentencepiece==0.1.85  
    > torch==1.4.0  
    > numpy==1.15.1  
    > Cython==0.28.5  
    > matplotlib==2.2.3  
    > sacrebleu==1.4.3  
    > tqdm==4.26.0  
    > click==6.7  
    > h5py==2.8.0  
    > regex==2020.2.20  
    > nltk==3.3  
    > pandas==0.23.4  


## Evaluate and Finetune

### Evaluate 

```bash
python evaluate_candidates.py --questions data/ELE/valid.jsonl --model checkpoints/mask-exp4 --log mask-exp4
```

It will solve the questions in `data/ELE/valid.jsonl` using `checkpoints/mask-exp4/model.pt` model, and record the logging message into `mask-exp4-log.pkl`.


### Finetune 

Write the fintune script, an example is like this:
```bash
vim mask-finetune/exp4.sh
```

```bash 
TOTAL_UPDATES=2400    # Total number of training steps
# WARMUP_UPDATES=100    # Warmup the learning rate over this many updates
PEAK_LR=0.000004          # Peak learning rate, adjust as needed
TOKENS_PER_SAMPLE=512   # Max sequence length
MAX_POSITIONS=512       # Num. positional embeddings (usually same as above)
# MAX_SENTENCES=16        # Number of sequences per batch (batch size)
# UPDATE_FREQ=16          # Increase the batch size 16x
MAX_SENTENCES=2        # Number of sequences per batch (batch size)
UPDATE_FREQ=64          # Increase the batch size 16x

SAVE_DIR=checkpoints/mask-exp4     # !!!
ROBERTA_PATH=models/roberta.large/model.pt

DATA_DIR=data-bin/ele

# CUDA_VISIBLE_DEVICES=0 fairseq-train --fp16 $DATA_DIR \
# CUDA_VISIBLE_DEVICES=0 fairseq-train $DATA_DIR \
fairseq-train $DATA_DIR \
    --task masked_lm --criterion masked_lm \
    --arch roberta_large --sample-break-mode complete --tokens-per-sample $TOKENS_PER_SAMPLE \
    --optimizer adam --adam-betas '(0.9,0.98)' --adam-eps 1e-6 --clip-norm 0.0 \
    --lr-scheduler fixed --lr $PEAK_LR \
    --dropout 0.1 --attention-dropout 0.1 --weight-decay 0.01 \
    --max-sentences $MAX_SENTENCES --update-freq $UPDATE_FREQ \
    --max-update $TOTAL_UPDATES --log-format simple --log-interval 25 \
    --ddp-backend=no_c10d \
    --restore-file $ROBERTA_PATH \
    --save-dir $SAVE_DIR \
    --skip-invalid-size-inputs-valid-test
```

Then run `bash mask-finetune/exp4.sh`.  
Or if you want to save the logging messages, use `log` written in `.bashrc`:
```bash 
log bash mask-finetune/exp4.sh
```
The log file will be saved on `log/0303_23:19.log`.  

The `log` command in `.bashrc` is:  
```bash
function log(){
    dir=`pwd`
    filename=$dir/log/`date +%m%d_%H:%M.log`

    echo "$@" >> $filename
    $@ 2>&1 | tee -a $filename

    echo "" >> $filename
    date +%m%d_%H:%M >> $filename
    python $dir/send_email.py $filename
}
```


## Analysis

### Analyse Evaluating Log

#### Statistic data

After evaluating, you can run `python stat.py pkl/mask-exp4` to get the statistic data of this evaluate process.  
The output is like this:  
```bash
multi-words      0.0
unk            220.0
near           468.0
far            268.0
dtype: float64

max acc 1.0
min acc 0.25
var acc 0.01125261111111111
Accuracy: 0.8774044626827392
```

#### Error type image

Write the log file name to `pkl_log_files` in `draw.py`, the `pkl_log_files` is like this:
```python
pkl_log_files = {
    "#18": "mask-large-without_ul",
    "#19": "mask-large-without_ul-long_art",
    "#20": "mask-large-without_ul-long_art-unk",
    "#21": "mask-exp3-without_ul-long_art-unk",
    "#22": "mask-exp3-t4",
    "#23": "mask-exp4-t4",
    "#24": "mask-exp4-t3",
}
```

And run `python draw.py`, you will get `fig/error.png`.


### Analyse Finetuning Log

Write the log file name to `log_files` in `draw.py`, which is like this:
```python
log_files = {
    "large": "0208_13:11.log",
    "exp1":  "0210_21:12.log",
    "exp2":  "0211_11:51.log",
    "exp3":  "0212_21:20.log",
    "exp4":  "0214_00:21.log",
    "exp6":  "0228_08:58.log",
    "exp7":  "0228_20:23.log",
}
```

And run `python draw.py`, you will get `fig/loss.png`.


## Make New Dataset

Fill all the answers into `train.jsonl` and `valid.jsonl` question articels, write them into `raw/new_dataset/train.raw` and `raw/new_dataset/valid.raw`, splited by a line.  
Modify and run `process.sh`, you will get `data-bin/new_dataset` directory which is the new dataset.

