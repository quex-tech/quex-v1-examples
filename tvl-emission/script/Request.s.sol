// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/TVLEmission.sol"; // Adjust path based on your project structure

contract RequestScript is Script {
    function run() external {
        vm.createSelectFork("arbitrum-sepolia");

        // Get parameters from environment
        uint256 privateKey = vm.envUint("SECRET");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        TVLEmission target = TVLEmission(payable(contractAddress));

        console.log("Contract address:", contractAddress);
        console.log("Flow id:", contractAddress);

        vm.startBroadcast(privateKey);
        target.request();
        vm.stopBroadcast();
    }
}
