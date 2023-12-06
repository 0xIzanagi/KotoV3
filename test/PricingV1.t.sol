//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import {KotoV3} from "../src/KotoV3.sol";
import {BondDepositoryV3} from "../src/BondDepositoryV3.sol";
import {PricingV1} from "../src/PricingV1.sol";
import {IUniswapV2Router02} from "../src/interfaces/IUniswapV2Router02.sol";
import "forge-std/Test.sol";

interface IERC20 {
    function approve(address,uint256) external returns(bool);
}

contract PricingV1Test is Test {
    KotoV3 public koto = KotoV3(payable(0x64C7d8C8Abf28Daf9D441c507CfE9Be678A0929c));
    BondDepositoryV3 public depo = BondDepositoryV3(payable(0xE58B33c813ac4077bd2519dE90FccB189a19FA71));
    PricingV1 public pricing;
    IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function setUp() public {
        pricing = new PricingV1();
    }

    function testCreate() public {
        vm.startPrank(depo.OWNER());
        depo.reward(100_000 ether, address(pricing));
        assertEq(koto.balanceOf(address(pricing)), 100_000 ether);
        pricing.create(0, 100_000 ether);
        (uint48 interval, uint48 last, uint48 conclusion, uint96 theta, uint96 price, uint96 capacity) =
            pricing.lpModel();
        assertEq(capacity, 100_000 ether);
        assertEq(conclusion, block.timestamp + 604800);
        vm.stopPrank();
    }

    function testBond() public {
        // uint256 pre = address(koto).balance;
        // testCreate();
        // (uint48 interval, uint48 last, uint48 conclusion, uint96 theta, uint96 price, uint96 capacity) =
        //     pricing.ethModel();
        // pricing.bond{value: 0.5 ether}();
        // (,,,, uint96 updated,) = pricing.ethModel();
        // assertGt(updated, price);
        // vm.warp(block.timestamp + 100_000);
        // uint256 newPrice = pricing.ethPrice();
        // pricing.bond{value: 0.5 ether}();
        // (uint48 _interval, uint48 _last, uint48 _conclusion, uint96 _theta, uint96 _price, uint96 _capacity) =
        //     pricing.ethModel();
        // vm.warp(block.timestamp + 120_000);
        // uint256 third = pricing.ethPrice();
        // assertGt(_price, third);
        // assertEq(_interval, interval);
        // assertEq(_conclusion, _conclusion);
        // assertGt(_theta, theta);
        // assertGt(capacity, _capacity);
        // assertGt(updated, newPrice);
        // assertEq(address(koto).balance, pre + 1 ether);
    }

    function testBondLp() public {
        // testCreate();
        // vm.startPrank(koto.ownership());
        // router.addLiquidityETH{value: 1 ether}(address(koto), 4000 ether, 0, 0, koto.ownership(), block.timestamp + 10);
        // IERC20(pricing.PAIR()).approve(address(pricing), type(uint256).max);
        // (uint48 interval, uint48 last, uint48 conclusion, uint96 theta, uint96 price, uint96 capacity) =
        //     pricing.lpModel();
        // pricing.bondLp(10 ether);
        // (,,,, uint96 updated,) = pricing.lpModel();
        // assertGt(updated, price);
        // vm.warp(block.timestamp + 100_000);
        // uint256 newPrice = pricing.lpPrice();
        // pricing.bondLp(10 ether);
        // (uint48 _interval, uint48 _last, uint48 _conclusion, uint96 _theta, uint96 _price, uint96 _capacity) =
        //     pricing.lpModel();
        // vm.warp(block.timestamp + 120_000);
        // uint256 third = pricing.lpPrice();
        // assertGt(_price, third);
        // assertEq(_interval, interval);
        // assertEq(_conclusion, _conclusion);
        // assertGt(_theta, theta);
        // assertGt(capacity, _capacity);
        // assertGt(updated, newPrice);
    }

    
}
