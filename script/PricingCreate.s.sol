//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "lib/forge-std/src/Script.sol";
import {PricingV1} from "../src/PricingV1.sol";
import {BondDepositoryV3} from "../src/BondDepositoryV3.sol";

contract PricingCreateScript is Script {
    BondDepositoryV3 public depo = BondDepositoryV3(payable(0xE58B33c813ac4077bd2519dE90FccB189a19FA71));
    PricingV1 public pricing = PricingV1(payable(0xD83CC6c47cb34ad767711aD412f017Ceb44137d3));

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        depo.reward(100_000 ether, address(pricing));
        pricing.create(100_000 ether, 0);
        vm.stopBroadcast();
    }
}