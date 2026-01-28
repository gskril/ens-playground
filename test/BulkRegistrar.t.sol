// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {BulkRegistrar} from "../src/BulkRegistrar.sol";

contract BulkRegistrarTest is Test {
    BulkRegistrar public bulkRegistrar;
    address public user = makeAddr("user");
    address public publicResolver = 0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63;

    // Accept refunds from overflow
    receive() external payable {}

    function setUp() public {
        vm.createSelectFork("https://ethereum-rpc.publicnode.com", 24330000);
        bulkRegistrar = new BulkRegistrar();
    }

    function test_available() public view {
        string[] memory labels = new string[](3);
        uint256 length = labels.length;
        labels[0] = "lkjasdf";
        labels[1] = "bbbbb";
        labels[2] = "ccccc";

        bool[] memory expected = new bool[](length);
        expected[0] = true;
        expected[1] = false;
        expected[2] = false;

        bool[] memory availability = bulkRegistrar.available(labels);
        for (uint256 i; i < length;) {
            assertEq(availability[i], expected[i]);
            unchecked {
                ++i;
            }
        }
    }

    function test_invalidBatch() public view {
        string[] memory labels = new string[](3);
        labels[0] = "aaa";
        labels[1] = "bbbb";
        labels[2] = "ccccc";

        bool canBatch = bulkRegistrar.canBatch(labels);
        assertEq(canBatch, false);
    }

    function test_validBatch() public view {
        string[] memory labels = new string[](3);
        labels[0] = "aaaaa";
        labels[1] = "bbbbb";
        labels[2] = "ccccc";

        bool canBatch = bulkRegistrar.canBatch(labels);
        assertEq(canBatch, true);
    }

    function test_register() public {
        string[] memory labels = new string[](3);
        labels[0] = "lkjasdf";
        labels[1] = "ljkasaf";
        labels[2] = "ljkasdf";

        bytes32[] memory commitments = bulkRegistrar.makeCommitments(labels, user, bytes32(0), publicResolver);
        bulkRegistrar.multiCommit(commitments);

        skip(60);

        uint256 totalPrice;
        uint256[] memory prices = bulkRegistrar.prices(labels, 31536000);
        for (uint256 i; i < prices.length;) {
            totalPrice += prices[i];
            unchecked {
                ++i;
            }
        }

        bulkRegistrar.multiRegister{value: totalPrice}(labels, user, 31536000, bytes32(0), publicResolver);
    }
}
