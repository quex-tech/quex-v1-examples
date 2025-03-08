pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "quex-v1-interfaces/interfaces/core/IQuexActionRegistry.sol";
import "./ParametricToken.sol";

//TODO move to SDK?
address constant QUEX_CORE = 0xD8a37e96117816D43949e72B90F73061A868b387;
IQuexActionRegistry constant quexCore = IQuexActionRegistry(QUEX_CORE);

struct FlowResponse {
    uint256 timestamp;
    uint256 currentTVL;
}


contract TVLEmission is Ownable {
    address private _treasury;
    uint256 private _requestId;
    FlowResponse lastUpdate;
    ParametricToken parametricToken;

    constructor(address treasuryAddress) Ownable(msg.sender) {
        parametricToken = new ParametricToken();
        _treasury = treasuryAddress;
    }

    // We will track the requests performed by the unique request Id assigned by Quex
    // Only keep the latest request Id
    function request(uint256 flowId) public payable onlyOwner returns (uint256) {
        _requestId = quexCore.createRequest{value: msg.value}(flowId);
        return _requestId;
    }

    // Callback handling the data processing logic
    function processResponse(uint256 receivedRequestId, DataItem memory response, IdType idType) external {
        // Verify that the sender is indeed Quex
        require(msg.sender == QUEX_CORE, "Only Quex Proxy can push data");
        // Verify that the request was initiated on-chain, rather than off-chain
        require(idType == IdType.RequestId, "Return type mismatch");
        // Verify that the response corresponds to our request
        require(receivedRequestId == _requestId, "Unknown request ID");
        // Use the data. Decode and mint tokens
        lastUpdate = abi.decode(response.value, (FlowResponse));
        parametricToken.mint(_treasury, lastUpdate.currentTVL);
        return;
    }
}
