// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/ParametricToken.sol";
import "../src/TVLEmission.sol";

contract DeployTVLEmissionScript is Script {
    function run() external {
        // Prepare to broadcast contracts
        uint256 privateKey = vm.envUint("SECRET");
        address deployer = vm.addr(privateKey);
        console.log("Deploying from:", deployer);
        vm.createSelectFork("arbitrum-sepolia");
        vm.startBroadcast(privateKey);

        // Deploy TVLEmission with the deployer's address as treasury
        TVLEmission tvlEmission = new TVLEmission(deployer);
        console.log("TVLEmission Contract Deployed at:", address(tvlEmission));

        // Retrieve the ParametricToken address from TVLEmission
        address parametricTokenAddress = address(tvlEmission.parametricToken());
        console.log("ParametricToken Contract Deployed at:", parametricTokenAddress);

        console.log("===== Next steps ====");
        console.log("Save contact address to environment variables to use it in requests function:");
        console.log(string(abi.encodePacked("export CONTRACT_ADDRESS=", vm.toString(address(tvlEmission)))));

        vm.stopBroadcast();
    }
}
