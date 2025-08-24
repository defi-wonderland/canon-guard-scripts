// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ISafeEntrypoint} from "canon-guard/ISafeEntrypoint.sol";

import {ISafeMinimal} from "../interfaces/ISafeMinimal.sol";
import {CanonRegistry} from "./constants.sol";

contract IsGuardSetup is Script {

    function setUp() public {}

    function run() public {
        ISafeMinimal safe = ISafeMinimal(vm.envAddress("SAFE"));

        console.log("Safe: ", address(safe));
        console.log("Test: ", CanonRegistry.SAFE_ENTRYPOINT_FACTORY_OLD);

        // Compute the guard storage slot and read it from the Safe
        bytes32 guardSlot = keccak256(bytes("guard_manager.guard.address"));
        bytes32 raw = vm.load(address(safe), guardSlot);
        address guard = address(uint160(uint256(raw)));

        if (guard == address(0)) {
            console.log("Canon Guard is not configured");
        } else {
            // TODO: check if it is really a Canon Guard
            console.log("Guard %s configured", guard);
        }

        vm.startBroadcast();
        vm.stopBroadcast();
    }
}
