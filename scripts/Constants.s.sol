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
    ICanonGuardFactory constant CANON_GUARD_FACTORY = ICanonGuardFactory(0xc7B2BA2A8281A1F466Afc5E0096FdE30E6753db0);
    IAllowanceClaimorFactory constant ALLOWANCE_CLAIMOR_FACTORY = IAllowanceClaimorFactory(0x118b6C10F09f03bf4D9BD77B85978b60c4dECE35);
    IApproveActionFactory constant APPROVE_ACTION_FACTORY = IApproveActionFactory(0xD3792dbB77Cf104332f5C50866465a01fE300B26);
    ICappedTokenTransfersHubFactory constant CAPPED_TOKEN_TRANSFERS_HUB_FACTORY = ICappedTokenTransfersHubFactory(0x6C331077CD06C6d37b8C147FCefD59536D416b55);
    ISimpleActionsFactory constant SIMPLE_ACTIONS_FACTORY = ISimpleActionsFactory(0x32B766aD20aa65B4bffA7bD2b4C713CfE30af56e);
    ISimpleTransfersFactory constant SIMPLE_TRANSFERS_FACTORY = ISimpleTransfersFactory(0xCE5b38C24db98FD5B196D747Cf4Bdc132489a2Eb);
}