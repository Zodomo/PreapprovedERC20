// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {PreapprovedOzERC20} from "../PreapprovedOzERC20.sol";

contract OzERC20Example is PreapprovedOzERC20 {
    constructor(
        address[] memory preapprovals_
    ) PreapprovedOzERC20("OpenZeppelin ERC20 Example", "OZ_ERC20_EXAMPLE") {
        _preapprove(preapprovals_, true);
        _mint(msg.sender, 1_000_000 ether);
    }
}
