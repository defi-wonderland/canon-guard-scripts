// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {console} from "forge-std/console.sol";
import {ISafeEntrypoint} from '@canon-guard/ISafeEntrypoint.sol';
import {ISimpleActions} from '@canon-guard/actions-builders/ISimpleActions.sol';
import {BasicActions} from "./BasicActions.s.sol";
import {CanonRegistry} from "../Constants.s.sol";

contract GuardActions is BasicActions {
    function isGuardSetup() view public {
        if (address(entrypoint) == address(0)) {
            console.log("Canon Guard is not configured");
        } else {
            // TODO: check if it is really a Canon Guard
            console.log("Yes! Guard %s is configured", address(entrypoint));
        }
    }

    function setupGuard() public {
        // Ensure entrypoint address is being logged as detached
        isEntrypointDetached = true;

        uint256 shortTxExecutionDelay = vm.parseUint(vm.prompt("How long in seconds should you SHORT execution delay be? In seconds"));
        uint256 longTxExecutionDelay = vm.parseUint(vm.prompt("How long in seconds should you LONG execution delay be? In seconds"));
        uint256 txExpiryDelay = vm.parseUint(vm.prompt("From the moment a transaction is executable, how long until it expires? In seconds"));
        uint256 maxApprovalDuration = vm.parseUint(vm.prompt("What should be the maximum approval duration? In seconds"));
        address emergencyTrigger = vm.parseAddress(vm.prompt("Who should be the emergency trigger?"));
        address emergencyCaller = vm.parseAddress(vm.prompt("Who should be the emergency caller?"));

        _setupGuard(shortTxExecutionDelay, longTxExecutionDelay, txExpiryDelay, maxApprovalDuration, emergencyTrigger, emergencyCaller);
    }

    function removeGuard() public {
        // TODO: check if it is really a Canon Guard
        if (address(entrypoint) == address(0)) {
            console.log("Canon Guard is not configured");
            return;
        }

        vm.startBroadcast();
        address removeGuardAction = CanonRegistry.SIMPLE_ACTIONS_FACTORY.createSimpleActions(
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

    function _setupGuard(uint256 shortTxExecutionDelay, uint256 longTxExecutionDelay, uint256 txExpiryDelay, uint256 maxApprovalDuration, address emergencyTrigger, address emergencyCaller) internal {
        vm.startBroadcast();
        entrypoint = ISafeEntrypoint(CanonRegistry.SAFE_ENTRYPOINT_FACTORY.createSafeEntrypoint(
            address(safe),
            shortTxExecutionDelay,
            longTxExecutionDelay,
            txExpiryDelay,
            maxApprovalDuration,
            emergencyTrigger,
            emergencyCaller
        ));
        console.log("Entrypoint deployed to: %s", address(entrypoint));

        address setGuardAction = CanonRegistry.SIMPLE_ACTIONS_FACTORY.createSimpleActions(
            ISimpleActions.SimpleAction(
                address(safe),
                "setGuard(address)",
                abi.encode(address(entrypoint)),
                0
            )
        );
        console.log("Set guard simple action deployed to: %s", setGuardAction);
        vm.stopBroadcast();

        _proposeQueueTransaction(setGuardAction, "Entrypoint and set guard action successfully deployed");
    }

}