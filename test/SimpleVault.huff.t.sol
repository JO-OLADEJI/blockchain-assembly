// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {Base_SimpleVaultTest} from "./Base_SimpleVault.t.sol";
import {ISimpleVault} from "../src/ISimpleVault.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract SimpleVaultHuffTest is Base_SimpleVaultTest {
    function setUp() public override {
        super.setUp();
        vault = ISimpleVault(
            HuffDeployer.config().with_deployer(deployer).deploy("SimpleVault")
        );
    }
}
