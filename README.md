# Kong declarative with env
[![Docker](https://github.com/webhood-io/kong/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/webhood-io/kong/actions/workflows/docker-publish.yml)

Kong with ability to reference environment variables in declarative configuration file.

## Why?

Kong declarative configuration doesn't support environment variables interpolation ie. refencing an environment variable to be substituted at runtime.

## How?

This image is based on the official Kong image and uses the same [Dockerfile](https://github.com/Kong/docker-kong/blob/master/build_your_own_images.md) used to build the official one, but with a custom entrypoint that does the interpolation. 

All strings that start with `_FILE` will be replaced by the value of the environment variable with the same name.

## Getting Started

Create a config file with environment variables to be interpolated. For example:

with env

`SECRET=SuperSecretValue`

and file `kong.yml`

```yaml
secret: SECRET_FILE
```

will be interpolated to

```yaml
secret: SuperSecretValue
```

### Configure

**example.yaml**
```yaml
---
_format_version: '1.1'
consumers:
  - username: anon
    keyauth_credentials:
      - key: ANON_KEY_FILE
```

Remember to set the environment variable to be interpolated: `ANON_KEY`

**docker-compose.yml**
```yaml
 services:
  kong:
    container_name: webhood-kong
    image: ghcr.io/webhood-io/kong:main
    restart: unless-stopped
    environment:
      ANON_KEY: ${ANON_KEY}
      WEBHOOD_CONFIG: /tmp/kong.yml
    volumes:
      - ./kong.yml.example:/tmp/kong.yml:ro
```

```bash
docker up -d
```

### TODO / not supported
- [ ] Support same base images than the official image. Now image is based on Debian (alpine, centos)
- [ ] Support other vars than what are supported by Webhood 

