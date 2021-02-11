// SPDX-License-Identifier: MIT

pragma solidity ^0.7.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Vesting is Ownable {
    using SafeMath for uint256;
    
    address public CGB;

    mapping(address => uint256) public lastUpdateTime;
    mapping(address => uint256) public available;
    mapping(address => uint256) public total;
    mapping(address => uint256) public speed;

    event Added(address indexed user, uint256 amount, uint256 totalDays);
    event Withdrawn(address indexed user, uint256 amount);

    modifier updateReward(address account) {
        if (account != address(0)) {
            available[account] = earned(account);
            lastUpdateTime[account] = block.timestamp;
        }
        _;
    }

    constructor(address token) public {
        CGB = token;
    }

    function addVester(
        address vesterAddress,
        uint256 amount,
        uint256 totalDays
    ) public onlyOwner {
        IERC20(CGB).transferFrom(msg.sender, address(this), amount);

        total[vesterAddress] = amount;
        speed[vesterAddress] = amount.div(totalDays).div(86400);
        emit Added(vesterAddress, amount, totalDays);
    }

    function earned(address account) public view returns (uint256) {
        uint256 blockTime = block.timestamp;
        uint256 result =
            available[account].add(
                blockTime.sub(lastUpdateTime[account]).mul(speed[account])
            );
        return (total[account] < result) ? total[account] : result;
    }

    function withdraw(address receiver, uint256 amount)
        public
        updateReward(receiver)
    {
        require(amount > 0, "Cannot withdraw 0");
        require(available[receiver] > 0, "Nothing to withdraw");
        require(
            amount <= available[receiver],
            "Cannot withdraw more than available"
        );

        available[receiver] = available[receiver].sub(amount);
        total[receiver] = total[receiver].sub(amount);
        IERC20(CGB).transfer(receiver, amount);
        emit Withdrawn(receiver, amount);
    }
}
