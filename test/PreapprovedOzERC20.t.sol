// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {IERC20Errors} from "../lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";
import {OzERC20Example} from "../src/examples/OzERC20Example.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract PreapprovedOzERC20Test is Test {
    OzERC20Example token;

    address public preapproved;
    address public notPreapproved;

    function setUp() public {
        preapproved = makeAddr("preapproved");
        notPreapproved = makeAddr("notPreapproved");
        address[] memory preapprovals = new address[](1);
        preapprovals[0] = preapproved;
        token = new OzERC20Example(preapprovals);
    }

    function test_preapproval_succeeds() public {
        assertEq(token.isPreapproved(preapproved), true);
        assertEq(token.allowance(address(0), preapproved), type(uint256).max);
        assertEq(token.allowance(address(this), preapproved), type(uint256).max);

        vm.startPrank(preapproved);
        token.transferFrom(address(this), address(0xdead), 1 ether);
        assertEq(token.balanceOf(address(0xdead)), 1 ether);
        token.transferFrom(address(0xdead), preapproved, 1 ether);
        assertEq(token.balanceOf(preapproved), 1 ether);
        vm.stopPrank();
    }

    function test_preapproval_notPreapproved_reverts() public {
        assertEq(token.isPreapproved(notPreapproved), false);
        assertEq(token.allowance(address(0), notPreapproved), 0);
        assertEq(token.allowance(address(this), notPreapproved), 0);

        vm.startPrank(notPreapproved);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, notPreapproved, 0, 1 ether)
        );
        token.transferFrom(address(this), notPreapproved, 1 ether);
        vm.stopPrank();
    }
}
