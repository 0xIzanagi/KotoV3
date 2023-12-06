//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import {KotoV3} from "../src/KotoV3.sol";
import {PricingV1} from "../src/PricingV1.sol";
import "forge-std/Test.sol";

contract PricingTest is Test {
    KotoV3 public koto = KotoV3(payable(0x64C7d8C8Abf28Daf9D441c507CfE9Be678A0929c));
    PricingV1 public pricing;

    function setUp() public {
        pricing = new PricingV1();
    }
}
