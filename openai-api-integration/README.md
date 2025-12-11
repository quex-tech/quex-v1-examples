# OpenAI API Integration Example

This project demonstrates how to integrate OpenAI API with Quex data oracles to fetch AI-generated responses on-chain. The example sends a sentiment analysis prompt to OpenAI's chat completions API and stores the numeric sentiment score (0-100) in a Solidity contract.

## Overview

The `OpenAIIntegration` contract:
- Sends POST requests to OpenAI's chat completions endpoint
- Uses encrypted private headers to securely pass the API key
- Extracts sentiment scores from OpenAI responses
- Stores the latest sentiment score on-chain
- Emits events when new responses are received

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

To deploy contracts and interact with the data oracle, you need:

1. A wallet with gas tokens on **Arbitrum Sepolia**
2. An OpenAI API key
3. A Trust Domain (TD) address and public key that you can find [here](https://docs.quex.tech/general-information/addresses#arbitrum-sepolia)

Set your private key as an environment variable:

```shell
export SECRET=<0xYourPrivateKey>
```

**Important**: Before deploying, you need to:
1. Encrypt your OpenAI API key with a Trust Domain public key to get the encrypted API key
2. Update the `TRUST_DOMAIN` constant in `script/DeployOpenAIScript.s.sol` with your TD address
3. Set the encrypted API key as an environment variable (as hex string):

```shell
export ENCRYPTED_API_KEY=<0xEncryptedApiKeyHex>
```

To encrypt your API key, use our [sensitive data encryption tool](https://github.com/quex-tech/quex-v1-interfaces/tree/master/tools/encrypt_data) as follows:

```shell
python encrypt_data.py --data "Bearer sk-..." --td-public-key 0x71d4...
```

## Build and Deploy Contracts

Run the `DeployOpenAIScript` to build and deploy the OpenAI integration contract and create a data flow:

```shell
forge script script/DeployOpenAIScript.s.sol --broadcast --rpc-url arbitrum-sepolia
```

If successful, the output will look similar to:

```shell
Deploying from: 0x...
Trust Domain address: 0x...
OpenAIIntegration Contract Deployed at: 0x...
##### arbitrum-sepolia
✅  [Success] Hash: 0x...
Contract Address: 0x...
Block: ...
Paid: ... ETH (... gas * ... gwei)
```

We'll need the deployed contract address for further requests. Set it as an environment variable:

```shell
export CONTRACT_ADDRESS=<DEPLOYED_CONTRACT_ADDRESS>
```

## Make a Request

After deployment, make a request using the built-in script:

```shell
forge script script/Request.s.sol --broadcast --rpc-url arbitrum-sepolia
```

This will send a request to OpenAI API through Quex oracles. The contract will receive the response and store the sentiment score.

## Check the Response

You can check the stored sentiment score by calling the contract's view functions:

```solidity
// Get the latest sentiment score
uint256 score = openAIIntegration.latestSentimentScore();

// Get both score and timestamp
(uint256 score, uint256 timestamp) = openAIIntegration.getLatestSentiment();
```

Or use Foundry's cast tool:

```shell
cast call $CONTRACT_ADDRESS "latestSentimentScore()(uint256)" --rpc-url https://sepolia-rollup.arbitrum.io/rpc
cast call $CONTRACT_ADDRESS "getLatestSentiment()(uint256,uint256)" --rpc-url https://sepolia-rollup.arbitrum.io/rpc
```

## How It Works

1. **Flow Configuration**: The contract sets up a flow that:
   - Makes POST requests to `api.openai.com/v1/chat/completions`
   - Includes the API key in encrypted private headers (via Trust Domain)
   - Sends a prompt asking for a sentiment score (0-100)
   - Uses jq filter to extract the numeric response: `.choices[0].message.content | tonumber`

2. **Request Processing**: When `request()` is called:
   - A request is sent to Quex core
   - Quex oracles fetch data from OpenAI API
   - The response is processed and the sentiment score is extracted
   - The `processResponse()` callback is triggered with the score

3. **Response Storage**: The contract:
   - Validates the score is between 0-100
   - Stores it in `latestSentimentScore`
   - Updates `lastResponseTime`
   - Emits a `SentimentScoreReceived` event

## Customization

You can customize the OpenAI prompt by modifying the `body` in the `setUp()` function of `OpenAIIntegration.sol`. The current prompt asks for sentiment analysis, but you can change it to any task that returns a numeric value.

## Notes

- The API key is stored encrypted in the Trust Domain and never exposed on-chain
- The contract validates that sentiment scores are between 0-100
- Each request incurs fees for both Quex oracles and OpenAI API usage
- Make sure your subscription has sufficient balance before making requests

