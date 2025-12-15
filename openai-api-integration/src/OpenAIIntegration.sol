// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "quex-v1-interfaces/src/libraries/QuexRequestManager.sol";

using FlowBuilder for FlowBuilder.FlowConfig;

/**
 * @title OpenAIIntegration
 * @dev This contract demonstrates how to integrate OpenAI API with Quex data oracles.
 * It fetches sentiment analysis scores from OpenAI and stores them on-chain.
 */
contract OpenAIIntegration is QuexRequestManager {
    /// @notice Stores the latest sentiment score received from OpenAI
    uint256 public latestSentimentScore;
    
    /// @notice Stores the timestamp of the last successful response
    uint256 public lastResponseTime;
    
    /// @notice Event emitted when a new sentiment score is received
    event SentimentScoreReceived(uint256 requestId, uint256 score, uint256 timestamp);

    constructor(address quexCore, address oraclePool, address tdAddress, bytes memory encryptedApiKey) payable QuexRequestManager(quexCore) {
        setUp(quexCore, oraclePool, tdAddress, encryptedApiKey);
    }

    /**
     * @notice Creates a new flow to fetch sentiment analysis from OpenAI API.
     * The flow sends a POST request to OpenAI's chat completions endpoint with a prompt
     * asking for a sentiment score (0-100), and extracts the numeric response.
     * @param quexCore Address of the Quex Core contract
     * @param oraclePool Address of the Oracle Pool contract
     * @param tdAddress Address of the Trust Domain that encrypted the API key
     * @param encryptedApiKey The encrypted API key (format: "Bearer sk-...") as bytes
     */
    function setUp(address quexCore, address oraclePool, address tdAddress, bytes memory encryptedApiKey) private onlyOwner {
        require(msg.value > 0, "Please attach some Eth to deposit subscription");
        require(encryptedApiKey.length > 0, "Encrypted API key cannot be empty");

        // Set up public headers
        RequestHeader[] memory headers = new RequestHeader[](1);
        headers[0] = RequestHeader({key: "Content-Type", value: "application/json"});

        // Set up private headers for API key (encrypted)
        RequestHeaderPatch[] memory privateHeaders = new RequestHeaderPatch[](1);
        privateHeaders[0] = RequestHeaderPatch({
            key: "Authorization",
            ciphertext: encryptedApiKey
        });

        // Set up request body with prompt for sentiment analysis
        bytes memory body = bytes('{"model":"gpt-5-nano-2025-08-07","messages":[{"role":"user","content":"Rate the sentiment of the following text on a scale of 0-100, where 0 is very negative and 100 is very positive. Return only the number: The cryptocurrency market is showing strong bullish signals today."}]}');

        // Set up flow
        FlowBuilder.FlowConfig memory config = FlowBuilder.create(quexCore, oraclePool, "api.openai.com", "/v1/chat/completions");
        config = config.withMethod(RequestMethod.Post);
        config = config.withHeaders(headers);
        config = config.withBody(body);
        config = config.withTdAddress(tdAddress);
        config = config.withPrivateHeaders(privateHeaders);
        // Extract the numeric sentiment score from the response
        // OpenAI returns: {"choices":[{"message":{"content":"75"}}]}
        // We extract just the number
        config = config.withFilter(".choices[0].message.content | tonumber | round");
        config = config.withSchema("uint256");
        config = config.withCallback(address(this), this.processResponse.selector);
        registerFlow(config);

        // Set up subscription that will be used to charge fees
        createSubscription(msg.value);
    }

    /**
     * @notice Processes a response from Quex containing the sentiment score from OpenAI.
     * @param receivedRequestId The ID of the request that is being processed.
     * @param response The response data from Quex, expected to contain the sentiment score (0-100).
     */
    function processResponse(uint256 receivedRequestId, DataItem memory response, IdType idType) 
        external 
        verifyResponse(receivedRequestId, idType) 
    {
        uint256 sentimentScore = abi.decode(response.value, (uint256));
        require(sentimentScore <= 100, "Invalid sentiment score");
        
        latestSentimentScore = sentimentScore;
        lastResponseTime = block.timestamp;
        
        emit SentimentScoreReceived(receivedRequestId, sentimentScore, block.timestamp);
    }

    /**
     * @notice Retrieves the latest sentiment score and timestamp
     * @return score The latest sentiment score (0-100)
     * @return timestamp The timestamp when the score was received
     */
    function getLatestSentiment() external view returns (uint256 score, uint256 timestamp) {
        return (latestSentimentScore, lastResponseTime);
    }
}

