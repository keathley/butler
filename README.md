Butler
======

Butler is a simple slack bot designed to make your life easier.  He's a swell guy.

## Creating your own Butler

You can install the butler archive with this command:

    $ mix archive.install https://github.com/butlerbot/butler/releases/download/v0.4.3/butler_new-0.4.3.ez

Once you've done that you can generate your robot. For instance, if you want
to name your robot `marvin` then you would run:

    $ mix butler.new marvin
    $ cd marvin
    $ mix deps.get
    $ mix run --no-halt

Congratulations! You now have your own butler.

Butler comes with a default configuration, which can be updated in `config/config.exs` or `config/ENV.exs` per environment.

### Plugins

Plugins give Butler abilities. They provide a simple api for listening for
specific commands.

### Adapters

Butler has adapters in order to talk to multiple chat platforms. The default platform
is Slack and an adapter is provided as a part of Butler.

For local development there is a terminal adapter which provides a lightweight
repl interface.

### Slack Adapter

Butler needs a slack api token in order to connect to your organization.

    $ export BUTLER_SLACK_API_KEY=your_api_key

You can then run butler in production mode.

    $ MIX_ENV=prod mix compile
    $ MIX_ENV=prod mix run --no-halt

### Deploying to Heroku

Heroku is the easiest way to deploy your bot:

First you'll need to create a new application with the elixir buildpack:

    $ heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"

Or if you've already created your application you can set the buildpack directly:

    $ heroku config:set BUILDPACK_URL="https://github.com/HashNuke/heroku-buildpack-elixir.git"

Before you deploy you need to set any environment variables that you'll need.
For the slack adapter that will be this:

    $ heroku config:set BUTLER_SLACK_API_KEY=your-api-key

You'll also have to make sure that any variables you need at compile time are
included in the elixir_buildpack.config file:

    $ cat elixir_buildpack.config
    erlang_version=17.5
    elixir_version=1.1.1
    always_rebuild=true
    config_vars_to_export=(BUTLER_SLACK_API_KEY BUTLER_SLACK_API_KEY)

If these config vars aren't included in the `config_vars_to_export` then they
won't be availble during compile time which will cause issues during runtime.

For more information on configuration you can check out the [elixir_buildpack](https://github.com/HashNuke/heroku-buildpack-elixir).

Once the configuration variables have been set its time to push:

    $ git push heroku master

You should see a lot of logging and after your bot should be up and running.

If you have any issues you can review the heroku logs:

    $ heroku logs

Your bot should now be deployed!

### Deploying to Unix

There are a number of ways to deploy to unix. The recommended way is to create
a release of Butler with [exrm](https://github.com/bitwalker/exrm) and run the
release on your vps or server of choice.

## Contributing

Butler is still a work in progress and we appreciate any contributions. If you
have questions then feel free to open an issue.

