//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import "lib/solmate/src/tokens/ERC20.sol";

contract MockUSDC is ERC20 {

    address immutable public owner;

    constructor() ERC20("Mock USDC", "mUSDC", 6) {
        owner = msg.sender;
    }

    mapping(address => bool) public whitelisted;


    function mint(uint256 value) external {
        _mint(msg.sender, value);
    }

    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }

    modifier onlyWhitelist() {
        if (!whitelisted[msg.sender]) revert OnlyWhitelist();
        _;
    }

    function whitelist(address user) external {
        if (msg.sender != owner) revert OnlyOwner();
        whitelisted[user] = true;
    }


    error OnlyOwner();
    error OnlyWhitelist();
}