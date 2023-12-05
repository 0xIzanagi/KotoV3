// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "forge-std/Script.sol";
import {KotoV3} from "../src/KotoV3.sol";
import {IUniswapV2Router02} from "../src/interfaces/IUniswapV2Router02.sol";

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

interface IBondDepository {
    function emergencyWithdraw(address) external;
}

contract AddLiquidityScript is Script {
    KotoV3 public koto = KotoV3(payable(0x64C7d8C8Abf28Daf9D441c507CfE9Be678A0929c));
    IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public depositoryV3 = 0xE58B33c813ac4077bd2519dE90FccB189a19FA71;
    IBondDepository public depository = IBondDepository(0x298ECA8683000B3911B2e7Dd07FD496D8019043E);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        depository.emergencyWithdraw(0x946eF43867225695E29241813A8F41519634B36b);
        uint256 kotoAmount = 472659367911423477086449;
        uint256 ethValue = 25478742607576637101;
        koto.approve(address(router), type(uint256).max);
        router.addLiquidityETH{value: ethValue}(
            address(koto), kotoAmount, kotoAmount, ethValue, depositoryV3, block.timestamp + 100
        );
        vm.stopBroadcast();
    }
}
