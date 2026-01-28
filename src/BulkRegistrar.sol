// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./IETHRegistrarController.sol";

contract BulkRegistrar {
    error InsufficientFunds();
    error SendExcessFundsFailed();

    IETHRegistrarController public immutable CONTROLLER =
        IETHRegistrarController(0x283Af0B28c62C092C9727F1Ee09c02CA627EB7F5);

    function available(string[] memory names) external view returns (bool[] memory) {
        uint256 length = names.length;
        bool[] memory availability = new bool[](length);
        for (uint256 i; i < length;) {
            availability[i] = CONTROLLER.available(names[i]);
            unchecked {
                ++i;
            }
        }

        return availability;
    }

    /// @notice Helper to check if a batch of names are the same price, and therefore safe to use with
    /// `multiRegister()`.
    function canBatch(string[] memory names) external view returns (bool) {
        uint256 length = names.length;
        uint256 duration = 31536000;
        uint256 firstPrice = CONTROLLER.rentPrice(names[0], duration);

        for (uint256 i; i < length;) {
            if (CONTROLLER.rentPrice(names[i], duration) != firstPrice) {
                return false;
            }
            unchecked {
                ++i;
            }
        }

        return true;
    }

    function makeCommitments(string[] memory names, address owner, bytes32 secret, address resolver)
        external
        view
        returns (bytes32[] memory)
    {
        uint256 length = names.length;
        bytes32[] memory commitments = new bytes32[](length);
        for (uint256 i; i < length;) {
            commitments[i] = CONTROLLER.makeCommitmentWithConfig(names[i], owner, secret, resolver, owner);
            unchecked {
                ++i;
            }
        }

        return commitments;
    }

    /// @notice Helper to get the prices of a batch of names.
    function prices(string[] memory names, uint256 duration) external view returns (uint256[] memory) {
        uint256 length = names.length;
        uint256[] memory p = new uint256[](length);
        for (uint256 i; i < length;) {
            p[i] = CONTROLLER.rentPrice(names[i], duration);
            unchecked {
                ++i;
            }
        }

        return p;
    }

    function multiCommit(bytes32[] calldata commitments) external {
        uint256 length = commitments.length;
        for (uint256 i; i < length;) {
            CONTROLLER.commit(commitments[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Should be used with names that are the same price and not in temporary premium.
    /// For example, you can batch "aaaaa.eth" and "bbbbb.eth" but not "aaa.eth" and "bbbbb.eth".
    /// @dev Inidividual name price is not checked for gas efficiency, and should be validated before calling this
    /// function. Must be used with a resolver that implements `setAddr(bytes32, address)`.
    function multiRegister(string[] calldata names, address owner, uint256 duration, bytes32 secret, address resolver)
        external
        payable
    {
        uint256 length = names.length;
        uint256 unitPrice = CONTROLLER.rentPrice(names[0], duration);
        if (msg.value < unitPrice * length) revert InsufficientFunds();

        for (uint256 i; i < length;) {
            CONTROLLER.registerWithConfig{value: unitPrice}(names[i], owner, duration, secret, resolver, owner);
            unchecked {
                ++i;
            }
        }

        // Send any excess funds back. The contract doesn't hold ETH, so entire balance is excess.
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) {
            revert SendExcessFundsFailed();
        }
    }
}
