# Bitbucket Pipelines PHP 7.0 image

[![](https://images.microbadger.com/badges/version/imposibrus/bitbucket-pipelines-php7.svg)](https://microbadger.com/images/imposibrus/bitbucket-pipelines-php7 "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/imposibrus/bitbucket-pipelines-php7.svg)](https://microbadger.com/images/imposibrus/bitbucket-pipelines-php7 "Get your own image badge on microbadger.com")

## Based on Ubuntu 16.04

### Packages installed

- `php7.0-fpm`, `php7.0-mcrypt`, `mongod`, `xdebug`, `php7.0-zip`, `php7.0-xml`, `php7.0-mbstring`, `php7.0-curl`, `php7.0-json`, `php7.0-imap`, `php7.0-mysql` and `php7.0-tokenizer`
- [Composer](https://getcomposer.org/)
- [Deployer](https://github.com/deployphp/deployer)
- Node / NPM
- Mysql 5.7

### Sample `bitbucket-pipelines.yml`

```YAML
image: imposibrus/bitbucket-pipelines-php7:1.2.0
pipelines:
  default:
    - step:
        script:
          - service mysql start
          - mysql -h localhost -u root -proot -e "CREATE DATABASE test;"
          - composer install --no-interaction --no-progress --prefer-dist
          - npm install --no-spin
          - ./node_modules/.bin/gulp
          - ./vendor/phpunit/phpunit/phpunit -v --coverage-text --colors=never --stderr
```
