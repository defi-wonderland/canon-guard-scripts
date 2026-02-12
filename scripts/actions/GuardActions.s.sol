// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {console} from "forge-std/console.sol";
import {ICanonGuard} from '@canon-guard/ICanonGuard.sol';
import {ISimpleActions} from '@canon-guard/actions-builders/ISimpleActions.sol';
import {BasicActions} from "./BasicActions.s.sol";
import {CanonRegistry} from "../Constants.s.sol";

contract GuardActions is BasicActions {

    function isGuardSetup() view public {
        if (address(canonGuard) == address(0)) {
            console.log("Canon Guard is not configured");
        } else {
            if (_isValidCanonGuard(address(canonGuard))) {
                console.log("Yes! Canon Guard %s is configured", address(canonGuard));
            } else {
                console.log("Warning: Guard %s is configured but is not a valid Canon Guard, since it was not deployed from a supported Factory address", address(canonGuard));
            }
        }
    }

    function setupGuard() public {
        if (address(canonGuard) != address(0)) {
            console.log("Canon Guard is already attached to the Safe");
            return;
        }

        // Ensure Canon guard address is being logged as detached
        isCanonGuardDetached = true;

        uint256 shortTxExecutionDelay = vm.parseUint(vm.prompt("How long in seconds should you SHORT execution delay be? In seconds"));
        uint256 longTxExecutionDelay = vm.parseUint(vm.prompt("How long in seconds should you LONG execution delay be? In seconds"));
        uint256 txExpiryDelay = vm.parseUint(vm.prompt("From the moment a transaction is executable, how long until it expires? In seconds"));
        uint256 maxApprovalDuration = vm.parseUint(vm.prompt("What should be the maximum approval duration? In seconds"));
        address emergencyTrigger = vm.parseAddress(vm.prompt("Who should be the emergency trigger?"));
        address emergencyCaller = vm.parseAddress(vm.prompt("Who should be the emergency caller?"));

        _setupGuard(shortTxExecutionDelay, longTxExecutionDelay, txExpiryDelay, maxApprovalDuration, emergencyTrigger, emergencyCaller);
    }

    function attachGuard() public {
        if (address(canonGuard) != address(0)) {
            console.log("Canon Guard is already attached to the Safe");
            return;
        }

        // Ensure Canon guard address is being logged as detached
        isCanonGuardDetached = true;

        address guard = vm.parseAddress(vm.prompt("What is the address of the Canon Guard you want to attach?"));
        _attachGuard(guard);
    }

    function removeGuard() public {
        if (address(canonGuard) == address(0)) {
            console.log("Safe Guard is not configured");
            return;
        }

        vm.startBroadcast();
        address removeGuardAction = CanonRegistry.SIMPLE_ACTIONS_FACTORY.createSimpleAction(
            ISimpleActions.SimpleAction(
                address(safe),
                "setGuard(address)",
                abi.encode(address(0)),
                0
            )
        );
        console.log("Remove guard simple action deployed to: %s", removeGuardAction);
        vm.stopBroadcast();

        _proposeQueueTransaction(removeGuardAction, "Remove guard action successfully deployed");
    }

    function _setupGuard(uint256 shortTxExecutionDelay, uint256 longTxExecutionDelay, uint256 txExpiryDelay, uint256 maxApprovalDuration, address emergencyTrigger, address emergencyCaller) internal view {
        console.log("");
        console.log("Please deploy Canon Guard via the Safe Transaction Builder, and then call attachGuard with the addess of the deployed Canon Guard");
        console.log("");
        console.log("Target: %s", address(CanonRegistry.CANON_GUARD_FACTORY));
        console.log("Function: createCanonGuard");
        console.log("");
        console.log("Parameters:");
        console.log("  _safe: %s", address(safe));
        console.log("  _multiSendCallOnly: %s", CanonRegistry.MULTI_SEND_CALL_ONLY);
        console.log("  _shortTxExecutionDelay: %s", shortTxExecutionDelay);
        console.log("  _longTxExecutionDelay: %s", longTxExecutionDelay);
        console.log("  _txExpiryDelay: %s", txExpiryDelay);
        console.log("  _maxApprovalDuration: %s", maxApprovalDuration);
        console.log("  _emergencyTrigger: %s", emergencyTrigger);
        console.log("  _emergencyCaller: %s", emergencyCaller);
        console.log("");
    }

    function _attachGuard(address guard) internal {
        require(_isValidCanonGuard(guard), "Invalid Canon Guard, not deployed from supported Factory address");

        canonGuard = ICanonGuard(guard);
        isCanonGuardDetached = true;

        vm.startBroadcast();
        address setGuardAction = CanonRegistry.SIMPLE_ACTIONS_FACTORY.createSimpleAction(
            ISimpleActions.SimpleAction(
                address(safe),
                "setGuard(address)",
                abi.encode(guard),
                0
            )
        );
        vm.stopBroadcast();
        console.log("Set guard simple action deployed to: %s", setGuardAction);

        _proposeQueueTransaction(setGuardAction, "Set guard action successfully deployed");
    }
    
}