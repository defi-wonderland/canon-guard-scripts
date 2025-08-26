// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {console} from "forge-std/console.sol";
import {ISafeEntrypoint} from "@interfaces/ISafeEntrypoint.sol";
import {ISimpleActions} from "@interfaces/actions-builders/ISimpleActions.sol";
import {IActionsBuilder} from "@interfaces/actions-builders/IActionsBuilder.sol";

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {ScriptWithUtils} from "./ScriptWithUtils.s.sol";
import {CanonRegistry} from "./Constants.s.sol";

contract Core is ScriptWithUtils {
    ISafe safe;
    uint256 safeThreshold;
    ISafeEntrypoint entrypoint;
    bool isEntrypointDetached;

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL"));

        // TODO: check that it is a valid safe
        safe = ISafe(vm.envAddress("SAFE"));
        safeThreshold = safe.getThreshold();
        entrypoint = ISafeEntrypoint(_getSafeGuard(safe));

        console.log("Signer: %s", msg.sender);
        console.log("Safe: %s", address(safe));
        console.log("Safe threshold: %s", safeThreshold);
        // TODO: check if this is an entrypoint or any other guard
        console.log("Safe guard: %s", address(entrypoint));
    }

    function _proposeQueueTransaction(address actionBuilder, string memory promptPrefix) internal {
        _proposeQueueTransaction(address(0), actionBuilder, promptPrefix);
    }

    function _proposeQueueTransaction(address actionHub, address actionBuilder, string memory promptPrefix) internal {
        string memory prompt = string.concat(promptPrefix, ". Would you like to enqueue the action into the entrypoint?");

        bool enqueueConfirmation = _promptConfirmation(prompt);
        if (!enqueueConfirmation) {
            console.log("You can enqueue the action via the queueTransaction script");
            if (isEntrypointDetached) {
                console.log("Detached entrypoint: %s", address(entrypoint));
            }
            console.log("Action builder: %s", actionBuilder);
            return;
        }

        _queueTransaction(actionHub, actionBuilder);
    }

    function _queueTransaction(address actionBuilder) internal {
        _queueTransaction(address(0), actionBuilder);
    }

    function _queueTransaction(address actionHub, address actionBuilder) internal {
        // Add transaction into the Entrypoint queue
        vm.startBroadcast();
        if (actionHub == address(0)) {
            entrypoint.queueTransaction(actionBuilder);
        } else {
            entrypoint.queueHubTransaction(actionHub, actionBuilder);
        }
        vm.stopBroadcast();

        bool approveConfirmation = _promptConfirmation("Transaction successfully queued. Would you like to approve this transaction in your Safe?");
        if (!approveConfirmation) {
            console.log("Signers can approve the action in your Safe via the signTransaction script by using the following address as input: %s", actionBuilder);
            console.log("Or the signers can also directly call your Safe's (%s) method approveHash(%s)", address(safe), actionBuilder);
            if (isEntrypointDetached) {
                console.log("Detached entrypoint: %s", address(entrypoint));
            }
            return;
        }

        _signTransaction(actionBuilder);
    }

    function _signTransaction(address actionBuilder) internal {
        bytes32 safeTxHash = entrypoint.getSafeTransactionHash(actionBuilder);
        vm.startBroadcast();
        safe.approveHash(safeTxHash);
        vm.stopBroadcast();

        if (safeThreshold > 1) {
            console.log(
                "You will need %s more signatures to execute, the other signers will need to call your Safe's method approveHash(%s), or use the signTransaction script with the following address as input: %s",
                safeThreshold - 1,
                vm.toString(safeTxHash),
                actionBuilder
            );
        }

        (, uint256 _executableAt, uint256 _expiresAt) = entrypoint.queuedTransactions(actionBuilder);
        uint256 executableIn = _executableAt - block.timestamp;
        uint256 expiresIn = _expiresAt - block.timestamp;

        console.log("Your transaction will be executable in %s seconds", executableIn);
        console.log("Watch out, your transaction will also expire in %s seconds", expiresIn);
        console.log("You can execute the transaction via the executeTransaction script");
        if (isEntrypointDetached) {
            console.log("Detached entrypoint: %s", address(entrypoint));
        }
        console.log("Action builder: %s", actionBuilder);
    }

    function _executeTransaction(address actionBuilder) ensureEntrypoint internal {
        (, uint256 _executableAt, uint256 _expiresAt) = entrypoint.queuedTransactions(actionBuilder);
        int256 executableIn = int256(_executableAt) - int256(block.timestamp);
        int256 expiresIn = int256(_expiresAt) - int256(block.timestamp);

        if (expiresIn <= 0) {
            console.log("Your transaction expired %s seconds ago", -expiresIn);
            return;
        }
        if (executableIn > 0) {
            console.log("Your transaction will only be executable in %s seconds from now", executableIn);
            return;
        }

        bytes32 safeTxHash = entrypoint.getSafeTransactionHash(actionBuilder);
        address[] memory approvedHashSigners = _getSafeApprovedHashSigners(safe, safeTxHash);

        uint256 missingSignatures = safeThreshold - approvedHashSigners.length;
        if (missingSignatures > 0) {
            console.log(
                "You will need %s more signatures to execute, the other signers must call your Safe's method approveHash(%s), or use the signTransaction script with the following address as input: %s",
                missingSignatures,
                vm.toString(safeTxHash),
                actionBuilder
            );
            if (isEntrypointDetached) {
                console.log("Detached entrypoint: %s", address(entrypoint));
            }
        }

        vm.startBroadcast();
        entrypoint.executeTransaction(actionBuilder);
        vm.stopBroadcast();

        console.log("Transaction executed in your Safe");
    }

    function _approveTransaction(address actionBuilder, uint256 approvalDuration) ensureEntrypoint internal {
        vm.startBroadcast();
        address approvalAction = CanonRegistry.APPROVE_ACTION_FACTORY.createApproveAction(address(entrypoint), actionBuilder, approvalDuration);
        console.log("Approval action of action builder %s for %s seconds deployed to: %s", actionBuilder, approvalDuration, approvalAction);
        vm.stopBroadcast();
        
        _proposeQueueTransaction(approvalAction, "Approve action successfully deployed");
    }

    modifier ensureEntrypoint {
        if (address(entrypoint) == address(0)) {
            bool confirmation = _promptConfirmation("Entrypoint not yet configured in your Safe. Would you like to specify your detached entrypoint address?");
            if (confirmation) {
                // TODO: check if valid entrypoint
                entrypoint = ISafeEntrypoint(vm.parseAddress(vm.prompt("Insert entrypoint address")));
                isEntrypointDetached = true;
            }
        }

        require (address(entrypoint) != address(0), "Canon Guard is not yet configured in your Safe");
        _;
    }
}