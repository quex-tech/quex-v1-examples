
## Prepare environment

Install [openzeppelin](https://docs.openzeppelin.com/contracts/5.x/) contracts:

```shell
forge install @openzeppelin/contracts
```

Install Quex interfaces:

```shell
forge install quex-tech/quex-v1-interfaces
```

Put your private key to environment variables;
```shell
export SECRET=0xYourPrivateKey
```


## Build and deploy contracts

Expect response like:
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
Remember the "Contract Address" value, we'll need it later. Let's put it into environment:
```shell
export CONTRACT_ADDRESS=0x48E5b08F29c8CB32A55610F10b244cf9f97e38CA
```


