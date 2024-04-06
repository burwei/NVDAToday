// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";
import {console} from "forge-std/Test.sol";

contract NvdaToday {
    uint constant minBet = 1000000000000000; // 1 finney
    uint constant contractFee = 10000000000000; // 0.01 finney (1% fee or less)
    uint constant PRECISION_FACTOR = 1000;

    uint public lastPrice;
    uint public totalStakeBetHigher;
    uint public totalStakeBetLower;
    address[] private playersBetHigher;
    address[] private playersBetLower;
    mapping(address => uint) private stakesBetHigher;
    mapping(address => uint) private stakesBetLower;

    // Make the contract payable
    receive() external payable {}
    fallback() external payable {}

    function betHigher() public payable {
        require(msg.value >= minBet, "You must bet more than 1 finney");
        uint stack = stakesBetHigher[msg.sender];
        if (stack == 0) {
            playersBetHigher.push(msg.sender);
        }
        stack = stack + msg.value;
        totalStakeBetHigher += msg.value;
        stakesBetHigher[msg.sender] = stack;
    }

    function betLower() public payable {
        require(msg.value >= minBet, "You must bet more than 1 finney");
        uint stack = stakesBetLower[msg.sender];
        if (stack == 0) {
            playersBetLower.push(msg.sender);
        }
        stack = stack + msg.value;
        totalStakeBetLower += msg.value;
        stakesBetLower[msg.sender] = stack;
    }

    // settleBets calculates the winning amount for each player and transfers the winnings to their address.  
    // It's an internal function for public mainnet or testnet.  
    // And it must be public for local testnet.  
    function settleBets(uint price) internal {
        uint totalWinning = totalStakeBetHigher + totalStakeBetLower;
        require(
            address(this).balance >= totalWinning,
            "Contract does not have enough balance to cover winnings"
        );

        if (price > lastPrice && playersBetHigher.length > 0) {
            for (uint i = 0; i < playersBetHigher.length; i++) {
                payable(playersBetHigher[i]).transfer(
                    (((totalWinning * PRECISION_FACTOR) / totalStakeBetHigher) *
                        stakesBetHigher[playersBetHigher[i]]) / PRECISION_FACTOR
                );
            }
            totalStakeBetHigher = 0;
            totalStakeBetLower = 0;
        } else if (price < lastPrice && playersBetLower.length > 0) {
            for (uint i = 0; i < playersBetLower.length; i++) {
                payable(playersBetLower[i]).transfer(
                    (((totalWinning * PRECISION_FACTOR) / totalStakeBetLower) *
                        stakesBetLower[playersBetLower[i]]) / PRECISION_FACTOR
                );
            }
            totalStakeBetHigher = 0;
            totalStakeBetLower = 0;
        } else {
            // No winner, stakes stay in the pool.
        }

        delete playersBetHigher;
        delete playersBetLower;
        for (uint i = 0; i < playersBetHigher.length; i++) {
            delete stakesBetHigher[playersBetHigher[i]];
        }
        for (uint i = 0; i < playersBetLower.length; i++) {
            delete stakesBetLower[playersBetLower[i]];
        }

        lastPrice = price;
    }

    // getNvdaPrice returns the last closing price of NVDA stock.
    // It's only for public mainnet or testnet.
    function getNvdaPrice() internal view returns (uint) {
        // TODO: implement this function
        return lastPrice;
    }

    // processBets settles the bets based on the last closing price of NVDA stock.
    // It's only for public mainnet or testnet.
    function processBets() public {
        uint currentHour = BokkyPooBahsDateTimeLibrary.getHour(block.timestamp);
        require(
            currentHour >= 21 && currentHour <= 22,
            "You can only call this function between 21:00 and 22:00 UTC"
        );

        uint price = getNvdaPrice();
        settleBets(price);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
