// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../BridgeV2PoC.sol";

/**
 * @notice Foundry test demonstrating the CEI bug and fix
 *
 * Run with: forge test -vv
 */
contract BridgeV2PoCTest is Test {
    BridgeV2PoC poc;
    bytes32 constant TEST_PAYLOAD = keccak256("test-payload-1");

    function setUp() public {
        poc = new BridgeV2PoC();
        payable(address(poc)).transfer(10 ether);
    }

    // DEMONSTRATES THE BUG
    function test_BadVersion_locksFunds() public {
        // Try to withdraw to zero address — will revert
        vm.expectRevert("Recipient cannot be zero address");
        poc.handlePayload_bad(TEST_PAYLOAD, address(0), 1 ether);

        // The withdrawal failed, but...
        assertTrue(poc.payloadSpent(TEST_PAYLOAD), "Payload marked spent despite revert");
        // Funds are stuck! User cannot retry.
    }

    // DEMONSTRATES THE FIX
    function test_FixedVersion_allowsRetry() public {
        // Try to withdraw to zero address — will revert
        vm.expectRevert("Recipient cannot be zero address");
        poc.handlePayload_fixed(TEST_PAYLOAD, address(0), 1 ether);

        // The withdrawal failed and...
        assertFalse(poc.payloadSpent(TEST_PAYLOAD), "Payload NOT marked spent");
        // User can retry with correct address!
    }

    function test_FixedVersion_succeeds() public {
        address recipient = makeAddr("recipient");

        // First withdrawal succeeds
        poc.handlePayload_fixed(TEST_PAYLOAD, recipient, 1 ether);
        assertTrue(poc.payloadSpent(TEST_PAYLOAD), "Payload marked spent after success");
        assertEq(recipient.balance, 1 ether, "Recipient received funds");
    }
}
