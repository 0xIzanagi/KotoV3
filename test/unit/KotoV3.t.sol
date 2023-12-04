// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

// Retest the main contract to ensure that nothing that was changed in the mock did not
// slip through the cracks to the main contract.

import "forge-std/Test.sol";
import {KotoV3, IKotoV3} from "../../src/KotoV3.sol";

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
}

contract KotoV3Test is Test {
    KotoV3 public koto;

    function setUp() public {
        koto = new KotoV3();
        vm.deal(address(koto), 1000 ether);
        vm.startPrank(koto.ownership());
        koto.transfer(address(koto), 500_000 ether);
        koto.launch();
        koto.approve(address(koto), type(uint256).max);
        vm.stopPrank();
    }

    function testCreate() public {
        vm.startPrank(koto.ownership());
        koto.create(100_000 ether, 0);
        vm.expectRevert(IKotoV3.OngoingBonds.selector);
        koto.create(100_000 ether, 0);
        vm.expectRevert(IKotoV3.MarketClosed.selector);
        koto.bondLp(100 ether);
        vm.stopPrank();
    }

    function testBond() public {
        vm.startPrank(koto.ownership());
        vm.expectRevert(IKotoV3.MarketClosed.selector);
        assertEq(address(koto).balance, 0);
        koto.bond{value: 1 ether}();
        koto.create(100_000 ether, 0);
        uint256 pre = koto.balanceOf(koto.ownership());
        koto.bond{value: 1 ether}();
        assertEq(address(koto).balance, 1 ether);
        assertGt(koto.balanceOf(koto.ownership()), pre);
        vm.stopPrank();
    }

    function testBondLp() public {
        vm.startPrank(koto.depository());
        IERC20(koto.pool()).transfer(koto.ownership(), 100 ether);
        vm.stopPrank();
        vm.startPrank(koto.ownership());
        IERC20(koto.pool()).approve(address(koto), type(uint256).max);
        vm.expectRevert(IKotoV3.MarketClosed.selector);
        koto.bondLp(100 ether);
        assertEq(IERC20(koto.pool()).balanceOf(koto.ownership()), 100 ether);
        koto.create(0, 100_000 ether);
        uint256 pre = koto.balanceOf(koto.ownership());
        uint256 lp = IERC20(koto.pool()).balanceOf(koto.depository());
        koto.bondLp(100 ether);
        assertGt(koto.balanceOf(koto.ownership()), pre);
        assertGt(IERC20(koto.pool()).balanceOf(koto.depository()), lp);
    }
}
