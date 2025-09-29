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
    ICanonGuardFactory constant CANON_GUARD_FACTORY = ICanonGuardFactory(0x84725ebdF986308cc8a24525CbFcfe288ff73399);
    IAllowanceClaimorFactory constant ALLOWANCE_CLAIMOR_FACTORY = IAllowanceClaimorFactory(0x92E1FD85AD2Cc57d454571d912Ffc5693bd120A0);
    IApproveActionFactory constant APPROVE_ACTION_FACTORY = IApproveActionFactory(0x28AA7716DbfCb459F6A82a5Da1FdA7094ec9A943);
    ICappedTokenTransfersHubFactory constant CAPPED_TOKEN_TRANSFERS_HUB_FACTORY = ICappedTokenTransfersHubFactory(0x65b1D23728F1f5a8a51C7794CD29C0a98020792A);
    ISimpleActionsFactory constant SIMPLE_ACTIONS_FACTORY = ISimpleActionsFactory(0xfADd479952e7CA915F89d1D7cFdc6552f351C652);
    ISimpleTransfersFactory constant SIMPLE_TRANSFERS_FACTORY = ISimpleTransfersFactory(0xA773D569F700F1100b0D662bD90Ea948aA8D299d);
}
