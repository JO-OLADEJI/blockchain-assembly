// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

interface ISimpleVault {
    error WithdrawError();
    error Unauthorized();

    function owner() external view returns (address);

    function balances(address _user) external view returns (uint256);

    function deposit() external payable;

    function withdraw() external;

    function revokeOwnership() external;
}
