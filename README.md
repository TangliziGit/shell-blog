# shell-blog

A simple static blog web app based on `nginx` and `shell-scripts`.

<http://39.106.185.26/index.sh>


## Deploy & Run

```bash
cp nginx.conf /etc/nginx/nginx.conf
systemctl start nginx
fcgiwrap -s unix:/var/run/fcgiwrap.sock
crontab -e
# append a line to enable sync hourly: `0 * * * * bash /your/path/shell-blog/util/daemon.sh`
```

## Post & modify file steps

1. Write/modify your markdown file in `edit` branch, via local or github editor.
2. Commit it and make a pr, and `github actions` will run `CI` to check your file format.
    If you do not pass the `CI`, you will receive a email with failure information.
3. Merge it.
4. Trigger your server to accept the new content, via `git pull`.

Or, you can simply write new file in `master` and trigger server to pull.

The `CI` process will be run too.


## License

> MIT License
>
> Copyright (c) 2020 Chunxu Zhang
