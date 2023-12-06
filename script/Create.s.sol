// SPDX-License-Identifir: UNLICENSED

pragma solidity 0.8.23;

import {BondDepositoryV3} from "../src/BondDepositoryV3.sol";
import "forge-std/Script.sol";

import {IERC20Minimal} from "../src/interfaces/IERC20Minimal.sol";

contract CreateScript is Script {
    address public koto = 0x64C7d8C8Abf28Daf9D441c507CfE9Be678A0929c;
    BondDepositoryV3 public depository = BondDepositoryV3(payable(0xE58B33c813ac4077bd2519dE90FccB189a19FA71));

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        depository.deposit(100_000 ether, 0);
        vm.stopBroadcast();
    }
}
