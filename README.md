# shell-blog

A simple static blog web app based on `nginx` and `shell-scripts`.


## Deploy & Run

```bash
docker build -t shell-blog .
docker run --name shell-blog -p 80:80 -d shell-blog
```

## Post & modify file steps

You can **simply write new file in `master` using github editor** and wait server to pull.

Or,
1. Write/modify your markdown file in `edit` branch, via local or github editor.
2. Commit it and make a pr, and `github actions` will run `CI` to check your file format.
    If you do not pass the `CI`, you will receive a email with failure information.
3. Merge it.
4. Wait an hour or directly trigger your server to accept the new content, via `git pull`.


## License

> MIT License
>
> Copyright (c) 2020 Chunxu Zhang
