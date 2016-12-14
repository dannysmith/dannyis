# danny.is

[![CircleCI](https://circleci.com/gh/dannysmith/dannyis.svg?style=svg)](https://circleci.com/gh/dannysmith/dannyis)

### To Run

```shell
brew services start redis # Or set REDIS_URL to point to a remote redis instance.
bundle install
rackup config.ru --host 0.0.0.0 --port 8080
rake scss:watch
browser-sync start --proxy 0.0.0.0:8080 --files "public/css/**/*.css, views/*.erb"
```

We can add the `--tunnel` option to browser-synch to get an external URL for sharing with others.
