//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IAppraiser.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Appraiser is Ownable, IAppraiser {

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

    event AppraisalSubmitted(address indexed nftAddress, uint256 volatility, uint256 lastPrice, uint256 recommendedLoanAmount, uint256 lastUpdateTimestamp);
    
    // sets owner to msg.sender by default
    constructor() {
    }

    function setAppraisal(address nftAddress, uint256 volatility, uint256 lastPrice, uint256 recommendedLoanAmount) public onlyOwner {
        uint256 timeNow = block.timestamp;
        appraisals[nftAddress] = NFTAppraisal(volatility, lastPrice, recommendedLoanAmount, timeNow);
        emit AppraisalSubmitted(nftAddress, volatility, lastPrice, recommendedLoanAmount, timeNow);
    }

    function getAppraisal(IERC721 nftAddress, uint256 id) external view returns (uint256, uint256) {
        uint256 lastPrice = appraisals[address(nftAddress)].lastPrice;
        uint256 recommendedLoanAmount = appraisals[address(nftAddress)].recommendedLoanAmount;
        return (lastPrice, recommendedLoanAmount);
    }

}
