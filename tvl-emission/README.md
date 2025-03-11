# Intro

This project demonstrates how to use Quex data oracles to issue parametric emission tokens. Check the exploration of this example in our [documentation](https://docs.quex.tech/developers/getting_started).  
It includes Solidity contracts that implement ERC-20 token emissions, where the number of tokens issued corresponds to the Total Value Locked (TVL) of the DYDX protocol, as reported by [DeFiLlama](https://defillama.com/protocol/dydx).

## Set Up

Ensure that [Foundry](https://book.getfoundry.sh) (Forge) is correctly installed and up to date. You can update Foundry by running:

```shell
foundryup
```

Then, install the project dependencies using Forge:
```shell
forge install
```

## Prepare Environment

To deploy contracts and interact with the data oracle, you need a wallet with gas tokens on **Arbitrum Sepolia**. Set your private key as an environment variable for further use:

```shell
export SECRET=<0xYourPrivateKey>
```

## Build and Deploy Contracts

Run the `DeployTVLEmissionScript` to build and deploy the ERC-20 token, the token emission contract, and create a data flow for verifiable Quex HTTPS responses:

```shell
forge script script/DeployTVLEmissionScript.s.sol --broadcast
```

If successful, the output will look similar to:

```shell
TVLEmission Contract Deployed at: 0x48E5b08F29c8CB32A55610F10b244cf9f97e38CA
ParametricToken Contract Deployed at: 0x6610E92439205f047f0986fb8686A98A6291aE2D
...
##### arbitrum-sepolia
✅  [Success] Hash: 0x0325eedc650ccd32b02157c9717080a9c64543b5a40d3011b56945b5b5e2e91f
Contract Address: 0x48E5b08F29c8CB32A55610F10b244cf9f97e38CA
Block: 130537449
Paid: 0.0001908059 ETH (1908059 gas * 0.1 gwei)

✅ Sequence #1 on arbitrum-sepolia | Total Paid: 0.0001908059 ETH (1908059 gas * avg 0.1 gwei)
```

We'll need the deployed contract address (`0x48E5...E38CA` in this example) for further requests. Set it as an environment variable:

```shell
export CONTRACT_ADDRESS=<DEPLOYED_CONTRACT_ADDRESS>
```

## Make a Request

After that, make a request using the built-in script:

```shell
forge script script/Request.s.sol --broadcast
```

## Check Your Balance

Wait for a short period of time and check your balance - you'll receive freshly minted `TVLT` tokens in the amount equivalent to the current TVL of the DyDx protocol!