#( Squid Docker image

- [Introduction](#introduction)
- [How to use it](#how-to-use-it)

# Introduction

Yet another docker image for [Squid proxy server](http://www.squid-cache.org/).
This dockerfile builds a Debian-11 based Squid-5.x image with
[SSL bumping support](https://wiki.squid-cache.org/Features/SslBump).
It installs [squid-openssl](https://packages.debian.org/sid/squid-openssl) debian package
which contains squid compiled with `--with-openssl` option
(unlike [squid](https://packages.debian.org/sid/squid) package).

The purpose of this image is to run Squid-5 as MITM. The image allows using your own
certificate for SSL bumping or it can generate a self-signed cert each time it starts.

**_NOTE:_**  Caching is disabled by default.

# How to use it

## Basic use-case

To simply run a docker container:

```bash
  $ docker run -p 3128:3128 -d --name squid5 dans/squid:5.6
```

## Use your own certificate for SSL bumping

You can mount a directory containing a certificate and a key to be used by squid for SSL bumping.

```bash
  $ ls ./my_certs
  private.key private.crt
  $ docker run -p 3128:3128 -d --volume $(pwd)/my_certs:/certs --name squid5 dans/squid:5.6
```

## Use your custom squid configuration

```bash
  $ ls -R ./my_squid_configs
    acls	conf.d

    mysquid/acls:
    fast_fail_regexps.txt	no_ssl_bump_domains.txt

    mysquid/conf.d:
    debug.conf

  # enable debug logging
  $ cat ./my_squid_configs/conf.d/debug.conf
  debug_options ALL,1 16,9 11,2 74,9
  # do not SSL bump google.com
  $ cat ./my_squid_configs/acls/no_ssl_bump_domains.txt
  google.com

  $ docker run -p 3128:3128 -d --volume $(pwd)/my_squid_configs/squid --name squid5 dans/squid:5.6
```
