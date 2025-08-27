// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {console} from "forge-std/console.sol";
import {ICappedTokenTransfersHub} from "@canon-guard/action-hubs/ICappedTokenTransfersHub.sol";

import {CanonRegistry} from "../Constants.s.sol";
import {BasicActions} from "./BasicActions.s.sol";

contract CappedTokenTransferActions is BasicActions {
    function deployCappedTokenTransfersHub() ensureEntrypoint public {
        address recipient = vm.parseAddress(vm.prompt("What's the address of the recipient?"));

        // Collect tokens and caps interactively
        address[] memory tokens = new address[](0);
        uint256[] memory caps = new uint256[](0);

        while (true) {
            address token = vm.parseAddress(vm.prompt("Which token would you like to cap transfer? Please specify its contract address"));
            uint256 cap = vm.parseUint(vm.prompt("What should be the capped amount? Remember the amount is in wei"));

            uint256 len = tokens.length;
            address[] memory newTokens = new address[](len + 1);
            uint256[] memory newCaps = new uint256[](len + 1);
            for (uint256 i; i < len; ++i) {
                newTokens[i] = tokens[i];
                newCaps[i] = caps[i];
            }
            newTokens[len] = token;
            newCaps[len] = cap;
            tokens = newTokens;
            caps = newCaps;

            bool addMore = _promptConfirmation("Would you like to approve any other token?");
            if (!addMore) {
                break;
            }
        }

        uint256 epochLength = vm.parseUint(vm.prompt("How often should the cap be resetted? In seconds"));

        vm.startBroadcast();
        address cappedTokenTransfersHub = CanonRegistry.CAPPED_TOKEN_TRANSFERS_HUB_FACTORY.createCappedTokenTransfersHub(
            address(safe),
            recipient,
            tokens,
            caps,
            epochLength
        );
        console.log("Capped token transfer hub successfully deployed to: %s", cappedTokenTransfersHub);
        vm.stopBroadcast();

        _proposeApproveTransactionOrHub(cappedTokenTransfersHub, "Capped token transfer hub successfully deployed");
    }

    // TODO: subdivide this into smaller internal functions for better readability of the code
    function deployCappedTokenTransfer() ensureEntrypoint public {
        ICappedTokenTransfersHub actionHub = ICappedTokenTransfersHub(vm.parseAddress(vm.prompt("What's the address of your Capped Token Transfer Hub?")));
        // Fetch the tokens from the hub. If there is only one token, skip asking for the token address
        address[] memory hubTokens = actionHub.tokens();
        address token;
        if (hubTokens.length == 1) {
            token = hubTokens[0];
            string memory prompt = string.concat(string.concat("The only token configured in the hub is: ", vm.toString(token)), ". Would you like to continue with it?");
            bool confirmedToken = _promptConfirmation(prompt);
            if (!confirmedToken) {
                return;
            }
        } else {
            string memory promptMessage = "The following tokens are configured in your hub:\n";
            for (uint256 i; i < hubTokens.length; ++i) {
                promptMessage = string.concat(promptMessage, "- ", vm.toString(hubTokens[i]), "\n");
            }
            promptMessage = string.concat(promptMessage, "Which token would you like to transfer?");
            token = vm.parseAddress(vm.prompt(promptMessage));
        }

        // Show the remaining amount to spend in this epoch and ensure the user doesn't set a higher number than it
        uint256 capForToken = actionHub.cap(token);
        uint256 spentForToken = actionHub.totalSpent(token);
        uint256 remaining = capForToken > spentForToken ? capForToken - spentForToken : 0;

        // Calculate next epoch start and show reset time if any amount has already been spent
        uint256 starting = actionHub.STARTING_TIMESTAMP();
        uint256 epochLength = actionHub.EPOCH_LENGTH();
        uint256 nextEpochStart;
        if (block.timestamp <= starting) {
            nextEpochStart = starting;
        } else {
            uint256 currentEpoch = (block.timestamp - starting) / epochLength;
            nextEpochStart = starting + (currentEpoch + 1) * epochLength;
        }

        console.log("Total allowance: %s", capForToken);
        console.log("Remaining allowance: %s", remaining);
        console.log("Allowance reset at %s (in %s seconds)", nextEpochStart, nextEpochStart - block.timestamp);

        if (remaining == 0) {
            console.log("No remaining allowance for this epoch");
            return;
        }
        
        uint256 amount;
        while (true) {
            string memory prompt = string.concat(string.concat("Remaining allowance for this epoch: ", vm.toString(remaining)), " wei. How much would you like to transfer? In wei");
            amount = vm.parseUint(vm.prompt(prompt));
            // Note: console.logs do not show until the end of the process
            if (amount == 0) {
                console.log("Amount must be greater than zero.");
                continue;
            }
            if (amount > remaining) {
                console.log("Amount exceeds remaining allowance. Please enter an amount <= %s", remaining);
                continue;
            }
            break;
        }

        vm.startBroadcast();
        address actionBuilder = actionHub.createNewActionBuilder(token, amount);
        console.log("Transfer action deployed to: %s", actionBuilder);
        vm.stopBroadcast();

        _proposeQueueTransaction(address(actionHub), actionBuilder, "Transfer action successfully deployed");
    }
}