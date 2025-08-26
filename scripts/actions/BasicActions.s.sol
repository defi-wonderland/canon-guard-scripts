// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {console} from "forge-std/console.sol";
import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {ISafeEntrypoint} from "@interfaces/ISafeEntrypoint.sol";
import {ISimpleActions} from "@interfaces/actions-builders/ISimpleActions.sol";
import {IActionsBuilder} from "@interfaces/actions-builders/IActionsBuilder.sol";

import {Core} from "../Core.s.sol";
import {CanonRegistry} from "../Constants.s.sol";

contract BasicActions is Core {
    function queueTransaction() ensureEntrypoint public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to enqueue?"));
        _queueTransaction(actionBuilder);
    }
    
    function queueHubTransaction() ensureEntrypoint public {
        address actionHub = vm.parseAddress(vm.prompt("What's the address of the action hub?"));
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to enqueue?"));
        _queueTransaction(actionHub, actionBuilder);
    }

    function signTransaction() ensureEntrypoint public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to approve?"));
        _signTransaction(actionBuilder);
    }

    function executeTransaction() ensureEntrypoint public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the transaction builder address you want to execute?"));
        _executeTransaction(actionBuilder);
    }

    function approveHub() ensureEntrypoint public {
        address actionHub = vm.parseAddress(vm.prompt("What's the address of the hub you want to approve?"));
        _approveTransactionOrHub(actionHub);
    }

    function approveTransaction() ensureEntrypoint public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to approve?"));
        _approveTransactionOrHub(actionBuilder);
    }

    function _approveTransactionOrHub(address actionBuilderOrHub) ensureEntrypoint internal {
        uint256 approvalDuration = vm.parseUint(vm.prompt("How long should for it to be approved? In seconds"));
        _approveTransaction(actionBuilderOrHub, approvalDuration);
    }

    function _proposeApproveTransactionOrHub(address actionBuilderOrHub, string memory promptPrefix) internal {
        string memory prompt = string.concat(promptPrefix, ". Would you like to approve it into the entrypoint?");

        bool approveConfirmation = _promptConfirmation(prompt);
        if (!approveConfirmation) {
            console.log("You can approve the action via the approveTransaction script");
            if (isEntrypointDetached) {
                console.log("Detached entrypoint: %s", address(entrypoint));
            }
            console.log("Action builder: %s", actionBuilderOrHub);
            return;
        }

        _approveTransactionOrHub(actionBuilderOrHub);
    }
}