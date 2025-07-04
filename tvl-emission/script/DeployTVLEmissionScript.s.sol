// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/ParametricToken.sol";
import "../src/TVLEmission.sol";

address constant QUEX_CORE = 0x97076a3c0A414E779f7BEC2Bd196D4FdaADFDB96;
address constant ORACLE_POOL = 0xE83bB2038F098E7aD40DC03298F4337609E6b0d5;

contract DeployTVLEmissionScript is Script {
    function run() external {
        // Prepare to broadcast contracts
        uint256 privateKey = vm.envUint("SECRET");
        address deployer = vm.addr(privateKey);
        uint256 deposit = 500000000000000;

        console.log("Deploying from:", deployer);
        vm.startBroadcast(privateKey);

        // Deploy TVLEmission with the deployer's address as treasury
        TVLEmission tvlEmission = new TVLEmission{value: deposit}(deployer, QUEX_CORE, ORACLE_POOL);
        console.log("TVLEmission Contract Deployed at:", address(tvlEmission));

        // Retrieve the ParametricToken address from TVLEmission
        address parametricTokenAddress = address(tvlEmission.parametricToken());
        console.log("ParametricToken Contract Deployed at:", parametricTokenAddress);

        // For tet purposes we make arequest to Quex core and withdraw money from the subscription
        tvlEmission.request();
        tvlEmission.withdraw();
        vm.stopBroadcast();
    }
}
