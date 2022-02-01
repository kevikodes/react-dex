// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import './CCToken.sol';

contract Exchange {
    //Name and Token are state variables, data is stored on blockchain
    string public name = "CC Exchange";
    uint rate = 100;
    event CCTokensPurchase (
        address account,
        address token,
        uint amount,
        uint rate
    );
    event CCTokensSold (
        address account,
        address token,
        uint amount,
        uint rate
    );

    //Creates variable that represents token smart contract.
    //Allows us to call functions on this token like transfer
    //This is just the code, Exchange still doesn't know where to find it.
    //We need to tell it where to find it.
    CCToken public ccToken;

    //Tell Exchange where to find the token contract in the constructor
    constructor(CCToken _ccToken) {
        ccToken = _ccToken;
    }

    function getName() external view returns (string memory){
        console.log("Contract name: ",  name);
        return name;
    }

    function buyTokens() public payable {
        uint256 tokenAmount = msg.value * rate;

        //Make sure the exhange has anough tokens to transfer to user
        require(
            ccToken.balanceOf(address(this)) >= tokenAmount,
            "Not enough tokens in exchange"
        );
        ccToken.transfer(msg.sender, tokenAmount);

        //Emit the event
        emit CCTokensPurchase(msg.sender, address(ccToken), tokenAmount, rate);
    }

    function sellTokens(uint _amount) public payable {
        //Calculate the amount of ether to redeem
        uint256 etherAmount = _amount / rate;
        //Check that the exchange has enough ether 
        require(
           address(this).balance >= etherAmount,
            "Not enough ether to sell tokens"
        );
        //Here we are calling transfer for ether
        //This is different that the transfer function called on the token contract above
        payable(msg.sender).transfer(etherAmount);
        ccToken.transferFrom(msg.sender, address(this), _amount);
        emit CCTokensSold(msg.sender, address(ccToken), _amount, rate);
    }
}