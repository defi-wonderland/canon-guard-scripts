// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {ICanonGuardFactory} from "@canon-guard/factories/ICanonGuardFactory.sol";
import {IAllowanceClaimorFactory} from "@canon-guard/factories/IAllowanceClaimorFactory.sol";
import {IPreApproveActionFactory} from "@canon-guard/factories/IPreApproveActionFactory.sol";
import {ICappedTokenTransfersHubFactory} from "@canon-guard/factories/ICappedTokenTransfersHubFactory.sol";
import {ISimpleActionsFactory} from "@canon-guard/factories/ISimpleActionsFactory.sol";
import {ISimpleTransfersFactory} from "@canon-guard/factories/ISimpleTransfersFactory.sol";
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

library CanonRegistry {
    ICanonGuardFactory constant CANON_GUARD_FACTORY = ICanonGuardFactory(0x656c264F914bd8Fe7bbAfb9B4F2EBcB4f259F67C);
    IAllowanceClaimorFactory constant ALLOWANCE_CLAIMOR_FACTORY = IAllowanceClaimorFactory(0x6636eDd0125880677f3a1f7411555ea64411d60E);
    IPreApproveActionFactory constant APPROVE_ACTION_FACTORY = IPreApproveActionFactory(0x2A62b0644BA7F4648179BfAE9a279D63DC44eF4a);
    ICappedTokenTransfersHubFactory constant CAPPED_TOKEN_TRANSFERS_HUB_FACTORY = ICappedTokenTransfersHubFactory(0x8531f72986374445507c29A0753fcc9cA36468D0);
    ISimpleActionsFactory constant SIMPLE_ACTIONS_FACTORY = ISimpleActionsFactory(0xEE501087737570c780C3C219A0d3FFf2d86417a4);
    ISimpleTransfersFactory constant SIMPLE_TRANSFERS_FACTORY = ISimpleTransfersFactory(0xC2E8c09Eb985Dd34285bc154D1B6886e6886aE54);
    address constant MULTI_SEND_CALL_ONLY = 0x9641d764fc13c8B624c04430C7356C1C7C8102e2;
}
