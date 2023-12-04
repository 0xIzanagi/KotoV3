// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Test.sol";
import {MockKotoV3} from "../helpers/MockKotoV3.sol";
import {BondDepositoryV3} from "../../src/BondDepositoryV3.sol";
import {FullMath} from "../../src/libraries/FullMath.sol";
import {IUniswapV2Router02} from "../../src/interfaces/IUniswapV2Router02.sol";

interface IERC20 {
    function approve(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

contract KotoV3Test is Test {
    MockKotoV3 public koto;
    BondDepositoryV3 public depository;
    address public alice = address(0x01);
    IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function setUp() public {
        depository = new BondDepositoryV3();
        koto = new MockKotoV3(address(depository));
    }

    // Constructor Test

    function testConstructor() public {}

    // State Changing Function Tests

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

    function testBurn(uint256 amount) public {
        address owner = koto.ownership();
        vm.startPrank(owner);
        if (amount > 8_500_000 ether) {
            vm.expectRevert(MockKotoV3.InsufficentBalance.selector);
            koto.burn(amount);
        } else {
            koto.burn(amount);
            assertEq(koto.totalSupply(), 8_500_000 ether - amount);
            assertEq(koto.balanceOf(owner), 8_500_000 ether - amount);
        }
        vm.stopPrank();
    }

    function testBond() public {
        vm.deal(address(koto), 1000 ether);
        vm.startPrank(koto.ownership());
        koto.transfer(address(koto), 500_000 ether);
        koto.launch();
        koto.approve(address(koto), type(uint256).max);

        koto.create(100_000 ether, 0);
        vm.stopPrank();

        vm.deal(alice, 100 ether);
        vm.prank(alice);
        uint256 payout = koto.bond{value: 1 ether}();

        assertEq(koto.balanceOf(address(alice)), payout);
        assertEq(koto.balanceOf(address(koto)), 100_000 ether - payout);

        uint256 currentBondPrice = koto.bondPrice();

        vm.warp(block.timestamp + 40_000);
        ///@dev send a 0 value bond to activate the adjustments and tuning
        koto.bond();
        uint256 post = koto.bondPrice();
        assertGt(currentBondPrice, post);
        vm.warp(block.timestamp + 80_000);
        ///@dev now that adjustments have been activiated we do not need to send an additional bond
        assertGt(post, koto.bondPrice());
        vm.warp(block.timestamp + 100_000);
        vm.expectRevert(MockKotoV3.MarketClosed.selector);
        koto.bond{value: 100 ether}();
    }

    function testLpBond() public {
        vm.startPrank(koto.ownership());
        koto.approve(address(router), type(uint256).max);
        koto.approve(address(koto), type(uint256).max);
        (,, uint256 lpTokens) =
            router.addLiquidityETH{value: 1 ether}(address(koto), 1000 ether, 0, 0, koto.ownership(), type(uint256).max);
        IERC20(koto.pool()).approve(address(koto), type(uint256).max);
        koto.create(0, 100_000 ether);
        koto.bondLp(lpTokens);
        assertEq(IERC20(koto.pool()).balanceOf(address(depository)), lpTokens);
        assertEq(IERC20(koto.pool()).balanceOf(koto.ownership()), 0);
        uint256 pre = koto.bondPriceLp();
        vm.warp(block.timestamp + 20_000);
        koto.bondLp(0);
        uint256 post = koto.bondPriceLp();
        assertGt(pre, post);
        vm.warp(block.timestamp + 30_000);
        assertGt(post, koto.bondPriceLp());
        vm.warp(block.timestamp + 100_000);
        vm.expectRevert(MockKotoV3.MarketClosed.selector);
        koto.bondLp(100 ether);
        vm.warp(block.timestamp + 150_000);
        koto.create(0, 10_000 ether);
        assertEq(koto.balanceOf(address(koto)), 10_000 ether);
    }

    // External View / Constant Tests (Primarily for coverage report)

    function testName() public {
        assertEq(koto.name(), "Koto");
    }

    function testSymbol() public {
        assertEq(koto.symbol(), "KOTO");
    }

    function testDecimals() public {
        assertEq(koto.decimals(), 18);
    }

    function testTotalSupply() public {
        assertEq(koto.totalSupply(), 8_500_000 ether);
    }

    function testBalanceOf(address user) public {
        if (user != koto.ownership()) {
            assertEq(koto.balanceOf(user), 0);
        } else {
            assertEq(koto.balanceOf(user), 8_500_000 ether);
        }
    }

    function testPool() public {
        assertNotEq(koto.pool(), address(0));
    }

    function testAllowance(uint256 amount) public {
        address owner = koto.ownership();
        assertEq(koto.allowance(koto.ownership(), address(this)), 0);
        vm.prank(koto.ownership());
        koto.approve(address(this), amount);
        if (amount > 8_500_000 ether) {
            vm.expectRevert(MockKotoV3.InsufficentBalance.selector);
            koto.transferFrom(owner, address(this), amount);
            assertEq(koto.allowance(owner, address(this)), amount);
        } else if (amount > 0) {
            koto.transferFrom(owner, address(this), amount);
            assertEq(koto.balanceOf(owner), 8_500_000 ether - amount);
            assertEq(koto.balanceOf(address(this)), amount);
            assertEq(koto.allowance(owner, address(this)), 0);
        }
    }

    function testOwnership() public {
        assertEq(koto.ownership(), 0x946eF43867225695E29241813A8F41519634B36b);
    }

    function testDepository() public {
        assertEq(koto.depository(), address(depository));
    }

    // Admin Functionality Tests

    function testAddAmm(address sender, address amm) public {
        vm.startPrank(sender);
        if (sender != koto.ownership() && amm != koto.pool()) {
            vm.expectRevert(MockKotoV3.OnlyOwner.selector);
            koto.addAmm(amm);
            assertEq(koto._amms(amm), false);
        } else {
            koto.addAmm(amm);
            assertEq(koto._amms(amm), true);
        }
        vm.stopPrank();
    }

    function testExclude(address sender, address user) public {
        address owner = koto.ownership();
        vm.startPrank(sender);
        if (sender != koto.ownership()) {
            vm.expectRevert(MockKotoV3.OnlyOwner.selector);
            koto.exclude(user);
            if (user != owner && user != address(depository) && user != address(koto)) {
                assertEq(koto._excluded(user), false);
            }
        } else {
            koto.exclude(user);
            assertEq(koto._excluded(user), true);
        }
        vm.stopPrank();
    }

    function testLaunch(address sender) public {
        address owner = koto.ownership();
        vm.deal(address(koto), 1000 ether);
        vm.prank(owner);
        koto.transfer(address(koto), 1_000_000 ether);
        if (sender != owner) {
            vm.expectRevert(MockKotoV3.OnlyOwner.selector);
            koto.launch();
        } else {
            assertEq(koto.balanceOf(address(koto)), 1_000_000 ether);
            koto.launch();
            assertEq(koto.balanceOf(address(koto)), 0);

            vm.expectRevert(MockKotoV3.AlreadyLaunched.selector);
            koto.launch();
        }
    }

    function testCreate() public {
        vm.startPrank(koto.ownership());
        vm.deal(address(koto), 1000 ether);
        koto.transfer(address(koto), 500_000 ether);
        koto.launch();

        koto.transfer(address(koto), 1000 ether);
        koto.approve(address(koto), type(uint256).max);

        assertEq(koto.balanceOf(address(koto)), 1000 ether);

        koto.create(100 ether, 0);
        assertEq(koto.balanceOf(address(koto)), 100 ether);

        vm.expectRevert(MockKotoV3.OngoingBonds.selector);
        koto.create(100 ether, 0);

        vm.warp(block.timestamp + 90_000);
        koto.create(100_000 ether, 0);
        assertEq(koto.balanceOf(address(koto)), 100_000 ether);
        vm.stopPrank();
    }

    // Private Function Tests (Have been made public inside the Mock not the Main contract)
}
