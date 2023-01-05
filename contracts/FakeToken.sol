// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract FakeToken is ERC20, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("Fake", "FK") {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(uint256 _numberOfTokens) public onlyRole(MINTER_ROLE) {
        _mint(msg.sender, _numberOfTokens);
    }

    function mintAndSendToTokenSale(uint256 _numberOfTokens, address _tokenSale)
        public
        onlyRole(MINTER_ROLE)
    {
        _mint(msg.sender, _numberOfTokens);
        transfer(_tokenSale, _numberOfTokens);
    }
}
