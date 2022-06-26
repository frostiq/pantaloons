//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Appraiser is Ownable {

    uint256 apprisalCount = 0;
    uint256 appraisalFee = 0.025 ether;
    uint256 totalFeesCollected = 0;

    struct NFTAppraisal {
        uint256 volatility;
        uint256 lastPrice;
        uint256 recommendedLoanAmount;
        uint256 lastUpdateTimestamp;
    }

    // Mapping of NFT collection addresses to their NFT appraisal
    mapping (address => NFTAppraisal) public appraisals;

    event AppraisalRequested(address indexed nftAddress, uint16 defaultProbability, uint256 loanTime, address requesterAddress);
    event AppraisalSubmitted(address indexed nftAddress, uint256 volatility, uint256 lastPrice, uint256 recommendedLoanAmount, uint256 lastUpdateTimestamp);
    
    // sets owner to msg.sender by default
    constructor() {
        console.log("Welcome to Appraisal contract");
    }

    // Request for an appraisal by emitting an event
    function requestAppraisal(address nftAddress, uint16 defaultProbability, uint256 loanTime) public payable {
        require(msg.value == appraisalFee, "Please pay the appraisal fee");
        totalFeesCollected += msg.value;
        emit AppraisalRequested(nftAddress, defaultProbability, loanTime, msg.sender);
    }

    // Only owner contract can set the appraisal, updating the NFTAppraisal information
    function setAppraisal(address nftAddress, uint256 volatility, uint256 lastPrice, uint256 recommendedLoanAmount) public onlyOwner {
        uint256 timeNow = block.timestamp;
        appraisals[nftAddress] = NFTAppraisal(volatility, lastPrice, recommendedLoanAmount, timeNow);
        emit AppraisalSubmitted(nftAddress, volatility, lastPrice, recommendedLoanAmount, timeNow);
    }

}