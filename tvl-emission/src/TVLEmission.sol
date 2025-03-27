// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./ParametricToken.sol";
import "./lib/FlowBuilder.sol";
import "quex-v1-interfaces/src/interfaces/oracles/IRequestOraclePool.sol";
import "quex-v1-interfaces/src/interfaces/core/IFlowRegistry.sol";
import "quex-v1-interfaces/src/libraries/QuexRequestManager.sol";

using FlowBuilder for FlowBuilder.FlowConfig;

/**
 * @title TVLEmission
 * @dev This contract manages token emissions based on Total Value Locked (TVL) data retrieved from Quex.
 * It ensures that emissions can only be processed once per day to prevent excessive token minting.
 */
contract TVLEmission is QuexRequestManager {
    address private _treasuryAddress;
    ParametricToken public parametricToken;
    uint256 public lastRequestTime;
    uint256 private constant REQUEST_COOLDOWN = 1 days;

    constructor(address treasuryAddress, address quexCore, address oraclePool) QuexRequestManager(quexCore) {
        parametricToken = new ParametricToken();
        _treasuryAddress = treasuryAddress;
        setUpFlow(quexCore, oraclePool);
    }

    /**
     * @notice Creates a new flow to fetch TVL data from the DeFi Llama API for dydx, multiplies it by 1e18,
     * and rounds to the nearest integer.
     */
    function setUpFlow(address quexCore, address oraclePool) private onlyOwner {
        FlowBuilder.FlowConfig memory config = FlowBuilder.create(quexCore, oraclePool, "api.llama.fi", "/tvl/dydx");
        config = config.withFilter(". * 1000000000000000000 | round");
        config = config.withSchema("uint256");
        config = config.withCallback(address(this), this.processResponse.selector);
        registerFlow(config);
    }

    /**
     * @notice Build flow from config and register it in FlowRegistry
     */
    function registerFlow(FlowBuilder.FlowConfig memory config) public virtual onlyOwner {
        uint256 flowId = config.build();
        setFlowId(flowId);
    }

    /**
     * @notice Processes a response from Quex and mints tokens based on TVL.
     * @dev Ensures a minimum of 24 hours has passed since the last emission before minting new tokens.
     * @param receivedRequestId The ID of the request that is being processed.
     * @param response The response data from Quex, expected to contain the latest TVL value.
     */
    function processResponse(uint256 receivedRequestId, DataItem memory response, IdType idType)
        external
        verifyResponse(receivedRequestId, idType)
    {
        require(block.timestamp >= lastRequestTime + REQUEST_COOLDOWN, "Request cooldown active");
        uint256 lastTVL = abi.decode(response.value, (uint256));
        parametricToken.mint(_treasuryAddress, lastTVL);
        lastRequestTime = block.timestamp;
    }
}
