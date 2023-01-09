FROM nginx:alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache git fcgiwrap grep bash \
    && git clone https://github.com/TangliziGit/shell-blog /blog \
    && echo "* * * * * sh /blog/util/daemon.sh > /blog/daemon.log" >> /var/spool/cron/crontabs/root \
    && cp /blog/nginx.conf /etc/nginx/nginx.conf \
    && echo "rm /var/run/fcgiwrap.sock" >> /docker-entrypoint.d/startup.sh \
    && echo "fcgiwrap -s unix:/var/run/fcgiwrap.sock > /var/log/fcgi.log 2>&1 &" >> /docker-entrypoint.d/startup.sh \
    && echo "crond" >> /docker-entrypoint.d/startup.sh \
    && mkdir -p /tmp/nginx/cache \
    && chmod +x /docker-entrypoint.d/startup.sh

WORKDIR /blog
