// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Script.sol";
import {KotoV3} from "../src/KotoV3.sol";

contract DeployKotoScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new KotoV3();
        vm.stopBroadcast();
    }
}
