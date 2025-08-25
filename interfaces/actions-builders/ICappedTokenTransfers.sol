// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';

/**
 * @title ICappedTokenTransfers
 * @notice Interface for the CappedTokenTransfers contract
 */
interface ICappedTokenTransfers is IActionsBuilder {
  // ~~~ STORAGE METHODS ~~~

  /**
   * @notice Gets the token contract
   * @return _token The token contract address
   */
  function TOKEN() external view returns (address _token);

  /**
   * @notice Gets the amount of tokens to transfer
   * @return _amount The amount of tokens to transfer
   */
  function AMOUNT() external view returns (uint256 _amount);

  /**
   * @notice Gets the recipient of the tokens
   * @return _recipient The recipient of the tokens
   */
  function RECIPIENT() external view returns (address _recipient);

  /**
   * @notice Gets the actionHub contract
   * @return _actionHub The actionHub contract address
   */
  function HUB() external view returns (address _actionHub);
}
