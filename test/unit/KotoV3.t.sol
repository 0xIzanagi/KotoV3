// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import {MockKotoV3} from "../helpers/MockKotoV3.sol";
import {BondDepositoryV3} from "../../src/BondDepositoryV3.sol";
import {FullMath} from "../../src/libraries/FullMath.sol";

contract KotoV3Test is Test {
    MockKotoV3 public koto;
    BondDepositoryV3 public depository;
    address public alice = address(0x01);

    function setUp() public {
        depository = new BondDepositoryV3();
        koto = new MockKotoV3(address(depository));
    }

    function testConstructor() public {}

    function testTransfer(uint256 _value, address _to) public {
        vm.assume(_to != koto.ownership());
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
        vm.stopPrank();
    }

    function testTransferFrom(address to, uint256 amount) public {
        address owner = koto.ownership();
        vm.assume(to != owner);
        if (to == address(0) || amount == 0) {
            vm.expectRevert(MockKotoV3.InvalidTransfer.selector);
            koto.transferFrom(owner, to, amount);
        } else {
            vm.expectRevert(MockKotoV3.InsufficentAllowance.selector);
            koto.transferFrom(owner, to, amount);
        }
        vm.prank(owner);
        koto.approve(address(this), amount);
        if (to == address(0) || amount == 0) {
            vm.expectRevert(MockKotoV3.InvalidTransfer.selector);
            koto.transferFrom(owner, to, amount);
        } else if (amount > 8_500_000 ether) {
            vm.expectRevert(MockKotoV3.InsufficentBalance.selector);
            koto.transferFrom(owner, to, amount);
        } else {
            koto.transferFrom(owner, to, amount);
            assertEq(koto.balanceOf(to), amount);
            assertEq(koto.balanceOf(owner), 8_500_000 ether - amount);
        }
    }

    function testApprove(uint256 amount, address to) public {
        koto.approve(to, amount);
        assertEq(koto.allowance(address(this), to), amount);
    }

    function testRedeem(uint256 amount) public {
        address owner = koto.ownership();
        vm.assume(amount > 0.001 ether);
        vm.startPrank(owner);
        if (amount > 8_500_000 ether) {
            vm.expectRevert(MockKotoV3.InsufficentBalance.selector);
            koto.redeem(amount);
        } else {
            koto.redeem(amount);
            assertEq(koto.balanceOf(owner), 8_500_000 ether - amount);
        }
        vm.deal(address(koto), 8_500_000 ether);
        if (amount <= koto.balanceOf(owner)) {
            uint256 expected = FullMath.mulDiv(8_500_000 ether, amount, koto.totalSupply());
            uint256 pre = address(owner).balance;
            koto.redeem(amount);
            assertEq(koto.balanceOf(owner), 8_500_000 ether - amount * 2);
            assertEq(koto.totalSupply(), 8_500_000 ether - amount * 2);
            assertApproxEqAbs(address(owner).balance, pre + expected, 100_000_000);
            assertApproxEqAbs(address(koto).balance, 8_500_000 ether - expected, 100_000_000);
            // Precision within 0.0000000001 ether. From the test it shows that the precision error
            // is in the benefit of the cotract itself. Meaning that users get approximately  > 0.0000000001 less ether than they might be expecting on large scale redemptions.
            // At the current time of writing this is equal to about .000000208 dollars.
        }
        vm.stopPrank();
    }
}
