
![](./assets/artemis.png)


[![CI status](https://github.com/paradigmxyz/reth/workflows/ci/badge.svg)][gh-ci]
[![Telegram Chat][tg-badge]][tg-url]

[gh-ci]: https://github.com/paradigmxyz/reth/actions/workflows/rust.yml
[tg-badge]: https://img.shields.io/badge/chat-telegram-blue

## What is Artemis?

Artemis is a framework for writing MEV bots in Rust. It's designed to be simple, modular, and fast. 

At its core, Artemis is architected as an event processing pipeline. The library is made up of three main components: 

1. *Collectors*: *Collectors* take in external events (such as pending txs, new blocks, marketplace orders, etc. ) and turn them into an internal *event* representation. 
2. *Strategies*: *Strategies* contain the core logic required for each MEV opportunity. They take in *events* as inputs, and compute whether any opportunities are available (for example, a strategy might listen to a stream of marketplace orders to see if there are any cross-exchange arbs). *Strategies* produce *actions*.
3. *Executors*: *Executors* process *actions*, and are responsible for executing them in different domains (for example, submitting txs, posting off-chain orders, etc.).

## Strategies 

The following strategies have been implemented: 

- [Opensea/Sudoswap NFT Arbitrage](/crates/strategies/opensea-sudo-arb/): A strategy implementing atomic, cross-market NFT arbitrage between Seaport and Sudoswap.

## Build, Test and Run

First, make sure the following are installed: 
1. [Anvil](https://github.com/foundry-rs/foundry/tree/master/crates/anvil#installing-from-source)

In order to build, first clone the github repo: 

```sh
git clone https://github.com/paradigmxyz/artemis
cd artemis
```

Next, run tests with cargo: 

```sh
cargo test --all
```

In order to run the opensea sudoswap arbitrage strategy, you can run the following command: 

```sh
cargo run -- --wss <INFURA_OR_ALCHEMY_KEY> --opensea-api-key <OPENSEA_API_KEY> --private-key <PRIVATE_KEY> --arb-contract-address <ARB_CONTRACT_ADDRESS> --bid-percentage <BID_PERCENTAGE>
```

where `ARB_CONTRACT_ADDRESS` is the address to which you deploy the [arb contract](/crates/strategies/opensea-sudo-arb/contracts/src/SudoOpenseaArb.sol).

## Deployment

## Deployment

### Quick Start

**TL;DR:** Deploy Artemis in 3 steps:

1. `cp .env.example .env` and configure your settings
2. `./deploy.sh` 
3. Monitor at http://localhost:3000 (admin/artemis)

### Docker Deployment (Recommended)

The easiest way to deploy Artemis is using pre-built Docker images:

1. **Pull the latest image:**
   ```sh
   docker pull ghcr.io/zpecoin/artemis:main
   ```

2. **Set up environment configuration:**
   ```sh
   cp .env.example .env
   nano .env  # Edit with your configuration
   ```

3. **Run with Docker Compose:**
   ```sh
   cd docker
   docker-compose up -d
   ```

### Development Deployment

For development or if you want to build from source:

1. **Prerequisites:**
   - Rust 1.70+ with nightly toolchain
   - Docker and Docker Compose
   - Git with SSH keys configured for GitHub

2. **Clone and setup:**
   ```sh
   git clone https://github.com/ZPECOIN/artemis
   cd artemis
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Use the deployment script:**
   ```sh
   ./deploy.sh
   ```

**Note:** Due to dependency issues with some Git repositories, building from source may require SSH access to private repositories. For production deployments, use the pre-built Docker images.

### Production Deployment

For production environments:

1. **Use the pre-built Docker images:**
   ```sh
   docker pull ghcr.io/zpecoin/artemis:latest
   ```

2. **Set up your environment configuration:**
   - Copy `.env.example` to `.env`
   - Configure all required variables (see table below)
   - Ensure your arbitrage contract is deployed and funded

3. **Deploy with proper security:**
   ```sh
   # Use docker-compose with production configuration
   cd docker
   docker-compose -f docker-compose.yml up -d
   ```

4. **Monitor your deployment:**
   - Grafana: http://localhost:3000 (admin/artemis)
   - Prometheus: http://localhost:9090
   - View logs: `docker-compose logs -f artemis`

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `WSS` | Ethereum WebSocket RPC endpoint | `wss://eth-mainnet.alchemyapi.io/v2/YOUR_KEY` |
| `OPENSEA_API_KEY` | OpenSea API key | `your_opensea_api_key` |
| `PRIVATE_KEY` | Private key for signing transactions | `0x123...` |
| `ARB_CONTRACT_ADDRESS` | Deployed arbitrage contract address | `0x123...` |
| `BID_PERCENTAGE` | Percentage of profit to pay in gas | `20` |
| `RUST_LOG` | Logging level (optional) | `info` |

### Prerequisites

- Docker and Docker Compose
- Deployed arbitrage contract (see [contract deployment guide](/crates/strategies/opensea-sudo-arb/contracts/))
- Ethereum RPC endpoint (Infura, Alchemy, or self-hosted)
- OpenSea API key
- Funded wallet for gas fees

### Security Notes

- **Never commit your `.env` file to version control**
- Keep your private key secure and use a dedicated wallet
- Monitor your bot's performance and gas usage
- Consider using environment-specific private keys for different deployments


## Acknowledgements

- [subway](https://github.com/libevm/subway)
- [subway-rs](https://github.com/refcell/subway-rs)
- [cfmms-rs](https://github.com/0xKitsune/cfmms-rs)
- [rusty-sando](https://github.com/mouseless-eth/rusty-sando)
- [bundle-generator](https://github.com/Alcibiades-Capital/mev_bundle_generator/blob/master/Cargo.toml)
- [ethers-rs](https://github.com/gakonst/ethers-rs)
- [ethers-flashbots](https://github.com/onbjerg/ethers-flashbots)



[tg-url]: https://t.me/artemis_devs
