// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {Base_SimpleVaultTest} from "./Base_SimpleVault.t.sol";
import {ISimpleVault} from "../src/ISimpleVault.sol";
import {SimpleVaultYul} from "../src/SimpleVault.yul.sol";

contract SimpleVaultYulTest is Base_SimpleVaultTest {
    function setUp() public override {
        super.setUp();
        vm.startPrank(deployer);
        vault = ISimpleVault(new SimpleVaultYul());
        vm.stopPrank();
    }
}
