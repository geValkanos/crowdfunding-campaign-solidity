// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function transfer(address to, uint256 amount) external;

    function decimals() external view returns (uint256);
}


contract TokenSale {
    uint256 public tokenPriceInWei = 1 ether;
    address public owner;

    IERC20 token;

    event AmountReturnedToUser(uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier _preValidatePurchase() {
        require(msg.value >= tokenPriceInWei, "Not enough money sent");
        require(msg.value != 0, "You can't buy 0 tokens");
        _;
    }

    function purchase() public payable _preValidatePurchase {
        uint256 tokensToTransfer = msg.value / tokenPriceInWei;
        uint256 remainder = msg.value - tokensToTransfer * tokenPriceInWei;
        token.transfer(msg.sender, tokensToTransfer);
        payable(msg.sender).transfer(remainder);
        emit AmountReturnedToUser(remainder);
    }
}
