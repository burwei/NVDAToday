// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";
import {console} from "forge-std/Test.sol";

contract NvdaToday {
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
        require(msg.value > 0, "You must bet more than 0");
        uint stack = stakesBetHigher[msg.sender];
        if (stack == 0) {
            playersBetHigher.push(msg.sender);
        }
        stack = stack + msg.value;
        totalStakeBetHigher += msg.value;
        stakesBetHigher[msg.sender] = stack;
    }

    function betLower() public payable {
        require(msg.value > 0, "You must bet more than 0");
        uint stack = stakesBetLower[msg.sender];
        if (stack == 0) {
            playersBetLower.push(msg.sender);
        }
        stack = stack + msg.value;
        totalStakeBetLower += msg.value;
        stakesBetLower[msg.sender] = stack;
    }

    function settleBets(uint price) internal {
        uint totalWinning = totalStakeBetHigher + totalStakeBetLower;
        require(
            address(this).balance >= totalWinning,
            "Contract does not have enough balance to cover winnings"
        );

        if (price > lastPrice && playersBetHigher.length > 0) {
            for (uint i = 0; i < playersBetHigher.length; i++) {
                payable(playersBetHigher[i]).transfer(
                    totalWinning * 1000 / totalStakeBetHigher * stakesBetHigher[playersBetHigher[i]] / 1000
                );
            }
            totalStakeBetHigher = 0;
            totalStakeBetLower = 0;
        } else if (price < lastPrice && playersBetLower.length > 0) {
            for (uint i = 0; i < playersBetLower.length; i++) {
                payable(playersBetLower[i]).transfer(
                    totalWinning * 1000 / totalStakeBetLower * stakesBetLower[playersBetLower[i]] / 1000
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

    // TODO: implement this function
    function getNvdaPrice() public view returns(uint) {
        return lastPrice;
    }

    function processBets() public {
        uint currentHour = BokkyPooBahsDateTimeLibrary.getHour(block.timestamp);
        require(currentHour >= 20 && currentHour <= 23, "You can only call this function between 20:00 and 23:00 UTC");

        uint price = getNvdaPrice();
        settleBets(price);
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}
