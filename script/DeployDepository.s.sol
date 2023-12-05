// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Script.sol";
import {BondDepositoryV3} from "../src/BondDepositoryV3.sol";

contract DeployDepositoryScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new BondDepositoryV3();
        vm.stopBroadcast();
    }
}
