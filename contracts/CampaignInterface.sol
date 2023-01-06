// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface CampaignInterface {
    /*
     * This function is used to add funds from a user to the campaign.
     *
     * Input:
     * - _from: The address of the user that want to contribute.
     * - _amount: The amount of tokens the user contributes.
     */
    function addFunds(address _from, uint256 _amount) external;

    // The caller demands a refund of his donation;
    /*
     * This function is used to refund the full amount to a user
     *
     * Input:
     * - _to: The address of the user that want a refunds.
     */
    function refund(address _to) external;
}
