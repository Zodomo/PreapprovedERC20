// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {ERC20} from "../lib/solady/src/tokens/ERC20.sol";

/// @title Solady ERC20 with Preapprovals
/// @notice Abstract ERC20 contract that preapproves addresses for transfers.
/// @author Zodomo <https://github.com/Zodomo>
/// @dev Exercise caution when preapproving addresses. `_preapprove` functions should only be used in the constructor
/// or initializer functions, as calls in external functions could be attacked to rug all holders.
abstract contract PreapprovedSoladyERC20 is ERC20 {
    /// @dev Emitted when an address is preapproved.
    /// @param addr The address that was preapproved.
    /// @param approved Whether the address was preapproved.
    event Preapproved(address indexed addr, bool approved);

    /// @dev The allowance slot of (`owner`, `spender`) is given by:
    /// ```
    ///     mstore(0x20, spender)
    ///     mstore(0x0c, _ALLOWANCE_SLOT_SEED)
    ///     mstore(0x00, owner)
    ///     let allowanceSlot := keccak256(0x0c, 0x34)
    /// ```
    /// NOTE: This was directly copied from the imported Solady ERC20 contract due to its private scope.
    uint256 private constant _ALLOWANCE_SLOT_SEED = 0x7f5e9f20;

    /// @dev A mapping of addresses to their preapproval status.
    mapping(address => bool) private _preapproved;

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

    /// @dev Checks if the `from` address has applied the preapproval for the caller.
    /// This is necessary as Solady's transferFrom function does not call the allowance function.
    /// @param from The address to check for preapproval.
    /// @return preapprovalActive Whether the `from` address has applied the preapproval for the caller.
    function _checkPreapproval(
        address from
    ) internal view returns (bool) {
        bool preapprovalActive;
        assembly {
            let from_ := shl(96, from)
            // Compute the allowance slot and load its value.
            mstore(0x20, caller())
            mstore(0x0c, or(from_, _ALLOWANCE_SLOT_SEED))
            let allowanceSlot := keccak256(0x0c, 0x34)
            let allowance_ := sload(allowanceSlot)
            preapprovalActive := iszero(not(allowance_))
        }
        return preapprovalActive;
    }

    /// @dev Prior to transfer, ensure the preapproval is fully applied.
    /// @param from The address of the token holder.
    /// @inheritdoc ERC20
    function _beforeTokenTransfer(address from, address, uint256) internal virtual override {
        if (_preapproved[msg.sender]) {
            bool preapprovalActive = _checkPreapproval(from);
            if (!preapprovalActive) {
                _approve(from, msg.sender, type(uint256).max);
            }
        }
    }
}
