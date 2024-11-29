// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

contract SimpleSolVault {
    error WithdrawError();
    error Unauthorized();

    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: balance}("");
        if (!success) {
            revert WithdrawError();
        }
    }

    function revokeOwnership() external {
        if (msg.sender != owner) {
            revert Unauthorized();
        }

        owner = address(0);
    }

    receive() external payable {
        deposit();
    }
}
