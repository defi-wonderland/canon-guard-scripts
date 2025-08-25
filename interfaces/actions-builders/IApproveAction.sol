// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';

/**
 * @title IApproveAction
 * @notice Interface for the ApproveAction contract
 */
interface IApproveAction is IActionsBuilder {
  // ~~~ STORAGE METHODS ~~~

  /**
   * @notice Gets the safe entrypoint contract
   * @return _safeEntrypoint The safe entrypoint contract address
   */
  function SAFE_ENTRYPOINT() external view returns (address _safeEntrypoint);

  /**
   * @notice Gets the actions builder contract
   * @return _actionsBuilder The actions builder contract address
   */
  function ACTIONS_BUILDER() external view returns (address _actionsBuilder);

  /**
   * @notice Gets the approval duration
   * @return _approvalDuration The approval duration
   */
  function APPROVAL_DURATION() external view returns (uint256 _approvalDuration);
}
