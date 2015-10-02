Butler
======

Butler is a simple slack bot designed to make your life easier.  He's a swell guy.

## Creating your own Butler

You can install the butler archive with this command:

    $ mix archive.install https://github.com/butlerbot/butler/releases/download/v0.4.2/butler_new-0.4.2.ez

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

## Contributing

Butler is still a work in progress and we appreciate any contributions. If you
have questions then feel free to open an issue.

