// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {console} from "forge-std/console.sol";
import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {ICanonGuard} from "@canon-guard/ICanonGuard.sol";
import {ISimpleActions} from "@canon-guard/actions-builders/ISimpleActions.sol";
import {IActionsBuilder} from "@canon-guard/actions-builders/IActionsBuilder.sol";

import {Core} from "../Core.s.sol";
import {CanonRegistry} from "../Constants.s.sol";

contract BasicActions is Core {
    function queueTransaction() ensureCanonGuard public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to enqueue?"));
        _queueTransaction(actionBuilder);
    }

    function signTransaction() ensureCanonGuard public {
        string memory result = vm.prompt("What's the address of the action builder you want to approve? (0 for no-action transaction)");
        if (_isEqual(result, "0")) {
            _signTransaction(address(0));
        } else {
             address actionBuilder = vm.parseAddress(result);
            _signTransaction(actionBuilder);
        }
    }

    function executeTransaction() ensureCanonGuard public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the transaction builder address you want to execute?"));
        _executeTransaction(actionBuilder);
    }

    function approveHub() ensureCanonGuard public {
        address actionHub = vm.parseAddress(vm.prompt("What's the address of the hub you want to approve?"));
        _approveTransactionOrHub(actionHub);
    }

    function approveTransaction() ensureCanonGuard public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to approve?"));
        _approveTransactionOrHub(actionBuilder);
    }

    function executeNoActionTransaction() public {
        string memory prompt = "You are going to execute an empty transaction. This needs the required signatures beforehand. Would you like to proceed?";

        bool approveConfirmation = _promptConfirmation(prompt);
        if (approveConfirmation) {
            _executeNoActionTransaction();
        } else {
            console.log("Operation cancelled");
        }
    }

    function cancelEnqueuedTransaction() public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to cancel?"));

        _cancelEnqueuedTransaction(actionBuilder);
    }

    function _approveTransactionOrHub(address actionBuilderOrHub) ensureCanonGuard internal {
        uint256 approvalDuration = vm.parseUint(vm.prompt("How long should for it to be approved? In seconds"));
        _approveTransaction(actionBuilderOrHub, approvalDuration);
    }

    function _proposeApproveTransactionOrHub(address actionBuilderOrHub, string memory promptPrefix) internal {
        string memory prompt = string.concat(promptPrefix, ". Would you like to approve it into your Canon guard?");

        bool approveConfirmation = _promptConfirmation(prompt);
        if (!approveConfirmation) {
            console.log("You can approve the action via the approveTransaction script");
            if (isCanonGuardDetached) {
                console.log("Detached Canon guard: %s", address(canonGuard));
            }
            console.log("Action builder: %s", actionBuilderOrHub);
            return;
        }

        _approveTransactionOrHub(actionBuilderOrHub);
    }
}
