// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

contract MaliciousReceiver {
    function execute(
        address target,
        bytes memory data
    ) external payable returns (bool success) {
        (success, ) = target.call{value: msg.value}(data);
    }

    receive() external payable {
        revert();
    }
}
