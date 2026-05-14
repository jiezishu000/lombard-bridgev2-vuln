// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BridgeV2 PoC — CEI Violation
 * @notice Demonstrates how setting payloadSpent BEFORE _withdraw
 *         can permanently lock cross-chain funds.
 */
contract BridgeV2PoC {
    mapping(bytes32 => bool) public payloadSpent;
    mapping(address => uint256) public balances;

    event WithdrawalFailed(bytes32 indexed payloadId, address recipient, uint256 amount);

    // VULNERABLE VERSION — CEI violation
    function handlePayload_bad(
        bytes32 payloadId,
        address recipient,
        uint256 amount
    ) external {
        require(!payloadSpent[payloadId], "Already spent");

        // BUG: Mark spent BEFORE withdrawal
        payloadSpent[payloadId] = true;

        // Simulate withdrawal that CAN fail
        _withdraw(recipient, amount);

        // If _withdraw reverts, payloadSpent[payloadId] is permanently true
        // Funds are stuck forever
    }

    // FIXED VERSION — CEI compliant
    function handlePayload_fixed(
        bytes32 payloadId,
        address recipient,
        uint256 amount
    ) external {
        require(!payloadSpent[payloadId], "Already spent");

        // First: external interaction
        _withdraw(recipient, amount);

        // Then: state change (Effects after Interactions)
        payloadSpent[payloadId] = true;
    }

    function _withdraw(address recipient, uint256 amount) internal {
        // Simulate a failing condition (e.g., recipient contract rejects)
        if (recipient == address(0)) {
            revert("Recipient cannot be zero address");
        }
        // Additional checks can fail here (e.g., daily limit)
        require(amount <= address(this).balance, "Insufficient balance");

        payable(recipient).transfer(amount);
    }

    // Test helper
    receive() external payable {}

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}
