// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {ISafeEntrypointFactory} from "@interfaces/factories/ISafeEntrypointFactory.sol";
import {IAllowanceClaimorFactory} from "@interfaces/factories/IAllowanceClaimorFactory.sol";
import {IApproveActionFactory} from "@interfaces/factories/IApproveActionFactory.sol";
import {ICappedTokenTransfersHubFactory} from "@interfaces/factories/ICappedTokenTransfersHubFactory.sol";
import {ISimpleActionsFactory} from "@interfaces/factories/ISimpleActionsFactory.sol";
import {ISimpleTransfersFactory} from "@interfaces/factories/ISimpleTransfersFactory.sol";
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

library CanonRegistry {
    ISafeEntrypointFactory constant SAFE_ENTRYPOINT_FACTORY = ISafeEntrypointFactory(0x82386Bc221fc4C8FE8a1aBBCb9ba63d9379DE1dE);
    IAllowanceClaimorFactory constant ALLOWANCE_CLAIMOR_FACTORY = IAllowanceClaimorFactory(0x22caFedbd199b77241ff862Da076a951709f0f66);
    IApproveActionFactory constant APPROVE_ACTION_FACTORY = IApproveActionFactory(0x7B836eB789A63E22686709b95745b50bf271DBB3);
    ICappedTokenTransfersHubFactory constant CAPPED_TOKEN_TRANSFERS_HUB_FACTORY = ICappedTokenTransfersHubFactory(0x70Dae504858e38cf786833671e1bdDb622bd2507);
    ISimpleActionsFactory constant SIMPLE_ACTIONS_FACTORY = ISimpleActionsFactory(0xB63Bd0e55d3026d4a06C482b4c193E835EeD66b1);
    ISimpleTransfersFactory constant SIMPLE_TRANSFERS_FACTORY = ISimpleTransfersFactory(0xEE6c9f2Ced068f0389f437B830A511f054F5cc9B);
    address constant NO_ACTIONS = 0xCA026cceC6DA7E6716087697C5662040E8bd54F0;
    IERC20 constant USDC = IERC20(0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85);
}
