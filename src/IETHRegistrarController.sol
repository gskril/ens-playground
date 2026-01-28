// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IETHRegistrarController {
    function rentPrice(string memory name, uint256 duration) external view returns (uint256 price);

    function available(string memory name) external view returns (bool);

    function makeCommitmentWithConfig(string memory name, address owner, bytes32 secret, address resolver, address addr)
        external
        pure
        returns (bytes32);

    function commit(bytes32 commitment) external;

    function registerWithConfig(
        string memory name,
        address owner,
        uint256 duration,
        bytes32 secret,
        address resolver,
        address addr
    ) external payable;
}
