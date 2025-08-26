// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {BasicActions} from "./BasicActions.s.sol";
import {CanonRegistry} from "../Constants.s.sol";
import {console} from "forge-std/console.sol";
import {ISimpleTransfers} from "@interfaces/actions-builders/ISimpleTransfers.sol";

contract SimpleTransferActions is BasicActions {
    function deploySimpleTransfer() ensureEntrypoint public {
        // Collect transfer actions interactively
        ISimpleTransfers.TransferAction[] memory transferActions = new ISimpleTransfers.TransferAction[](0);

        while (true) {
            address token = vm.parseAddress(vm.prompt("Which token would you like to transfer? Please specify its contract address"));
            address to = vm.parseAddress(vm.prompt("Who should receive the tokens? Please specify the recipient address"));

            uint256 amount;
            while (true) {
                amount = vm.parseUint(vm.prompt("What amount should be transferred? In wei"));
                if (amount == 0) {
                    // Note: Logs do not show until the process is finished
                    console.log("Amount must be greater than zero.");
                    continue;
                }
                break;
            }

            uint256 len = transferActions.length;
            ISimpleTransfers.TransferAction[] memory newTransferActions = new ISimpleTransfers.TransferAction[](len + 1);
            for (uint256 i; i < len; ++i) {
                newTransferActions[i] = transferActions[i];
            }
            newTransferActions[len] = ISimpleTransfers.TransferAction({ token: token, to: to, amount: amount });
            transferActions = newTransferActions;

            bool addMore = _promptConfirmation("Would you like to add another transfer action?");
            if (!addMore) {
                break;
            }
        }

        vm.startBroadcast();
        address simpleTransfers = CanonRegistry.SIMPLE_TRANSFERS_FACTORY.createSimpleTransfers(transferActions);
        console.log("Simple transfers action deployed to: %s", simpleTransfers);
        vm.stopBroadcast();

        _proposeQueueTransaction(simpleTransfers, "Simple transfers action successfully deployed");
    }
}