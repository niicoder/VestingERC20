// SPDX-License-Identifier: MIT

pragma solidity ^0.7.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ChainGuardians is ERC20 {
    constructor (
        string memory name,
        string memory symbol,
        uint256 initialBalance
    )
        ERC20(name, symbol)
    {
        require(initialBalance > 0, "ChainGuardians: supply cannot be zero");

        _mint(_msgSender(), initialBalance);
    }
}