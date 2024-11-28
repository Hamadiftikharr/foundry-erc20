// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        vm.deal(user1, 1 ether); // Fund user1 with ETH for gas
        vm.deal(user2, 1 ether); // Fund user2 with ETH for gas
    }

    // Test the initial supply is set correctly
    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    // Test that users cannot mint new tokens
    function testUsersCantMint() public {
        vm.expectRevert("function selector was not recognized");
        // Attempt to call a non-existent mint function on the contract
        (bool success, ) = address(ourToken).call(
            abi.encodeWithSignature("mint(address,uint256)", address(this), 1)
        );
        assertFalse(success);
    }

    // Test transferring tokens between accounts
    function testTransferTokens() public {
        uint256 transferAmount = 1000 ether;

        // Mint some tokens to user1 for testing
        deal(address(ourToken), user1, transferAmount);

        // Ensure user1 balance is updated
        assertEq(ourToken.balanceOf(user1), transferAmount);

        // Transfer tokens from user1 to user2
        vm.prank(user1);
        ourToken.transfer(user2, transferAmount);

        // Check final balances
        assertEq(ourToken.balanceOf(user1), 0);
        assertEq(ourToken.balanceOf(user2), transferAmount);
    }

    // Test transfers revert when the sender has insufficient balance
    function testTransferRevertsOnInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert();
        ourToken.transfer(user2, 1 ether);
    }

    // Test allowances: approve and transferFrom
    function testAllowanceWorks() public {
        uint256 approveAmount = 500 ether;

        // Approve user2 to spend tokens on behalf of user1
        vm.prank(user1);
        ourToken.approve(user2, approveAmount);

        // Check allowance is set
        assertEq(ourToken.allowance(user1, user2), approveAmount);

        // Mint tokens to user1 for testing
        deal(address(ourToken), user1, approveAmount);

        // Perform transferFrom using allowance
        vm.prank(user2);
        ourToken.transferFrom(user1, user2, approveAmount);

        // Check balances and allowance after transfer
        assertEq(ourToken.balanceOf(user1), 0);
        assertEq(ourToken.balanceOf(user2), approveAmount);
        assertEq(ourToken.allowance(user1, user2), 0);
    }

    // Test that transferFrom reverts when the spender tries to exceed allowance
    function testTransferFromRevertsOnExceedingAllowance() public {
        uint256 approveAmount = 500 ether;

        // Approve user2 to spend tokens on behalf of user1
        vm.prank(user1);
        ourToken.approve(user2, approveAmount);

        // Attempt transfer exceeding allowance
        vm.prank(user2);
        vm.expectRevert();
        ourToken.transferFrom(user1, user2, approveAmount + 1 ether);
    }

    // Test that approve overwrites previous allowance
    function testApproveOverwritesPreviousAllowance() public {
        uint256 firstApproveAmount = 500 ether;
        uint256 secondApproveAmount = 300 ether;

        // Approve user2 with the first amount
        vm.prank(user1);
        ourToken.approve(user2, firstApproveAmount);
        assertEq(ourToken.allowance(user1, user2), firstApproveAmount);

        // Overwrite allowance with a second approval
        vm.prank(user1);
        ourToken.approve(user2, secondApproveAmount);
        assertEq(ourToken.allowance(user1, user2), secondApproveAmount);
    }

    function testBurnTokens() public {
        uint256 initialBalance = 1000 ether;
        uint256 burnAmount = 500 ether;

        // Mint tokens to user1 for testing
        deal(address(ourToken), user1, initialBalance);

        // Attempt to burn tokens by transferring to the zero address
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature("ERC20InvalidReceiver(address)", address(0))
        );
        ourToken.transfer(address(0), burnAmount);

        // Verify that the balance and total supply remain unchanged
        assertEq(ourToken.balanceOf(user1), initialBalance);
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    // Test approve and transferFrom when allowance is partially used
    function testPartialAllowanceUsage() public {
        uint256 approveAmount = 1000 ether;
        uint256 transferAmount = 500 ether;

        // Approve user2 to spend tokens on behalf of user1
        vm.prank(user1);
        ourToken.approve(user2, approveAmount);

        // Mint tokens to user1
        deal(address(ourToken), user1, approveAmount);

        // Use part of the allowance
        vm.prank(user2);
        ourToken.transferFrom(user1, user2, transferAmount);

        // Check remaining allowance
        assertEq(
            ourToken.allowance(user1, user2),
            approveAmount - transferAmount
        );
        assertEq(ourToken.balanceOf(user1), approveAmount - transferAmount);
        assertEq(ourToken.balanceOf(user2), transferAmount);
    }

    function testTransferToZeroAddressReverts() public {
        uint256 transferAmount = 100 ether;

        // Mint tokens to user1 for testing
        deal(address(ourToken), user1, transferAmount);

        // Expect the transfer to zero address to revert with the custom error
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature("ERC20InvalidReceiver(address)", address(0))
        );
        ourToken.transfer(address(0), transferAmount);

        // Verify that the balance of user1 remains unchanged
        assertEq(ourToken.balanceOf(user1), transferAmount);
    }

    function testConstructorInitializesCorrectly() public view {
        uint256 expectedSupply = 1e21; // Expected initial supply
        assertEq(ourToken.totalSupply(), expectedSupply); // Check total supply
        assertEq(ourToken.balanceOf(address(msg.sender)), expectedSupply); // Check deployer’s balance
    }
}
