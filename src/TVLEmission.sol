// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./ParametricToken.sol";
import "./lib/QuexFlowManager.sol";

address constant QUEX_CORE = 0xD8a37e96117816D43949e72B90F73061A868b387;

contract TVLEmission is QuexFlowManager {
    address private _treasuryAddress;
    ParametricToken public parametricToken;

    constructor(address treasuryAddress) QuexFlowManager(QUEX_CORE) {
        parametricToken = new ParametricToken();
        _treasuryAddress = treasuryAddress;
    }

    function processResponse(uint256 receivedRequestId, DataItem memory response, IdType /* idType */)
    external verifyResponse(receivedRequestId)
    {
        uint256 lastTVL = abi.decode(response.value, (uint256));
        parametricToken.mint(_treasuryAddress, lastTVL);
    }
}