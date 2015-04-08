# yargui

Edit the `config/redis.yml` file with your various evironment details.

Then run (`RAILS_ENV` optional):

    RAILS_ENV=staging rails s Puma

Open your browser to

    http://localhost:3000


## Usage

The front-end web app uses websockets to communicate with the Rails application and acts as a bridge to your Redis server.

The front-end is composed of a table view and a JS-powered terminal. When you load the page, the table will load in all the keys in Redis and the data type of the key. Future versions will surface more usefull options like the ability to quickly delete a key or change it's value.

Any Redis command can be run via the terminal. The terminal command to use is `redis` and the next string sent should represent a method on a [redis-rb](https://github.com/redis/redis-rb/blob/master/lib/redis.rb) client (since this is a wrapper for the Ruby client). A couple commands have enhanced responses.


### Examples:

Load all keys into the table:

    redis keys

Load keys using matching a pattern:

    redis keys "my:keys:*"

Set the value of a key, with a TTL:

    redis set "foo", "bar", ex: 3

Get the value of a key (also returns extra details):

    redis get "foo"

Delete a key

    redis del "foo"
