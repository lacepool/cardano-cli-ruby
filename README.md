# Cardano CLI Ruby wrapper

A Ruby wrapper for the Cardano Node command line interface (CLI).

It aims to support most [CLI commands](https://github.com/input-output-hk/cardano-node/blob/master/doc/reference/cardano-node-cli-reference.md). The intuitive API allows to easily call the CLI commands in a rubyish way.

Even though you can always just use the provided methods for triggering the commands on the cardano-cli,  this library also adds some convienence layer on top of it possibly making your life easier.

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
  -e CARDANO_NODE_SOCKET_PATH="/node-ipc/node.socket" \
  -v /node-ipc:/node-ipc \
  -v /config:/config \
  arradev/cardano-pool:latest --start
```

Note: Creating a new node means syncing with the blockchain. It can take several hours until its ready unless you bootstrap the database from some other node first.

## Configuration

The configuration options can be set by using the `configure` block

```ruby
Cardano::CLI.configure do |config|
  config.network = ENV.fetch('NETWORK')
  config.cli_path = ENV.fetch('CLI_PATH')
  config.root_path = ENV.fetch('ROOT_PATH')
  config.logger = MyLogger.new
end
```

The following list shows available configuration options with their default values

| config      | description                                             | default value         |
| ------------| ------------------------------------------------------- | --------------------- |
| `network`   | The Cardano blockchain network to connect storing       | `:testnet`            |
| `cli_path`  | The path to the cardano-cli binary                      | `nil`                 |
| `root_path` | The path for storing all relevant files and sub folders | `nil`                 |
| `logger`    | A Logger instance                                       | `Logger.new($stdout)` |

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

Retrieves the node’s current pool parameters

```ruby
client.query.protocol_params
```

### 1.2 Wallets / Addresses

The current implementation supports a rudimentary concept of wallets and addresses. A set of public and private keys is what we call a wallet here.

It is on the roadmap to support a more sophisticated way of managing wallets, probably by pulling in `cardano-wallet` as another dependency.

#### Create keys
Create a new payment key-pair (aka wallet) and a first payment address

```ruby
wallet = client.wallets.create("my-wallet")
```

Alternatively, if you only want to create the wallet keys but no payment address, you can pass the following keyword argument: `without_payment_address: true`

```ruby
# returns Wallet
wallet = client.wallets.create("my-wallet", without_payment_address: true)
```

### Payment addresses

List all payment addresses objects belonging to a wallet

```ruby
# returns [Address]
addresses = wallet.payment_addresses
```

Create a new payment addresses for a wallet

```ruby
# returns Address
address = wallet.create_payment_address
```

Retrieve more information about an address

```ruby
# returns Hash
address.info
```

Retrieve the hash for an address key

```ruby
# returns String
address.key_to_hash
```

### Transactions

You can either build a transaction manually as if you were using the cardano-cli, or you can make use of the provided methods sparing you some manual steps.

Creating transactions requires thinking about coin selection. This library implements the Random-Improve algorithm researched by [Edsko de Vries](https://twitter.com/EdskoDeVries) and specified as [CIP#2](https://cips.cardano.org/cips/cip2/) by the cardano-wallet team.

Caution: Currently, the coin selection process is not thread safe and you should build and submit transactions sequentially.

Examples

```ruby
# Transaction with only 1 output
tx = wallet.transactions.create(to: "addr1...", lovelace: 5_000_000)

# Transaction with multiple outputs
outputs = [
    { to: "addr1abc..", lovelace: 50_000_000 },
    { to: "addr1def..", lovelace: 10_000_000 },
    { to: "addr1ghi..", lovelace: 20_000_000 },
]
tx = wallet.transactions.create(outputs)

# Building the transaction manually, with only 1 output
tx = Cardano::CLI::Commands::Transaction.new(wallet: wallet, to: "addr1..", lovelace: 5_000_000, ttl: 1200)
draft_file_path = tx.draft
fees = tx.calculate_fees
change = tx.calculate_change
raw_file_path = tx.build
signed_file_path = tx.sign

tx.submit
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cardano-cli.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
