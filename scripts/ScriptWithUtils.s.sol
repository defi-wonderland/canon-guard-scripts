// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Script} from "forge-std/Script.sol";
import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';

contract ScriptWithUtils is Script {

    function _promptConfirmation(string memory question) internal returns (bool confirmation) {
        string memory response = vm.prompt(string.concat(question, " y/(N)"));
        return _isEqual(response, "y") || _isEqual(response, "Y") || _isEqual(response, "Yes") || _isEqual(response, "YES");
    }

    /**
    * @notice Internal function to get the list of approved hash signers for a transaction
    * @param _safeTxHash The hash of the Safe transaction
    * @return _approvedHashSigners The array of approved hash signer addresses
    */
    function _getSafeApprovedHashSigners(ISafe safe, bytes32 _safeTxHash) internal view returns (address[] memory _approvedHashSigners) {
        address[] memory _safeOwners = safe.getOwners();
        uint256 _safeOwnersLength = _safeOwners.length;

        // Create a temporary array to store approved hash signers
        address[] memory _tempSigners = new address[](_safeOwnersLength);
        uint256 _approvedHashSignersCount;

        // Single pass through all owners
        address _safeOwner;
        for (uint256 _i; _i < _safeOwnersLength; ++_i) {
            _safeOwner = _safeOwners[_i];
            // Check if this owner has approved the hash
            if (safe.approvedHashes(_safeOwner, _safeTxHash) == 1) {
                _tempSigners[_approvedHashSignersCount] = _safeOwner;
                ++_approvedHashSignersCount;
            }
        }

        // Create the final result array with the exact size needed
        _approvedHashSigners = new address[](_approvedHashSignersCount);

        // Copy from temporary array to final array
        for (uint256 _i; _i < _approvedHashSignersCount; ++_i) {
            _approvedHashSigners[_i] = _tempSigners[_i];
        }
    }

    function _getSafeGuard(ISafe _safe) internal view returns (address _guard) {
        // Compute the guard storage slot and read it from the Safe
        bytes32 guardSlot = keccak256(bytes("guard_manager.guard.address"));
        bytes32 raw = vm.load(address(_safe), guardSlot);
        // TODO: check if it is really a Canon Guard
        return address(uint160(uint256(raw)));
    }

    function _isEqual(string memory _a, string memory _b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}