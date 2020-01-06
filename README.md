# shell-blog

A simple static blog web app based on `nginx` and `shell-scripts`.

<http://39.106.185.26/index.sh>


## Deploy & Run

```bash
cp nginx.conf /etc/nginx/nginx.conf
systemctl start nginx
fcgiwrap -s unix:/var/run/fcgiwrap.sock
```


## License

> MIT License
>
> Copyright (c) 2020 Chunxu Zhang
