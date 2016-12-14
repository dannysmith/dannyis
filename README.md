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

### Environment Variables

Ensure you have the following environment variables set, either in a `.env` file or locally. Be sure to push these to heroku. `dotenv-heroku` provides rake tasks to do this.

```shell
BASE_DOMAIN # Base domain of the deployed site. In my case, this is 'danny.is'.
MONGODB_URI # URI of a valid MongoDB instance.
NEW_RELIC_LICENSE_KEY # New Relic licence key.
NEW_RELIC_LOG # New Relic log level. You can leave this as 'stdout'.
PUMA_WORKERS # The number of puma workers to use. You should probably set this as 1 in development.
IFTTT_POST_TOKEN # A random string that IFTTT webhooks must provide in order to POST.
REDIS_URL # URI of a valid Redis instance.
```
