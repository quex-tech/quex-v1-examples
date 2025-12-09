// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/OpenAIIntegration.sol";

address constant QUEX_CORE = 0x97076a3c0A414E779f7BEC2Bd196D4FdaADFDB96;
address constant ORACLE_POOL = 0xE83bB2038F098E7aD40DC03298F4337609E6b0d5;
address constant TRUST_DOMAIN = 0xB86EeAe9e3F0D3a91cE353CB0EfEaFF17CF16E6f;

contract DeployOpenAIScript is Script {
    function run() external {
        // Prepare to broadcast contracts
        uint256 privateKey = vm.envUint("SECRET");
        address deployer = vm.addr(privateKey);
        uint256 deposit = 1_000_000_000_000_000_000_000;

        // Get encrypted API key from environment variable
        // The encrypted API key should be provided as hex string (e.g., "0x...")
        // Format should be: "Bearer sk-..." (encrypted by Trust Domain public key)
        bytes memory encryptedApiKey = vm.envBytes("ENCRYPTED_API_KEY");

        console.log("Deploying from:", deployer);
        console.log("Trust Domain address:", TRUST_DOMAIN);
        console.log("Encrypted API key length:", encryptedApiKey.length);
        vm.startBroadcast(privateKey);

        // Deploy OpenAIIntegration contract
        OpenAIIntegration openAIIntegration = new OpenAIIntegration{value: deposit}(
            QUEX_CORE,
            ORACLE_POOL,
            TRUST_DOMAIN,
            encryptedApiKey
        );
        console.log("OpenAIIntegration Contract Deployed at:", address(openAIIntegration));

        // For test purposes we make a request to Quex core and withdraw money from the subscription
        openAIIntegration.request();
        vm.stopBroadcast();
    }
}

