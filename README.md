# yargui

You had a problem with Redis administration so you downloaded a Redis GUI. Now you have to problems!

## Configuration

Edit the `config/redis.yml` file with your various evironment details.

Then run (`RAILS_ENV` optional):

    RAILS_ENV=staging rails s puma

Open your browser to

    http://localhost:3000


## Usage

The front-end web app uses websockets to communicate with the Rails application and acts as a bridge to your Redis server.

The front-end is composed of a table view and a JS-powered terminal. When you load the page, the table will load in all the keys in Redis and the data type of the key. Future versions will surface more usefull options like the ability to quickly delete a key or change it's value.

Any [Redis command](http://redis.io/commands) can be run via the terminal. The terminal command to use is `redis` and the next string sent should represent a method on a [redis-rb](https://github.com/redis/redis-rb/blob/master/lib/redis.rb) client (since this is a wrapper for the Ruby client). A couple commands have enhanced responses.


### Examples:

Load all keys into the table:

    yargui> redis keys

Load keys using matching a pattern:

    yargui> redis keys "my:keys:*"

Set the value of a key, with a TTL:

    yargui> redis set "foo", "bar", ex: 3

Get the value of a key (also returns extra details):

    yargui> redis get "foo"

Delete a key

    yargui> redis del "foo"


## Deployment

Yargui **should NOT be deployed** to production or even staging and is intended to be **run locally as a development tool**. The application makes calls to Redis using the `[KEYS](http://redis.io/commands/keys)` command, which can cause performance issues if the size of the database is very large.

## Future Goals

* Quick-delete options on all table rows
* Viewing and editing of keys, sets, lists, and hashes
* Powerful filtering and bulk editing commands
* Real-time monitoring of new/changing keys (this might be tough)
* Gemify and make it work similar to Sidekiq::Web
