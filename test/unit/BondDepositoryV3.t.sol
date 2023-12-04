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
        vm.deal(address(koto), 1000 ether);
        vm.startPrank(koto.ownership());
        koto.transfer(address(koto), 500_000 ether);
        koto.launch();
        koto.approve(address(koto), type(uint256).max);
        koto.create(100_000 ether, 0);
    }

    function testConstructor() public {}

    function testBond() public {
        vm.deal(address(depository), 100 ether);
        vm.startPrank(depository.OWNER());
        depository.set(address(koto));
        depository.bond(1 ether);
        assertGt(koto.balanceOf(address(depository)), 0);
    }

    function testRedeem() public {
        uint256 pre = address(depository).balance;
        vm.deal(address(koto), 100 ether);
        vm.startPrank(depository.OWNER());
        depository.set(address(koto));
        koto.transfer(address(depository), 100 ether);
        depository.redeem(100 ether);
        assertGt(address(depository).balance, pre);
        assertEq(koto.balanceOf(address(depository)), 0);
    }

    function testBurn() public {
        vm.startPrank(depository.OWNER());
        depository.set(address(koto));
        koto.transfer(address(depository), 100 ether);
        depository.burn(100 ether);
        assertEq(koto.balanceOf(address(depository)), 0);
        assertEq(address(depository).balance, 0);
    }

    function testNotifyRewardAmount() public {
        vm.startPrank(depository.OWNER());
        koto.transfer(address(depository), 100 ether);
        depository.set(address(koto));
        depository.reward(1, address(voter));
        assertEq(koto.allowance(address(depository), address(voter)), type(uint256).max - 1);
    }

    function testSwap() public {}

    function testDeposit() public {
        vm.startPrank(depository.OWNER());
        depository.set(address(koto));
        koto.transfer(address(depository), 100_000 ether);
        assertEq(koto.balanceOf(address(depository)), 100_000 ether);
        vm.warp(block.timestamp + 90_000);
        depository.deposit(50_000 ether, 50_000 ether);
        assertEq(koto.balanceOf(address(depository)), 0);
    }

    function testEmergencyWithdraw() public {}

    function testSet() public {
        assertEq(depository.koto(), address(0));
        vm.prank(depository.OWNER());
        depository.set(address(koto));
        assertEq(address(koto), depository.koto());
        assertEq(koto.allowance(address(depository), depository.UNISWAP_ROUTER()), type(uint256).max);
        assertEq(koto.allowance(address(depository), address(koto)), type(uint256).max);
    }
}
