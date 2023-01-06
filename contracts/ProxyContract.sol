// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./CampaignInterface.sol";

contract ProxyContract {
    // Address of the contract's owner
    address public owner;

    // Address of campaign
    CampaignInterface campaign;

    constructor(address _campaign) {
        owner = msg.sender;
        campaign = CampaignInterface(_campaign);
    }

    function changeCampaign(address _newCampaign) public {
        require(owner == msg.sender, "Only owner is allowed to change that");
        campaign = CampaignInterface(_newCampaign);
    }

    function addFunds(uint256 _amount) public {
        campaign.addFunds(msg.sender, _amount);
    }

    function refund() public {
        campaign.refund(msg.sender);
    }

    function getCampaignAddress() public view returns (address) {
        return address(campaign);
    }
}
