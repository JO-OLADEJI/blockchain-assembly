// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MaliciousReceiver} from "./MaliciousReceiver.sol";
import {ISimpleVault} from "../src/ISimpleVault.sol";

abstract contract Base_SimpleVaultTest is Test {
    address deployer = makeAddr("deployer");
    address alice = makeAddr("alice");

    ISimpleVault public vault;
    MaliciousReceiver maliciousReceiver;

    function setUp() public virtual {
        vm.startPrank(deployer);
        maliciousReceiver = new MaliciousReceiver();
        vm.stopPrank();
    }

    function test_constructor() public view {
        address owner = vault.owner();
        assertEq(deployer, vault.owner());
    }

    function test_deposit() public {
        uint256 amount = 1 ether;

        vm.startPrank(alice);
        vm.deal(alice, amount);

        vault.deposit{value: amount}();
        vm.stopPrank();

        assertEq(alice.balance, 0);
        assertEq(address(vault).balance, amount);
        assertEq(vault.balances(alice), amount);
    }

    function test_eoaTransferDeposit() public {
        uint256 amount = 1 ether;

        vm.startPrank(alice);
        vm.deal(alice, amount);

        address(vault).call{value: amount}("");
        vm.stopPrank();

        assertEq(alice.balance, 0);
        assertEq(address(vault).balance, amount);
        assertEq(vault.balances(alice), amount);
    }

    function testFuzz_deposit(uint256 _amount) public {
        vm.assume(_amount < type(uint256).max - address(vault).balance);
        uint256 initialAliceBalance = vault.balances(alice);
        uint256 initialVaultBalance = address(vault).balance;

        vm.startPrank(alice);
        vm.deal(alice, _amount);

        vault.deposit{value: _amount}();
        vm.stopPrank();

        assertEq(alice.balance, 0);
        assertEq(address(vault).balance, initialVaultBalance + _amount);
        assertEq(vault.balances(alice), initialAliceBalance + _amount);
    }

    // function testFuzz_deposit(address user, uint256 _amount) public {
    //     // vm.assume(_amount < type(uint256).max - address(vault).balance);

    //     uint256 amount = _amount;
    //     vm.assume(_amount > 582);
    //     // uint256 initialUserBalance = vault.balances(user);
    //     uint256 initialVaultBalance = address(vault).balance;

    //     vm.startPrank(user);
    //     vm.deal(user, _amount);
    //     assertEq(address(user).balance, _amount);

    //     vault.deposit{value: _amount}();
    //     vm.stopPrank();

    //     assertEq(address(user).balance, 0);
    //     assertEq(address(vault).balance, amount);
    //     assertEq(vault.balances(user), amount);
    // }

    function test_withdraw() public {
        uint256 amount = 1 ether;

        vm.startPrank(alice);
        vm.deal(alice, amount);

        vault.deposit{value: amount}();
        assertEq(alice.balance, 0);
        assertEq(address(vault).balance, amount);
        assertEq(vault.balances(alice), amount);

        vault.withdraw();
        vm.stopPrank();

        assertEq(alice.balance, amount);
        assertEq(address(vault).balance, 0);
        assertEq(vault.balances(alice), 0);
    }

    function testFuzz_withdraw(uint256 _depositAmount) public {
        vm.assume(_depositAmount < type(uint256).max - address(vault).balance);
        uint256 initialAliceBalance = vault.balances(alice);
        uint256 initialVaultBalance = address(vault).balance;

        vm.startPrank(alice);
        vm.deal(alice, _depositAmount);

        vault.deposit{value: _depositAmount}();
        assertEq(alice.balance, 0);
        assertEq(address(vault).balance, initialVaultBalance + _depositAmount);
        assertEq(vault.balances(alice), initialAliceBalance + _depositAmount);

        vault.withdraw();
        vm.stopPrank();

        assertEq(alice.balance, _depositAmount);
        assertEq(address(vault).balance, 0);
        assertEq(vault.balances(alice), 0);
    }

    function test_maliciousWithdraw() public {
        uint256 amount = 1 ether;

        maliciousReceiver.execute{value: amount}(
            address(vault),
            abi.encodeWithSelector(vault.deposit.selector)
        );

        assertEq(address(vault).balance, amount);
        assertEq(vault.balances(address(maliciousReceiver)), amount);

        vm.expectRevert(
            abi.encodeWithSelector(ISimpleVault.WithdrawError.selector)
        );
        vault.withdraw();
    }

    function test_revokeOwnership() public {
        assertEq(vault.owner(), deployer);

        vm.startPrank(deployer);
        vault.revokeOwnership();
        vm.stopPrank();

        assertEq(vault.owner(), address(0));
    }

    function test_unauthorizedRevokeOwnership() public {
        assertEq(vault.owner(), deployer);
        vm.startPrank(alice);

        vm.expectRevert(
            abi.encodeWithSelector(ISimpleVault.Unauthorized.selector)
        );
        vault.revokeOwnership();
        vm.stopPrank();
    }

    function test_owner() public view {
        assertEq(vault.owner(), deployer);
    }
}
