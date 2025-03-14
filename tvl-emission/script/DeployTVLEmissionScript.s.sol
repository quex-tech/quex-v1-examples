// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/ParametricToken.sol";
import "../src/TVLEmission.sol";

address constant QUEX_CORE = 0xD8a37e96117816D43949e72B90F73061A868b387;
address constant ORACLE_POOL = 0x957E16D5bfa78799d79b86bBb84b3Ca34D986439;

contract DeployTVLEmissionScript is Script {
    function run() external {
        // Prepare to broadcast contracts
        uint256 privateKey = vm.envUint("SECRET");
        address deployer = vm.addr(privateKey);
        console.log("Deploying from:", deployer);
        vm.createSelectFork("arbitrum-sepolia");
        vm.startBroadcast(privateKey);

        // Deploy TVLEmission with the deployer's address as treasury
        TVLEmission tvlEmission = new TVLEmission(deployer, QUEX_CORE, ORACLE_POOL);
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
