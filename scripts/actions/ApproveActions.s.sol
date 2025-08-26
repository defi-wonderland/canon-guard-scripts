// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {BasicActions} from "./BasicActions.s.sol";
import {CanonRegistry} from "../Constants.s.sol";

contract ApproveActions is BasicActions {
    function approveNoAction() ensureEntrypoint public {
        _approveTransactionOrHub(CanonRegistry.NO_ACTIONS);
    }
}