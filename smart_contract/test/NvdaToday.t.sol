// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NvdaToday} from "../src/NvdaToday.sol";

contract PublicNvdaToday is NvdaToday {
    function publicSettleBets(uint256 price) public {
        settleBets(price);
    }
}

contract NvdaTodayTest is Test {
    PublicNvdaToday nvdaToday;

    function setUp() public {
        nvdaToday = new PublicNvdaToday();
    }

    function testBetHigher() public {
        uint256 initCallerBalance = address(this).balance;
        uint256 initCalleeBalance = address(nvdaToday).balance;

        // First test case: bet 1 ether
        nvdaToday.betHigher{value: 1 ether}();
        assertEq(nvdaToday.totalStakeBetHigher(), 1 ether);
        assertEq(address(this).balance, initCallerBalance - 1 ether);
        assertEq(address(nvdaToday).balance, initCalleeBalance + 1 ether);

        // Second test case: bet another 2 ether
        nvdaToday.betHigher{value: 2 ether}();
        assertEq(nvdaToday.totalStakeBetHigher(), 3 ether);
        assertEq(address(this).balance, initCallerBalance - 3 ether);
        assertEq(address(nvdaToday).balance, initCalleeBalance + 3 ether);
    }

    function testBetLower() public {
        uint256 initCallerBalance = address(this).balance;
        uint256 initCalleeBalance = address(nvdaToday).balance;

        // First test case: bet 1 ether
        nvdaToday.betLower{value: 1 ether}();
        assertEq(nvdaToday.totalStakeBetLower(), 1 ether);
        assertEq(address(this).balance, initCallerBalance - 1 ether);
        assertEq(address(nvdaToday).balance, initCalleeBalance + 1 ether);

        // Second test case: bet another 2 ether
        nvdaToday.betLower{value: 2 ether}();
        assertEq(nvdaToday.totalStakeBetLower(), 3 ether);
        assertEq(address(this).balance, initCallerBalance - 3 ether);
        assertEq(address(nvdaToday).balance, initCalleeBalance + 3 ether);
    }

    function testSettleBets() public {
        uint256 initCallerBalance = address(this).balance;
        uint256 initCalleeBalance = address(nvdaToday).balance;

        // First test case: price is higher than last price, bet higher
        nvdaToday.betHigher{value: 1 ether}();
        nvdaToday.publicSettleBets(2);
        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), 0);
        assertEq(address(this).balance, initCallerBalance);
        assertEq(address(nvdaToday).balance, initCalleeBalance);

        // Second test case: price is higher than last price, bet lower
        nvdaToday.betLower{value: 1 ether}();
        nvdaToday.publicSettleBets(2);
        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), 1 ether);
        assertEq(address(this).balance, initCallerBalance - 1 ether);
        assertEq(address(nvdaToday).balance,initCalleeBalance + 1 ether);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
