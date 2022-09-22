pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address buyer,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        // Validating the user sent eth
        uint256 amountOfETH = msg.value;
        require(amountOfETH > 0, "Send some ETH");

        // Validate the vendor has enough tokens
        uint256 VendorBalance = yourToken.balanceOf(address(this));
        uint256 amountOfTokens = amountOfETH * tokensPerEth;
        require(
            VendorBalance > amountOfTokens,
            "You do not have enough balance!"
        );

        // send the tokens
        bool sent = yourToken.transfer(msg.sender, amountOfTokens);
        require(sent, "Failed to transfer token!");

        // emit event
        emit BuyTokens(msg.sender, amountOfETH, amountOfTokens);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH

    // Allow the owner to withdaraw ETH
    function withdraw() public payable {
        uint256 VendorBalance = yourToken.balanceOf(address(this));
        require(VendorBalance > 0, "Need ETH to transfer");

        address owner = msg.sender;
        (bool sent, ) = owner.call{value: VendorBalance}("");
        require(sent, "Failed to send ETH");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 amount) public {
        // Validate token amount
        require(amount > 0, "Insufficient funds");

        // Validate user has enough Tokens
        address user = msg.sender;
        uint256 userBalance = yourToken.balanceOf(user);
        require(userBalance >= amount, "User does not have enough tokens");

        // Validate that Vendor has enough ETH
        uint256 amountOfETH = amount / tokensPerEth;
        uint256 VendorBalance = address(this).balance;
        require(
            VendorBalance >= amountOfETH,
            "Vendor does not have enough ETH"
        );

        // Sending of tokens from the user to the vendor
        bool sent = yourToken.transferFrom(user, address(this), amount);
        require(sent, "tokens not transferred");

        // Sending of eth from vendor to the user
        (bool send, ) = user.call{value: amountOfETH}("");
        require(send, "ETH not transferred");

        // emit Sell event
        emit SellTokens(user, amountOfETH, amount);
    }
}
