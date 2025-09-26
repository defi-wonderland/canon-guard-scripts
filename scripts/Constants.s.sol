// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {ICanonGuardFactory} from "@canon-guard/factories/ICanonGuardFactory.sol";
import {IAllowanceClaimorFactory} from "@canon-guard/factories/IAllowanceClaimorFactory.sol";
import {IApproveActionFactory} from "@canon-guard/factories/IApproveActionFactory.sol";
import {ICappedTokenTransfersHubFactory} from "@canon-guard/factories/ICappedTokenTransfersHubFactory.sol";
import {ISimpleActionsFactory} from "@canon-guard/factories/ISimpleActionsFactory.sol";
import {ISimpleTransfersFactory} from "@canon-guard/factories/ISimpleTransfersFactory.sol";
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

library CanonRegistry {
    ICanonGuardFactory constant CANON_GUARD_FACTORY = ICanonGuardFactory(0x079D6dc735975851d822CE51f4f63671f5fd98fF);
    IAllowanceClaimorFactory constant ALLOWANCE_CLAIMOR_FACTORY = IAllowanceClaimorFactory(0xd558C3e2dd8Cb0584CbDE4cFb9CE3d3D41B276DB);
    IApproveActionFactory constant APPROVE_ACTION_FACTORY = IApproveActionFactory(0x7bdB9eAdEC9e4C0eaf044AfAe0a08DDB57Fe6779);
    ICappedTokenTransfersHubFactory constant CAPPED_TOKEN_TRANSFERS_HUB_FACTORY = ICappedTokenTransfersHubFactory(0x08f30bA2C764F6C61EDD33116290892F8d2507DE);
    ISimpleActionsFactory constant SIMPLE_ACTIONS_FACTORY = ISimpleActionsFactory(0xF3bCCd24A1c0AB3e784A7CD812c0Fa382Beab62F);
    ISimpleTransfersFactory constant SIMPLE_TRANSFERS_FACTORY = ISimpleTransfersFactory(0x60fa43e3fb8F0016934B9fd78297209E24e2Fe21);
}
