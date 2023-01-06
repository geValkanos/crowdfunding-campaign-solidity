// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./CampaignInterface.sol";

contract Campaign is CampaignInterface {
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
    event Completed(uint256 goalAmount, uint256 totalGathered);

    constructor(uint256 _goal, address _tokenAddress) {
        goal = _goal;
        owner = msg.sender;
        theToken = IERC20(_tokenAddress);
    }

    modifier goalIsNotCompleted() {
        require(goal > gatheredAmount, "The goal has already been achieved");
        _;
    }

    function addFunds(address _from, uint256 _amount) external goalIsNotCompleted {
        // Validate the request
        require(
            theToken.balanceOf(_from) >= _amount,
            "Not enough theToken to contribute"
        );

        // Transfer the tokens to the crowdfunding account.
        theToken.transferFrom(_from, address(this), _amount);
        gatheredAmount += _amount;
        amounts[_from] += _amount;

        // Trigger event for this funding.
        emit FundsSent(_from, _amount, false);

        // Close the campaign if the funds are gathered.
        if (gatheredAmount >= goal) {
            emit Completed(goal, gatheredAmount);
        }
    }

    function refund(address _to) external goalIsNotCompleted {
        // Validate the request
        require(amounts[_to] != 0, "The user hasn't contribute any funds");

        // Transfer the tokens back to user.
        uint256 amount = amounts[_to];
        amounts[_to] = 0;
        gatheredAmount -= amount;
        theToken.transfer(_to, amount);

        // Trigger event for the refund.
        emit FundsSent(_to, amount, true);
    }
}
