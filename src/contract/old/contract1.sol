// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract Date {
    uint256 public lastUpdated;    

    function update() public {
        lastUpdated = block.timestamp;
    }
}