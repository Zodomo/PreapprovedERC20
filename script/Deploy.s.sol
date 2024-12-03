// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {SoladyERC20Example} from "../src/examples/SoladyERC20Example.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract DeployScript is Script {
    SoladyERC20Example public token;
    uint256 internal deployerPrivateKey;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.createSelectFork("sepolia");
    }

    function deploy() public {
        address[] memory preapprovals = new address[](7);
        preapprovals[0] = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD; // Uniswap V3 Universal Router
        preapprovals[1] = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E; // Uniswap V3 SwapRouter02
        preapprovals[2] = 0x1238536071E1c677A632429e3655c799b22cDA52; // Uniswap V3 NonfungiblePositionManager
        preapprovals[3] = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3; // Uniswap V2 Router02
        preapprovals[4] = 0x93c31c9C729A249b2877F7699e178F4720407733; // Sushiswap V3 SwapRouter
        preapprovals[5] = 0x544bA588efD839d2692Fc31EA991cD39993c135F; // Sushiswap V3 NonfungiblePositionManager
        preapprovals[6] = 0xeaBcE3E74EF41FB40024a21Cc2ee2F5dDc615791; // Sushiswap V2 Router02

        vm.startBroadcast(deployerPrivateKey);
        token = new SoladyERC20Example(preapprovals);
        vm.stopBroadcast();
    }
}
