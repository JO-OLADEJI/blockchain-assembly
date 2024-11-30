// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {ISimpleVault} from "./ISimpleVault.sol";

contract SimpleVaultYul is ISimpleVault {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        assembly {
            sstore(owner.slot, caller())
        }
    }

    function deposit() public payable {
        assembly {
            mstore(0x00, caller())
            mstore(0x20, balances.slot)
            mstore(0x00, keccak256(0x00, 0x40))
            mstore(0x20, sload(mload(0x00)))
            sstore(mload(0x00), add(mload(0x20), callvalue()))
        }
    }

    function withdraw() external {
        assembly {
            mstore(0x00, caller())
            mstore(0x20, balances.slot)
            mstore(0x00, keccak256(0x00, 0x40))
            mstore(0x20, sload(mload(0x00)))

            sstore(mload(0x00), 0x00)

            let success := call(
                gas(),
                caller(),
                mload(0x20),
                0x00,
                0x00,
                0x00,
                0x00
            )

            if iszero(success) {
                mstore(0x80, 0xd4771574)
                revert(0x9c, 0x04)
            }
        }
    }

    function revokeOwnership() external {
        assembly {
            if iszero(eq(caller(), sload(owner.slot))) {
                mstore(0x00, 0x82b42900)
                revert(0x1c, 0x04)
            }
            sstore(owner.slot, 0x00)
        }
    }

    receive() external payable {
        deposit();
    }
}
