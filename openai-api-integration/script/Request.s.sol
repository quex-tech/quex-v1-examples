// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/OpenAIIntegration.sol";

contract RequestScript is Script {
    function run() external {
        vm.createSelectFork("arbitrum-sepolia");

        // Get parameters from environment
        uint256 privateKey = vm.envUint("SECRET");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        OpenAIIntegration target = OpenAIIntegration(payable(contractAddress));

        console.log("Contract address:", contractAddress);
        console.log("Flow id:", target.getFlowId());

        vm.startBroadcast(privateKey);
        
        target.request();
        vm.stopBroadcast();
    }
}

