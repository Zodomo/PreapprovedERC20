<a id="readme-top"></a>

<a href="https://soliditylang.org/">
    <img alt="Languages" src="https://img.shields.io/github/languages/top/Zodomo/PreapprovedERC20?logo=solidity&style=flat" />
</a>
<a href="https://github.com/Zodomo/PreapprovedERC20/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/Zodomo/PreapprovedERC20?style=flat&color=0088ff" />
</a>
<a href="https://github.com/Zodomo/PreapprovedERC20/pulls">
    <img alt="Pull Request" src="https://img.shields.io/github/issues-pr/Zodomo/PreapprovedERC20?style=flat&color=0088ff" />
</a>
<a href="https://github.com/Zodomo/PreapprovedERC20/graphs/contributors">
    <img alt="Contributors" src="https://img.shields.io/github/contributors/Zodomo/PreapprovedERC20?style=flat" />
</a>
<a href="">
    <img alt="Stars" src="https://img.shields.io/github/stars/Zodomo/PreapprovedERC20" />
</a>
<a href="">
    <img alt="Forks" src="https://img.shields.io/github/forks/Zodomo/PreapprovedERC20" />
</a>

<br />

# Preapproved ERC20 Contracts

This repository contains specialized ERC20 implementations that enable permanent preapprovals for specific addresses. These contracts are built on top of both Solady and OpenZeppelin ERC20 implementations. These contracts have not been subject of an audit, so use at your own risk. However, tests are provided proving the logic works as intended.

## Table of Contents

- [Overview](#overview)
- [TODO](#todo)
- [⚠️ Security Considerations](#️-security-considerations) 
- [Usage](#usage)
  - [Inheritance](#inheritance)
  - [Key Functions](#key-functions)
  - [Gas Efficiency](#gas-efficiency)
  - [Installation](#installation)
- [Contributing](#contributing)
- [License](#license)

## Overview

The contracts introduce a preapproval mechanism that allows designated addresses to transfer tokens on behalf of any holder without requiring explicit approval transactions. This is particularly useful for:

- Gas-efficient token transfers in complex DeFi protocols
- Automated token management systems
- Reducing friction in token transfer workflows

Two implementations are provided:
- `PreapprovedSoladyERC20`: Built on Solady's gas-optimized ERC20
- `PreapprovedOzERC20`: Built on OpenZeppelin's standard ERC20

## TODO

- Add a revokable version of the contracts
- Add an enumerable version of the contracts
- Add ERC721, ERC1155, and ERC6909 versions

## ⚠️ Security Considerations

**IMPORTANT**: These contracts come with significant security implications that must be carefully considered:

1. Preapprovals should **only** be set in the constructor or initializer functions. Configurability would allow the contract owner to add malicious approvals later.
2. Preapproved addresses have unlimited authority to transfer tokens from any holder. Limit their use to DEXes and popular safe applications.
3. Preapprovals cannot be revoked by token holders. This is specifically done to reduce gas costs. A revokable version can be implemented by request or contribution.
4. If preapproval logic is exposed in external functions, it could be exploited to drain all holder balances, even if they're permissioned.
5. Preapproved contracts must not have any functions that have a configurable `from` address parameter. Such contracts could allow anyone to transfer tokens from any holder.

## Usage

### Inheritance

Create your token contract by inheriting from either implementation:

```solidity
// Using Solady version inside constructor
contract MyToken is PreapprovedSoladyERC20 {
    constructor() {
        // Preapprove a single address
        _preapprove(address(0x123...), true);
        
        // Or preapprove multiple addresses
        address[] memory addresses = new address[](2);
        addresses[0] = address(0x123...);
        addresses[1] = address(0x456...);
        _preapprove(addresses, true);
    }
}

// Using Solady version with constructor arguments
contract MyToken is PreapprovedSoladyERC20 {
    constructor(address[] memory preapprovals_) {
        _preapprove(preapprovals_, true);
    }
}

// Using OpenZeppelin version inside constructor
contract MyToken is PreapprovedOzERC20 {
    constructor() PreapprovedOzERC20("MyToken", "MTK") {
        _preapprove(address(0x123...), true);
    }
}

// Using OpenZeppelin version with constructor arguments
contract MyToken is PreapprovedOzERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory preapprovals_
    ) PreapprovedOzERC20(name_, symbol_) {
        _preapprove(preapprovals_, true);
    }
}
```

If using upgradeable or initializable contracts, make sure to ONLY call `_preapprove` in `initializer` functions.

### Key Functions

- `isPreapproved(address)`: Check if an address is preapproved
- `allowance(address, address)`: Returns `type(uint256).max` for preapproved spenders
- `_preapprove(address, bool)`: Set preapproval status for a single address
- `_preapprove(address[], bool)`: Set preapproval status for multiple addresses

### Gas Efficiency

The Solady implementation (`PreapprovedSoladyERC20`) is recommended for gas-sensitive applications as it inherits Solady's gas optimizations. The OpenZeppelin implementation (`PreapprovedOzERC20`) provides a more standard approach with slightly higher gas costs.

### Installation

```bash
forge init MyProject
forge install Zodomo/PreapprovedERC20
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b username/feature-name`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin username/feature-name`)
5. Open a Pull Request

## License

This project is licensed under GPL-3.0.