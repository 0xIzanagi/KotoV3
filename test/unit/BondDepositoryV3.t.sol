// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import {MockKotoV3} from "../helpers/MockKotoV3.sol";
import {BondDepositoryV3} from "../../src/BondDepositoryV3.sol";
import {MockVoter} from "../helpers/MockVoter.sol";

contract BondDepositoryV3Test is Test {
    MockKotoV3 public koto;
    BondDepositoryV3 public depository;
    MockVoter public voter;

    function setUp() public {
        depository = new BondDepositoryV3();
        koto = new MockKotoV3(address(depository));
        voter = new MockVoter(address(koto));
    }

    function testConstructor() public {}

    function testBond() public {}

    function testRedeem() public {}

    function testBurn() public {}

    function testNotifyRewardAmount() public {}

    function testSwap() public {}

    function testDeposit() public {}

    function testEmergencyWithdraw() public {}

    function testSet() public {}
}
