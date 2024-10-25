// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/RootFinder.sol";

contract DeployRootFinder is Script {
    function run() external {
        // Begin broadcasting transactions
        vm.startBroadcast();

        // Deploy the RootFinder contract
        RootFinder rootFinder = new RootFinder();

        // Log the address of the deployed contract
        console.log("RootFinder deployed at:", address(rootFinder));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
