// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import {IERC20Minimal} from "../../src/interfaces/IERC20Minimal.sol";

contract MockVoter {
    address public immutable koto;

    constructor(address _koto) {
        koto = _koto;
    }

    function notifyRewardAmount(uint256 amount) external {
        IERC20Minimal(koto).transferFrom(msg.sender, address(this), amount);
    }
}
