// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./ParametricToken.sol";
import "./lib/QuexFlowManager.sol";
import "quex-v1-interfaces/interfaces/oracles/IRequestOraclePool.sol";
import "quex-v1-interfaces/interfaces/core/IFlowRegistry.sol";

address constant QUEX_CORE = 0xD8a37e96117816D43949e72B90F73061A868b387;
address constant ORACLE_POOL = 0x957E16D5bfa78799d79b86bBb84b3Ca34D986439;

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
        generateFlow();
    }

    /**
     * @notice Creates a new flow to fetch TVL data from the DeFi Llama API for dydx, multiplies it by 1e18,
     * and rounds to the nearest integer.
     */
    function generateFlow() private onlyOwner {
        IRequestOraclePool oraclePool = IRequestOraclePool(ORACLE_POOL);
        IFlowRegistry flowRegistry = IFlowRegistry(QUEX_CORE);

        HTTPRequest memory request = HTTPRequest({
            method: RequestMethod.Get,
            host: "api.llama.fi",
            path: "/tvl/dydx",
            headers: new RequestHeader[](0),
            parameters: new QueryParameter[](0),
            body: ""
        });
        bytes32 patchId = 0;
        bytes32 requestId = oraclePool.addRequest(request);
        bytes32 schemaId = oraclePool.addResponseSchema('uint256');
        bytes32 filterId = oraclePool.addJqFilter('. * 1000000000000000000 | round');
        uint256 actionId = oraclePool.addActionByParts(requestId, patchId, schemaId, filterId);
        Flow memory flow = Flow({
            gasLimit: 700000,
            actionId: actionId,
            pool: ORACLE_POOL,
            consumer: address(this),
            callback: this.processResponse.selector
        });
        _flowId = flowRegistry.createFlow(flow);
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