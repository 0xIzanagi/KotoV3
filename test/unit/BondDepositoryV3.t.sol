// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import {MockKotoV3} from "../helpers/MockKotoV3.sol";
import {BondDepositoryV3} from "../../src/BondDepositoryV3.sol";

contract BondDepositoryV3Test is Test {
    MockKotoV3 public koto;
    BondDepositoryV3 public depository;

    function setUp() public {
        depository = new BondDepositoryV3();
        koto = new MockKotoV3(address(depository));
    }
}
