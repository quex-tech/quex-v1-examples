// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./ParametricToken.sol";
import "./lib/QuexFlowManager.sol";

address constant QUEX_CORE = 0xD8a37e96117816D43949e72B90F73061A868b387;

/**
 * @title TVLEmission
 * @dev This contract manages token emissions based on Total Value Locked (TVL) data retrieved from Quex.
 * It ensures that emissions can only be processed once per day to prevent excessive token minting.
 */
contract TVLEmission is QuexFlowManager {
    address private _treasuryAddress;
    ParametricToken public parametricToken;
    uint256 public lastRequestTime;
    uint256 private constant REQUEST_COOLDOWN = 1 days;

    constructor(address treasuryAddress) QuexFlowManager(QUEX_CORE) {
        parametricToken = new ParametricToken();
        _treasuryAddress = treasuryAddress;
    }

    /**
     * @notice Processes a response from Quex and mints tokens based on TVL.
     * @dev Ensures a minimum of 24 hours has passed since the last emission before minting new tokens.
     * @param receivedRequestId The ID of the request that is being processed.
     * @param response The response data from Quex, expected to contain the latest TVL value.
     */
    function processResponse(uint256 receivedRequestId, DataItem memory response, IdType /* idType */)
    external verifyResponse(receivedRequestId)
    {
        require(block.timestamp >= lastRequestTime + REQUEST_COOLDOWN, "Request cooldown active");
        uint256 lastTVL = abi.decode(response.value, (uint256));
        parametricToken.mint(_treasuryAddress, lastTVL);
        lastRequestTime = block.timestamp;
    }
}