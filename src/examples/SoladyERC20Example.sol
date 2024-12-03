// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {PreapprovedSoladyERC20} from "../PreapprovedSoladyERC20.sol";

contract SoladyERC20Example is PreapprovedSoladyERC20 {
    function name() public pure override returns (string memory) {
        return "Solady ERC20 Example";
    }

    function symbol() public pure override returns (string memory) {
        return "SOLADY_ERC20_EXAMPLE";
    }

    constructor(
        address[] memory preapprovals
    ) {
        _preapprove(preapprovals, true);
        _mint(msg.sender, 1_000_000 ether);
    }
}
