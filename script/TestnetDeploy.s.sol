// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "lib/forge-std/src/Script.sol";
import {MockUSDC} from "../src/testnet/MockUSDC.sol";

contract TestnetDeployScript is Script {

     function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        MockUSDC usdc = new MockUSDC();
        vm.stopBroadcast();
    }
}