pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "quex-v1-interfaces/interfaces/core/IQuexActionRegistry.sol";
import "./ParametricToken.sol";

//TODO move to SDK?
address constant QUEX_CORE = 0xD8a37e96117816D43949e72B90F73061A868b387;
IQuexActionRegistry constant quexCore = IQuexActionRegistry(QUEX_CORE);

contract TVLEmission is Ownable {
    address private _treasury;
    uint256 private _requestId;
    uint256 public lastTVL;
    ParametricToken public parametricToken;

    constructor(address treasuryAddress) Ownable(msg.sender) {
        parametricToken = new ParametricToken();
        _treasury = treasuryAddress;
    }

    function request(uint256 flowId) public payable onlyOwner returns (uint256) {
        _requestId = quexCore.createRequest{value: msg.value}(flowId);
        return _requestId;
    }

    // On request() call this contract may receive the change from Quex Core.
    // Therefore, receive() method must be implemented
    receive() external payable {
        payable(owner()).call{value: msg.value}("");
    }


    function processResponse(uint256 receivedRequestId, DataItem memory response, IdType idType) external {
        require(msg.sender == QUEX_CORE, "Only Quex Proxy can push data");
        require(idType == IdType.RequestId, "Return type mismatch");
        require(receivedRequestId == _requestId, "Unknown request ID");
        lastTVL = abi.decode(response.value, (uint256));
        parametricToken.mint(_treasury, lastTVL);
        return;
    }
}
