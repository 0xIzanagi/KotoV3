// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import {PricingLibrary} from "../../src/PricingLibrary.sol";

interface IMockKotoV3 {
    // ==================== EXTERNAL FUNCTIONS ===================== \\

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    ///@notice exchange ETH for Koto tokens at the current bonding price
    ///@dev bonds are set on 1 day intervals with 4 hour deposit intervals and 30 minute tune intervals.
    function bond() external payable returns (uint256 payout);

    function bondLp(uint256 _lpAmount) external returns (uint256 payout);

    ///@notice burn Koto tokens in exchange for a piece of the underlying reserves
    ///@param amount The amount of Koto tokens to redeem
    ///@return payout The amount of ETH received in exchange for the Koto tokens
    function redeem(uint256 amount) external returns (uint256 payout);

    ///@notice burn Koto tokens, without redemption
    ///@param amount the amount of Koto to burn
    function burn(uint256 amount) external returns (bool success);

    // ==================== EXTERNAL VIEW FUNCTIONS ===================== \\

    ///@notice get the tokens name
    function name() external pure returns (string memory);

    ///@notice get the tokens symbol
    function symbol() external pure returns (string memory);

    ///@notice get the tokens decimals
    function decimals() external pure returns (uint8);

    ///@notice get the tokens total supply
    function totalSupply() external view returns (uint256);

    ///@notice get the current balance of a user
    ///@param _owner the user whos balance you want to check
    function balanceOf(address _owner) external view returns (uint256);

    ///@notice get current approved amount for transfer from another party
    ///@param owner the current owner of the tokens
    ///@param spender the user who has approval (or not) to spend the owners tokens
    function allowance(address owner, address spender) external view returns (uint256);

    ///@notice return the Uniswap V2 Pair address
    function pool() external view returns (address);

    ///@notice get the owner of the contract
    ///@dev ownership is nontransferable and limited to opening trade, exclusion / inclusion,s and increasing liquidity
    function ownership() external pure returns (address);

    ///@notice the current price a bond
    function bondPrice() external view returns (uint256);

    function bondPriceLp() external view returns (uint256);

    ///@notice return the current redemption price for 1 uint of Koto.
    function redemptionPrice() external view returns (uint256);

    function marketInfo()
        external
        view
        returns (PricingLibrary.Market memory, PricingLibrary.Term memory, PricingLibrary.Data memory);

    function lpMarketInfo()
        external
        view
        returns (PricingLibrary.Market memory, PricingLibrary.Term memory, PricingLibrary.Data memory);

    function depository() external view returns (address);

    function create(uint256 ethBondAmount, uint256 lpBondAmount) external;

    // ========================= EVENTS ========================= \\

    event AmmAdded(address poolAdded);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Bond(address indexed buyer, uint256 amount, uint256 bondPrice);
    event CreateMarket(uint256 bonds, uint256 start, uint48 end);
    event IncreaseLiquidity(uint256 kotoAdded, uint256 ethAdded);
    event Launched(uint256 time);
    event LimitsRemoved(uint256 time);
    event OpenBondMarket(uint256 openingTime);
    event Redeem(address indexed sender, uint256 burned, uint256 payout, uint256 floorPrice);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event UserExcluded(address indexed userToExclude);

    // ========================= ERRORS ========================= \\

    error AlreadyLaunched();
    error BondFailed();
    error InsufficentAllowance();
    error InsufficentBalance();
    error InsufficentBondsAvailable();
    error InvalidSender();
    error InvalidTransfer();
    error LimitsReached();
    error MarketClosed();
    error MaxPayout();
    error OngoingBonds();
    error OnlyOwner();
    error RedeemFailed();
    error Reentrancy();
}
