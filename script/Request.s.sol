// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/TVLEmission.sol"; // Adjust path based on your project structure

contract RequestScript is Script {
    function run() external {
        uint256 nativeFee = 60000000000000;
        uint256 gasToCover = 810000;
        uint256 gasPrice = 1879871425;

//        uint256 flowId = vm.envUint("FLOW_ID"); // Load input value from env
        uint256 flowId = 0x0000000000000000000000000000000000000000000000000000000000000017;

        vm.createSelectFork("arbitrum-sepolia");
        uint256 privateKey = vm.envUint("SECRET"); // Load private key from env
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS"); // Load contract address
        TVLEmission target = TVLEmission(payable(contractAddress));

        uint256 totalFee = nativeFee + (gasPrice * gasToCover * 2);

        console.log("Flow id:", flowId);
        console.log("Gas price:", gasPrice);
        console.log("Total fee:", totalFee);

        vm.startBroadcast(privateKey);
        target.request{value: totalFee}(flowId);
        vm.stopBroadcast();
    }
}