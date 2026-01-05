// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {console} from "forge-std/console.sol";
import {ICanonGuard} from "@canon-guard/ICanonGuard.sol";
import {ISimpleActions} from "@canon-guard/actions-builders/ISimpleActions.sol";
import {IActionsBuilder} from "@canon-guard/actions-builders/IActionsBuilder.sol";

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {ScriptWithUtils} from "./ScriptWithUtils.s.sol";
import {CanonRegistry} from "./Constants.s.sol";

contract Core is ScriptWithUtils {
    ISafe safe;
    uint256 safeThreshold;
    ICanonGuard canonGuard;
    bool isCanonGuardDetached;

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL"));

        // TODO: check that it is a valid safe
        safe = ISafe(vm.envAddress("SAFE"));
        safeThreshold = safe.getThreshold();
        canonGuard = ICanonGuard(_getSafeGuard(safe));

        console.log("Signer: %s", msg.sender);
        console.log("Safe: %s", address(safe));
        console.log("Safe threshold: %s", safeThreshold);
        console.log("Canon guard: %s", address(canonGuard));
    }

    function _proposeQueueTransaction(address actionBuilder, string memory promptPrefix) internal {
        string memory prompt = string.concat(promptPrefix, ". Would you like to enqueue the action into your Canon guard?");

        bool enqueueConfirmation = _promptConfirmation(prompt);
        if (!enqueueConfirmation) {
            console.log("You can enqueue the action via the queueTransaction script");
            if (isCanonGuardDetached) {
                console.log("Detached Canon guard: %s", address(canonGuard));
            }
            console.log("Action builder: %s", actionBuilder);
            return;
        }

        _queueTransaction(actionBuilder);
    }

    function _queueTransaction(address actionBuilder) internal {
        // Add transaction into the Canon guard queue
        vm.startBroadcast();
        canonGuard.queueTransaction(actionBuilder);
        vm.stopBroadcast();

        bool approveConfirmation = _promptConfirmation("Transaction successfully queued. Would you like to approve this transaction in your Safe?");
        if (!approveConfirmation) {
            console.log("Signers can approve the action in your Safe via the signTransaction script by using the following address as input: %s", actionBuilder);
            console.log("Or the signers can also directly call your Safe's (%s) method approveHash(%s)", address(safe), actionBuilder);
            if (isCanonGuardDetached) {
                console.log("Detached Canon guard: %s", address(canonGuard));
            }
            return;
        }

        _signTransaction(actionBuilder);
    }

    function _signTransaction(address actionBuilder) internal {
        bytes32 safeTxHash = canonGuard.getSafeTransactionHash(actionBuilder);
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

        (,, uint256 _executableAt, uint256 _expiresAt,) = canonGuard.transactionsInfo(actionBuilder);
        int256 executableIn = int256(_executableAt) - int256(block.timestamp);
        int256 expiresIn = int256(_expiresAt) - int256(block.timestamp);

        console.log("Your transaction will be executable in %s seconds", executableIn);
        console.log("Watch out, your transaction will also expire in %s seconds", expiresIn);
        console.log("You can execute the transaction via the executeTransaction script");
        if (isCanonGuardDetached) {
            console.log("Detached Canon guard: %s", address(canonGuard));
        }
        console.log("Action builder: %s", actionBuilder);
    }

    function _executeTransaction(address actionBuilder) ensureCanonGuard internal {
        (,, uint256 _executableAt, uint256 _expiresAt,) = canonGuard.transactionsInfo(actionBuilder);
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

        bytes32 safeTxHash = canonGuard.getSafeTransactionHash(actionBuilder);
        address[] memory approvedHashSigners = _getSafeApprovedHashSigners(safe, safeTxHash);

        uint256 missingSignatures = safeThreshold - approvedHashSigners.length;
        if (missingSignatures > 0) {
            console.log(
                "You will need %s more signatures to execute, the other signers must call your Safe's method approveHash(%s), or use the signTransaction script with the following address as input: %s",
                missingSignatures,
                vm.toString(safeTxHash),
                actionBuilder
            );
            if (isCanonGuardDetached) {
                console.log("Detached Canon guard: %s", address(canonGuard));
            }
        }

        vm.startBroadcast();
        canonGuard.executeTransaction(actionBuilder);
        vm.stopBroadcast();

        console.log("Transaction executed in your Safe");
    }

    function _approveTransaction(address actionBuilder, uint256 approvalDuration) ensureCanonGuard internal {
        vm.startBroadcast();
        address approvalAction = CanonRegistry.APPROVE_ACTION_FACTORY.createPreApproveAction(actionBuilder, approvalDuration);
        console.log("Approval action of action builder %s for %s seconds deployed to: %s", actionBuilder, approvalDuration, approvalAction);
        vm.stopBroadcast();
        
        _proposeQueueTransaction(approvalAction, "Approve action successfully deployed");
    }

    modifier ensureCanonGuard {
        if (address(canonGuard) == address(0)) {
            bool confirmation = _promptConfirmation("Canon guard not yet configured in your Safe. Would you like to specify your detached Canon Guard address?");
            if (confirmation) {
                address guard = vm.parseAddress(vm.prompt("Insert Canon Guard address"));
                require (_isValidCanonGuard(guard), "Invalid Canon Guard, not deployed from supported Factory");
                canonGuard = ICanonGuard(guard);
                isCanonGuardDetached = true;
            }
        }

        require (address(canonGuard) != address(0), "Canon Guard is not yet configured in your Safe");
        _;
    }
}