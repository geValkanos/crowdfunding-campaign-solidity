// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Campaign {
    // The campaing's owner
    address public owner;

    // The total amount for the campaign.
    uint256 public goal;

    // The amount that has been gathered so far.
    uint256 public gatheredAmount;

    // Keep the amount each address has contributed.
    mapping(address => uint256) private amounts;

    // The Token we collect as part of the campaign.
    IERC20 theToken;

    // Events for everytime someone adds/removes funds.
    event FundsSent(address indexed user, uint256 amount, bool isRefund);

    // Event for when the campaign is completed.
    event Closed(uint256 goalAmount, uint256 totalGathered);

    constructor(uint256 _goal, address _tokenAddress) {
        goal = _goal;
        owner = msg.sender;
        theToken = IERC20(_tokenAddress);
    }

    function addFunds(uint256 _amount) public {
        // Validate the request.
        require(goal > gatheredAmount, "The goal has already been achieved");
        require(theToken.balanceOf(msg.sender) >= _amount, "Not enough theToken to contribute");

        // Transfer the tokens to the crowdfunding account.
        theToken.transferFrom(msg.sender, address(this), _amount);
        gatheredAmount += _amount;
        amounts[msg.sender] += _amount;
        
        // Trigger event for this funding.
        emit FundsSent(msg.sender, _amount, false);

        // Close the campaign if the funds are gathered.
        if (gatheredAmount >= goal) {
            emit Closed(goal, gatheredAmount);
        }
    }

    function refund() public {
        // Validate the request
        require(goal > gatheredAmount, "The goal is completed, no refunds allowed");
        require(amounts[msg.sender] != 0, "The user hasn't contribute any funds");

        // Transfer the tokens back to user.
        uint256 amount = amounts[msg.sender];
        amounts[msg.sender] = 0;
        gatheredAmount -= amount;
        theToken.transfer(msg.sender, amount);

        // Trigger event for the refund.
        emit FundsSent(msg.sender, amount, true);
    }

}