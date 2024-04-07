// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";
import "chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {console} from "forge-std/Test.sol";

contract NvdaToday {
    struct LastPrice {
        uint price;
        uint timestamp;
    }

    uint constant minBet = 1000000000000000; // 1 finney
    uint constant contractFee = 10000000000000; // 0.01 finney (1% fee or less)
    uint constant PRECISION_FACTOR = 1000;

    LastPrice public lastPrice;
    uint public totalStakeBetHigher;
    uint public totalStakeBetLower;
    address[] private playersBetHigher;
    address[] private playersBetLower;
    mapping(address => uint) private stakesBetHigher;
    mapping(address => uint) private stakesBetLower;
    AggregatorV3Interface private priceFeed;

    // Make the contract payable
    receive() external payable {}
    fallback() external payable {}

    // constructor initializes the price feed contract.
    // It's only for public mainnet or testnet.
    constructor() {
        // For NVDA/USD on BNB Mainnet (L1 mainnet).
        priceFeed = AggregatorV3Interface(
            0xea5c2Cbb5cD57daC24E26180b19a929F3E9699B8
        );

        // For NVDA/USD on Arbitrum Mainnet (L2 mainnet).
        priceFeed = AggregatorV3Interface(
            0x4881A4418b5F2460B21d6F08CD5aA0678a7f262F
        );

        // For SPY/USD on Arbitrum Sepolia (L2 testnet).
        // There's no NVDA/USD on any testnet, so we use SPY/USD instead.
        priceFeed = AggregatorV3Interface(
            0x4fB44FC4FA132d1a846Bd4143CcdC5a9f1870b06
        );

        uint price = getLastNvdaPrice();
        lastPrice = LastPrice(price, block.timestamp);
    }

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
    function settleBets(uint price) internal {
        uint totalWinning = totalStakeBetHigher + totalStakeBetLower;
        require(
            address(this).balance >= totalWinning,
            "Contract does not have enough balance to cover winnings"
        );

        if (price > lastPrice.price && playersBetHigher.length > 0) {
            for (uint i = 0; i < playersBetHigher.length; i++) {
                payable(playersBetHigher[i]).transfer(
                    (((totalWinning * PRECISION_FACTOR) / totalStakeBetHigher) *
                        stakesBetHigher[playersBetHigher[i]]) / PRECISION_FACTOR
                );
            }
            totalStakeBetHigher = 0;
            totalStakeBetLower = 0;
        } else if (price < lastPrice.price && playersBetLower.length > 0) {
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

        lastPrice.price = price;
    }

    // ownerSettleBets lets the owner of the contract settle the bets manually for testing purposes. 
    function ownerSettleBets(uint price) public {
        if (msg.sender != address(this)) {
            revert("Only the contract owner can call this function");
        }

        settleBets(price);
    }

    // getNvdaPrice returns the last closing price of NVDA stock.
    // It's only for public mainnet or testnet.
    function getLastNvdaPrice() internal view returns (uint) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        return uint(answer);
    }

    // processBets settles the bets based on the last closing price of NVDA stock.
    // It's only for public mainnet or testnet.
    function processBets() public {
        uint currentHour = BokkyPooBahsDateTimeLibrary.getHour(block.timestamp);
        require(
            currentHour >= 21 && currentHour <= 23,
            "You can only call this function between 21:00 and 23:59 UTC"
        );

        uint lastPriceUpdateDay = BokkyPooBahsDateTimeLibrary.getDay(
            lastPrice.timestamp
        );

        uint currentDay = BokkyPooBahsDateTimeLibrary.getDay(block.timestamp);

        if (lastPriceUpdateDay == currentDay) {
            revert("Price has been updated today already");
        }

        uint price = getLastNvdaPrice();
        if (price == lastPrice.price) {
            lastPrice.timestamp = block.timestamp;
            return;
        }

        settleBets(price);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
