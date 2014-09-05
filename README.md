skeleton-docker
===============

```sh
ssh-keygen -t rsa -C "your_email@example.com"
docker build -t skeleton_app .
docker run --name docker-php-app -d -p 2222:22 -p 8080:80 -v /home/.../www/docker-php-app/:/home/devop/www/ skeleton_app
```
