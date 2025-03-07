pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "quex-v1-interfaces/interfaces/core/IQuexActionRegistry.sol";

address constant QUEX_CORE = 0xD8a37e96117816D43949e72B90F73061A868b387;
IQuexActionRegistry constant quexCore = IQuexActionRegistry(QUEX_CORE);

contract TVLEmission is Ownable {
    constructor() Ownable(msg.sender) {}
    uint256 requestId;

    // We will track the requests performed by the unique request Id assigned by Quex
    // Only keep the latest request Id
    function request(uint256 flowId) public payable onlyOwner returns(uint256) {
        requestId = quexCore.createRequest{value:msg.value}(flowId);
        return requestId;
    }
}
