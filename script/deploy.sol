// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ISimpleVault} from "../src/ISimpleVault.sol";

import {SimpleVaultSolc} from "../src/SimpleVault.sol";
import {SimpleVaultYul} from "../src/SimpleVault.yul.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract DeployScript is Script {
    uint256 ghostSigner = 0x79f213a42315de5623fb9771d9d51ac1ff6a11cdde89cca5f63ad89e9c531593;

    function run(string memory target) public {
        vm.startBroadcast(ghostSigner);
        ISimpleVault vault;

        if (
            keccak256(abi.encodePacked(target)) ==
            keccak256(abi.encodePacked("solidity"))
        ) {
            vault = ISimpleVault(new SimpleVaultSolc());
        } else if (
            keccak256(abi.encodePacked(target)) ==
            keccak256(abi.encodePacked("yul"))
        ) {
            vault = ISimpleVault(new SimpleVaultYul());
        } else if (
            keccak256(abi.encodePacked(target)) ==
            keccak256(abi.encodePacked("huff"))
        ) {
            // vault = ISimpleVault(
            //     HuffDeployer.deploy("SimpleVault")
            // );
            console.log("working on fix with the foundry-huff repository");
        } else {
            console.log("Invalid bytecode target!");
        }
        
        vm.stopBroadcast();
    }
}
