# Cardano CLI Ruby wrapper

A Ruby wrapper for the Cardano Node command line interface (CLI).

It aims to support all [CLI commands](https://github.com/input-output-hk/cardano-node/blob/master/doc/reference/cardano-node-cli-reference.md). The intuitive API allows to easily call the CLI commands in a rubyish way.

Caution: This gem is under development! The API can change any time until version 1.0 is reached.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cardano-cli'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cardano-cli

## Prerequisites

### Cardano Node

You need to run a Cardano node and your Ruby application must have access to the `cardano-cli` binary.

There are different ways of setting up a node. An easy and straight forward way is to use a prepared docker image. The following command creates a new docker container.

```
docker run -d \
  --restart=unless-stopped \
  --name=relay \
  -e NODE_NAME="relay" \
  -e CARDANO_NETWORK="testnet" \
  -v $PWD/config:/config \
  arradev/cardano-pool:latest --start
```

Note: Creating a new node means syncing with the blockchain. It can take several hours until its ready unless you bootstrap the database from some other node first.

## Configuration

The configuration options can be set by using the `configure` block

```ruby
Cardano::CLI.configure do |config|
  config.network = ENV.fetch('NETWORK')
  config.cli_path = ENV.fetch('CLI_PATH')
  config.logger = MyLogger.new
end
```

In a minimal configuration, you must configure the `cli_path` because it is the essential receiver for all the commands you want to execute.

The following is the list of available configuration options with their default values

```ruby
network   # The Cardano blockchain network to connect to. Default :testnet
cli_path  # The path to the cardano-cli binary. Default nil
logger    # A Logger instance. Default: Logger.new($stdout)
```

## 1 Usage

After configuring the gem you create a new client instance

```ruby
client = Cardano::CLI.new
```

then you can call the commands.

### 1.1 Query commands

Get the node’s current tip (slot number, hash, and block number)

```ruby
client.query.tip
```

Retrieves the node’s current UTxO, filtered by address

```ruby
client.query.utxo("addr1qy...cx")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cardano-cli.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
