# shell-blog

A simple static blog web app based on `nginx` and `shell-scripts`.



## Deploy & Run

```bash
cp nginx.conf /etc/nginx/nginx.conf
systemctl start nginx
fcgiwrap -s unix:/var/run/fcgiwrap.sock
```



## Screen shot

![Screenshot from 2020-01-05 20-22-27](/home/tanglizi/Pictures/Screenshot from 2020-01-05 20-22-27.png)



## License

> MIT License
>
> Copyright (c) 2020 Chunxu Zhang