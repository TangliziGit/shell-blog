FROM nginx:alpine
RUN apk add --no-cache git fcgiwrap \
    && git clone https://github.com/TangliziGit/shell-blog /blog \
    && echo "0 * * * * sh /blog/util/daemon.sh > /blog/daemon.log" >> /var/spool/crond/crontabs/root \
    && cp /blog/nginx.conf /etc/nginx/nginx.conf \
    && fcgiwrap -s unix:/var/run/fcgiwrap.sock & \
    && crond 

