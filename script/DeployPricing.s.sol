// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Script.sol";
import {PricingV1} from "../src/PricingV1.sol";

contract DeployPricingScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new PricingV1();
        vm.stopBroadcast();
    }
}
