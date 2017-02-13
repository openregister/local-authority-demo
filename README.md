# OpenRegister Local Authority Demo

## Deployment

To setup a fresh heroku deployment:

```sh
heroku create --region eu \
       --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git" \
       --org <org>

heroku apps:rename <your-app-name>

heroku config:set DATA_FILE=local-authority-data/master/data/local-authority-eng/local-authorities.tsv \
                  MAPS_PATH=local-authority-data/master/maps \
                  LISTS_PATH=local-authority-data/master/lists \
                  HOST=<host domain> \
                  POOL_SIZE=18 \
                  SECRET_KEY_BASE="`mix phoenix.gen.secret`"

git push heroku master

heroku open
```

## Local Development

To start the Phoenix app locally:

```sh
export DATA_FILE=local-authority-data/master/data/local-authority-eng/local-authorities.tsv
export MAPS_PATH=local-authority-data/master/maps
export LISTS_PATH=local-authority-data/master/lists
```

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
