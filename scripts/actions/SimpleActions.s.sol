// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {BasicActions} from "./BasicActions.s.sol";
import {CanonRegistry} from "../Constants.s.sol";
import {console} from "forge-std/console.sol";
import {ISimpleActions} from "@canon-guard/actions-builders/ISimpleActions.sol";

// TODO: try this out
contract SimpleActions is BasicActions {
    function deploySimpleAction() ensureEntrypoint public {
        // Collect simple actions interactively
        ISimpleActions.SimpleAction[] memory simpleActions = new ISimpleActions.SimpleAction[](0);

        while (true) {
            address target = vm.parseAddress(vm.prompt("What is the target contract address?"));
            string memory signature = vm.prompt("What is the function signature? e.g., transfer(address,uint256) or deposit() ");

            // Ask for calldata payload as hex string (0x...)
            string memory dataHex = vm.prompt("Provide the ABI-encoded calldata without selector as a hex string (0x...) or 0x for none");
            bytes memory data;
            if (bytes(dataHex).length == 0 || (bytes(dataHex).length == 2 && bytes(dataHex)[0] == '0' && bytes(dataHex)[1] == 'x')) {
                data = hex"";
            } else {
                data = vm.parseBytes(dataHex);
            }

            string memory valueStr = vm.prompt("What ETH value (in wei) should be sent? (0)");
            uint256 value = bytes(valueStr).length == 0 ? 0 : vm.parseUint(valueStr);

            uint256 len = simpleActions.length;
            ISimpleActions.SimpleAction[] memory newSimpleActions = new ISimpleActions.SimpleAction[](len + 1);
            for (uint256 i; i < len; ++i) {
                newSimpleActions[i] = simpleActions[i];
            }
            newSimpleActions[len] = ISimpleActions.SimpleAction({ target: target, signature: signature, data: data, value: value });
            simpleActions = newSimpleActions;

            bool addMore = _promptConfirmation("Would you like to add another simple action?");
            if (!addMore) {
                break;
            }
        }

        vm.startBroadcast();
        address simpleActionsAddr = CanonRegistry.SIMPLE_ACTIONS_FACTORY.createSimpleActions(simpleActions);
        console.log("Simple actions builder deployed to: %s", simpleActionsAddr);
        vm.stopBroadcast();

        _proposeQueueTransaction(simpleActionsAddr, "Simple action builder successfully deployed");
    }
}