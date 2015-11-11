# PHP CLI

## Description

This image offers a comprehensive CLI PHP environment with newt, readline
and ncurses extensions available. It's intended to create containers to
provide a PHP console application.

The last PHP version is compiled through a build process borrowed from
the official PHP Docker image, with [this Dockerfile used](https://github.com/docker-library/php/blob/08bf31dfd492f02a2696c9a30eb85326b1570abd/5.6/fpm/Dockerfile).

We add common extensions like calendar, curl, gd, iconv, libxml, mbstring,
mcrypt, mysqli, PDO MySQL and pcntl. The Pear, PECL executables and utilities
(including build stuff like phpize) are available too.

Once running, you can quickly add PHP extensions to this image,
with `docker-php-ext-configure` and `docker-php-ext-install` scripts.

## How to use it

To rebuild this image:

    docker build --tag nasqueron/php-cli .

To rebuild a fork of this image based on a modified Dockerfile:

    docker build --tag your-image-name-tag .

To launch a container to execute a PHP application 'quux' in /data/awesome-php-app:

    docker run -it --rm -v /data/awesome-php-app:/opt/app nasqueron/php-cli /opt/app/quux

To create an image for an application with this as base, create a Dockerfile:

    FROM nasqueron/php-cli
    # Debian commands to deploy your application code
    CMD ["/path/to/your/app"]

That's it.
