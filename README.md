# danny.is

[![CircleCI](https://circleci.com/gh/dannysmith/dannyis.svg?style=svg)](https://circleci.com/gh/dannysmith/dannyis)

### To Run

```shell
bundle install
rackup config.ru --host 0.0.0.0 --port 8080
rake scss:watch
browser-sync start --proxy 0.0.0.0:8080 --files "public/css/**/*.css, views/*.erb"
```
