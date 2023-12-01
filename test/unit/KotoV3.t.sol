// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import {MockKotoV3} from "../helpers/MockKotoV3.sol";
import {BondDepositoryV3} from "../../src/BondDepositoryV3.sol";

contract KotoV3Test is Test {
    MockKotoV3 public koto;
    BondDepositoryV3 public depository;
    address public alice = address(0x01);

    function setUp() public {
        depository = new BondDepositoryV3();
        koto = new MockKotoV3(address(depository));
    }

    function testTransfer(uint256 _value, address _to) public {
        vm.startPrank(koto.ownership());
        if (_value > 8_500_000 ether) {
            vm.expectRevert(MockKotoV3.InsufficentBalance.selector);
            koto.transfer(alice, _value);
        } else if (_value > 0) {
            koto.transfer(alice, _value);
            assertEq(koto.balanceOf(koto.ownership()), 8_500_000 ether - _value);
            assertEq(koto.balanceOf(alice), _value);
        } else {
            vm.expectRevert(MockKotoV3.InvalidTransfer.selector);
            koto.transfer(alice, _value);
        }
        if (_to == address(0) && _value > 0 && _value < koto.balanceOf(koto.ownership())) {
            vm.expectRevert(MockKotoV3.InvalidTransfer.selector);
            koto.transfer(_to, _value);
        } else if (_to != address(0) && _value > 0 && _value < koto.balanceOf(koto.ownership())) {
            koto.transfer(_to, _value);
            assertEq(koto.balanceOf(koto.ownership()), 8_500_000 ether - (_value * 2));
            if (_to == alice) {
                assertEq(koto.balanceOf(_to), _value * 2);
            } else {
                assertEq(koto.balanceOf(_to), _value);
            }
        }
    }

    function testTransferFrom() public {}

    function testApprove() public {}
}
