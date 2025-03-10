// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/TVLEmission.sol"; // Adjust path based on your project structure

contract RequestScript is Script {
    function run() external {
        vm.createSelectFork("arbitrum-sepolia");

        // Calculate gas cost
        // TODO automate this step
        uint256 nativeFee = 30000000000000;
        uint256 gasToCover = 810000;
        uint256 gasPrice = 1879871425;
        uint256 totalFee = nativeFee + (gasPrice * gasToCover * 2);

        // Get parameters from environment
        uint256 privateKey = vm.envUint("SECRET");
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        TVLEmission target = TVLEmission(payable(contractAddress));

        console.log("Contract address:", contractAddress);
        console.log("Flow id:", contractAddress);
        console.log("Total fee:", totalFee);

        vm.startBroadcast(privateKey);
        target.request{value: totalFee}();
        vm.stopBroadcast();
    }
}