// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @title OpenZeppelin ERC20 with Preapprovals
/// @notice Abstract ERC20 contract that preapproves addresses for transfers.
/// @author Zodomo <https://github.com/Zodomo>
/// @dev Exercise caution when preapproving addresses. `_preapprove` functions should only be used in the constructor
/// or initializer functions, as calls in external functions could be attacked to rug all holders.
abstract contract PreapprovedOzERC20 is ERC20 {
    /// @dev Emitted when an address is preapproved.
    /// @param addr The address that was preapproved.
    /// @param approved Whether the address was preapproved.
    event Preapproved(address indexed addr, bool approved);

    /// @dev A mapping of addresses to their preapproval status.
    mapping(address => bool) private _preapproved;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /// @dev Checks if an address is preapproved.
    /// @param addr The address to check.
    /// @return preapproved Whether the address is preapproved.
    function isPreapproved(
        address addr
    ) public view returns (bool) {
        return _preapproved[addr];
    }

    /// @dev Overrides the allowance function to handle preapprovals.
    /// @inheritdoc ERC20
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        if (_preapproved[spender]) {
            return type(uint256).max;
        }
        return super.allowance(owner, spender);
    }

    /// @dev Preapproves an address.
    /// It is dangerous to utilize this function outside of a constructor or initializer function.
    /// @param addr The address to preapprove.
    /// @param approved Whether to preapprove the address.
    function _preapprove(address addr, bool approved) internal {
        _preapproved[addr] = approved;
        emit Preapproved(addr, approved);
    }

    /// @dev Preapproves a list of addresses.s
    /// It is dangerous to utilize this function outside of a constructor or initializer function.
    /// @param addrs The addresses to preapprove.
    /// @param approved Whether to preapprove the addresses.
    function _preapprove(address[] memory addrs, bool approved) internal {
        for (uint256 i = 0; i < addrs.length; i++) {
            _preapprove(addrs[i], approved);
        }
    }
}
