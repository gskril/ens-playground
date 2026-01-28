// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {BulkRegistrar} from "../src/BulkRegistrar.sol";

// source .env
// forge script script/BulkRegistrar.s.sol:BulkRegistrarScript --chain mainnet --rpc-url http://localhost:8545 --broadcast --unlocked --sender ${DEPLOYER_ADDRESS}
//
// forge verify-contract --chain mainnet --etherscan-api-key "${ETHERSCAN_API_KEY}" --watch <contract-address>
// src/BulkRegistrar.sol:BulkRegistrar
contract BulkRegistrarScript is Script {
    BulkRegistrar public bulkRegistrar;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        bulkRegistrar = new BulkRegistrar{salt: 0}();

        vm.stopBroadcast();
    }
}
