// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ISafeEntrypoint} from "@interfaces/ISafeEntrypoint.sol";
import {ISimpleActions} from "@interfaces/actions-builders/ISimpleActions.sol";
import {IActionsBuilder} from "@interfaces/actions-builders/IActionsBuilder.sol";

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {CanonRegistry} from "./constants.sol";

contract Basic is Script {

    ISafe safe;
    uint256 safeThreshold;
    ISafeEntrypoint entrypoint;
    bool isEntrypointDetached;

    function setUp() public {
        console.log("Signer: %s", msg.sender);

        // TODO: check that it is a valid safe
        safe = ISafe(vm.envAddress("SAFE"));
        safeThreshold = safe.getThreshold();
        console.log("Safe: %s", address(safe));
        console.log("Safe threshold: %s", safeThreshold);

        entrypoint = ISafeEntrypoint(_getSafeGuard(safe));
        // TODO: check if this is an entrypoint or any other guard
        console.log("Safe guard: %s", address(entrypoint));
    }

    function isGuardSetup() view public {
        if (address(entrypoint) == address(0)) {
            console.log("Canon Guard is not configured");
        } else {
            // TODO: check if it is really a Canon Guard
            console.log("Guard %s configured", address(entrypoint));
        }
    }

    function setupGuard() public {
        // Ensure entrypoint address is being logged as detached
        isEntrypointDetached = true;

        // uint256 shortTxExecutionDelay = vm.parseUint(vm.prompt("How long in seconds should you SHORT execution delay be? In seconds"));
        // uint256 longTxExecutionDelay = vm.parseUint(vm.prompt("How long in seconds should you LONG execution delay be? In seconds"));
        // uint256 txExpiryDelay = vm.parseUint(vm.prompt("From the moment a transaction is executable, how long until it expires? In seconds"));
        // uint256 maxApprovalDuration = vm.parseUint(vm.prompt("What should be the maximum approval duration? In seconds"));
        // address emergencyTrigger = vm.parseAddress(vm.prompt("Who should be the emergency trigger?"));
        // address emergencyCaller = vm.parseAddress(vm.prompt("Who should be the emergency caller?"));

        // _setupGuard(shortTxExecutionDelay, longTxExecutionDelay, txExpiryDelay, maxApprovalDuration, emergencyTrigger, emergencyCaller);
        _setupGuard(30, 120, 3600, 31536000, msg.sender, msg.sender);
    }

    function queueTransaction() ensureEntrypoint public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to enqueue?"));
        _queueTransaction(actionBuilder);
    }

    function approveTransaction() ensureEntrypoint public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the address of the action builder you want to approve?"));
        _approveTransaction(actionBuilder);
    }

    function executeTransaction() ensureEntrypoint public {
        address actionBuilder = vm.parseAddress(vm.prompt("What's the transaction builder address you want to execute?"));
        _executeTransaction(actionBuilder);
    }

    function _setupGuard(uint256 shortTxExecutionDelay, uint256 longTxExecutionDelay, uint256 txExpiryDelay, uint256 maxApprovalDuration, address emergencyTrigger, address emergencyCaller) internal {
        vm.startBroadcast();
        entrypoint = ISafeEntrypoint(CanonRegistry.SAFE_ENTRYPOINT_FACTORY.createSafeEntrypoint(
            address(safe),
            shortTxExecutionDelay,
            longTxExecutionDelay,
            txExpiryDelay,
            maxApprovalDuration,
            emergencyTrigger,
            emergencyCaller
        ));
        console.log("Entrypoint deployed to: %s", address(entrypoint));

        address setGuardAction = CanonRegistry.SIMPLE_ACTIONS_FACTORY.createSimpleActions(
            ISimpleActions.SimpleAction(
                address(safe),
                "setGuard(address)",
                abi.encode(address(entrypoint)),
                0
            )
        );
        vm.stopBroadcast();
        console.log("Set guard simple action deployed to: %s", setGuardAction);

        bool enqueueConfirmation = _promptConfirmation("Entrypoint and set guard action successfully deployed. Would you like to enqueue the action into the entrypoint?");
        if (!enqueueConfirmation) {
            console.log("You can enqueue the action via the queueTransaction script");
            console.log("Detached entrypoint: %s", address(entrypoint));
            console.log("Action builder: %s", setGuardAction);
            return;
        }

        _queueTransaction(setGuardAction);
    }

    function _queueTransaction(address actionBuilder) internal {
        // Add transaction into the Entrypoint queue
        vm.startBroadcast();
        entrypoint.queueTransaction(actionBuilder);
        vm.stopBroadcast();

        bool approveConfirmation = _promptConfirmation("Transaction successfully queued. Would you like to approve this transaction in your Safe?");
        if (!approveConfirmation) {
            console.log("Signers can approve the action in your Safe via the approveTransaction script by using the following address as input: %s", actionBuilder);
            console.log("Or the signers can also directly call your Safe's (%s) method approveHash(%s)", address(safe), actionBuilder);
            if (isEntrypointDetached) {
                console.log("Detached entrypoint: %s", address(entrypoint));
            }
            return;
        }

        _approveTransaction(actionBuilder);
    }

    function _approveTransaction(address actionBuilder) internal {
        bytes32 safeTxHash = entrypoint.getSafeTransactionHash(actionBuilder);
        vm.startBroadcast();
        safe.approveHash(safeTxHash);
        vm.stopBroadcast();

        if (safeThreshold > 1) {
            console.log(
                "You will need %s more signatures to execute, the other signers will need to call your Safe (%s) method approveHash(%s), or use the approveTransaction script with the following address as input: %s",
                safeThreshold - 1,
                vm.toString(safeTxHash),
                actionBuilder
            );
        }

        (, uint256 _executableAt, uint256 _expiresAt) = entrypoint.queuedTransactions(actionBuilder);
        uint256 executableIn = _executableAt - block.timestamp;
        uint256 expiresIn = _expiresAt - block.timestamp;

        console.log("Your transaction will be executable in %s seconds", executableIn);
        console.log("Watch out, your transaction will also expire in %s seconds", expiresIn);
        console.log("You can execute the transaction via the executeTransaction script");
        if (isEntrypointDetached) {
            console.log("Detached entrypoint: %s", address(entrypoint));
        }
        console.log("Action builder: %s", actionBuilder);
    }

    function _executeTransaction(address actionBuilder) ensureEntrypoint internal {
        (, uint256 _executableAt, uint256 _expiresAt) = entrypoint.queuedTransactions(actionBuilder);
        int256 executableIn = int256(_executableAt) - int256(block.timestamp);
        int256 expiresIn = int256(_expiresAt) - int256(block.timestamp);

        if (expiresIn <= 0) {
            console.log("Your transaction expired %s seconds ago", -expiresIn);
            return;
        }
        if (executableIn > 0) {
            console.log("Your transaction will only be executable in %s seconds from now", executableIn);
            return;
        }

        bytes32 safeTxHash = entrypoint.getSafeTransactionHash(actionBuilder);
        address[] memory approvedHashSigners = _getApprovedHashSigners(safeTxHash);

        uint256 missingSignatures = safeThreshold - approvedHashSigners.length;
        if (missingSignatures > 0) {
            console.log(
                "You will need %s more signatures to execute, the other signers must call your Safe (%s) method approveHash(%s), or use the approveTransaction script with the following address as input: %s",
                missingSignatures,
                vm.toString(safeTxHash),
                actionBuilder
            );
            if (isEntrypointDetached) {
                console.log("Detached entrypoint: %s", address(entrypoint));
            }
        }

        vm.startBroadcast();
        entrypoint.executeTransaction(actionBuilder);
        vm.stopBroadcast();

        console.log("Transaction executed in your Safe");
    }

    modifier ensureEntrypoint {
        if (address(entrypoint) == address(0)) {
            bool confirmation = _promptConfirmation("Entrypoint not yet configured in your Safe. Would you like to specify your detached entrypoint address?");
            if (confirmation) {
                // TODO: check if valid entrypoint
                entrypoint = ISafeEntrypoint(vm.parseAddress(vm.prompt("Insert entrypoint address")));
                isEntrypointDetached = true;
            }
        }

        require (address(entrypoint) != address(0), "Canon Guard is not yet configured in your Safe");
        _;
    }

    function _promptConfirmation(string memory question) internal returns (bool confirmation) {
        string memory response = vm.prompt(string.concat(question, " y/(N)"));
        return _isEqual(response, "y") || _isEqual(response, "Y") || _isEqual(response, "Yes") || _isEqual(response, "YES");
    }

    /**
    * @notice Internal function to get the list of approved hash signers for a transaction
    * @param _safeTxHash The hash of the Safe transaction
    * @return _approvedHashSigners The array of approved hash signer addresses
    */
    function _getApprovedHashSigners(bytes32 _safeTxHash) internal view returns (address[] memory _approvedHashSigners) {
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