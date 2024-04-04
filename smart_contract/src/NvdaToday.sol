// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract NvdaToday {
    uint256 public lastPrice;
    uint256 public totalStakeBetHigher;
    uint256 public totalStakeBetLower;
    address[] private playersBetHigher;
    address[] private playersBetLower;
    mapping(address => uint256) private stakesBetHigher;
    mapping(address => uint256) private stakesBetLower;

    function betHigher() public payable {
        require(msg.value > 0, "You must bet more than 0");
        uint256 stack = stakesBetHigher[msg.sender];
        if (stack == 0) {
            playersBetHigher.push(msg.sender);
        }
        stack = stack + msg.value;
        totalStakeBetHigher += msg.value;
        stakesBetHigher[msg.sender] = stack;
    }

    function betLower() public payable {
        require(msg.value > 0, "You must bet more than 0");
        uint256 stack = stakesBetLower[msg.sender];
        if (stack == 0) {
            playersBetLower.push(msg.sender);
        }
        stack = stack + msg.value;
        totalStakeBetLower += msg.value;
        stakesBetLower[msg.sender] = stack;
    }

    function settleBets(uint256 price) internal {
        uint256 totalWinning = totalStakeBetHigher + totalStakeBetLower;
        require(
            address(this).balance >= totalWinning,
            "Contract does not have enough balance to cover winnings"
        );

        if (price > lastPrice && playersBetHigher.length > 0) {
            for (uint256 i = 0; i < playersBetHigher.length; i++) {
                payable(playersBetHigher[i]).transfer(
                    totalWinning * 1000 / totalStakeBetHigher * stakesBetHigher[playersBetHigher[i]] / 1000
                );
            }
            totalStakeBetHigher = 0;
            totalStakeBetLower = 0;
        } else if (price < lastPrice && playersBetLower.length > 0) {
            for (uint256 i = 0; i < playersBetLower.length; i++) {
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
        for (uint256 i = 0; i < playersBetHigher.length; i++) {
            delete stakesBetHigher[playersBetHigher[i]];
        }
        for (uint256 i = 0; i < playersBetLower.length; i++) {
            delete stakesBetLower[playersBetLower[i]];
        }

        lastPrice = price;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
