// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAppraiser.sol";

contract Appraiser is IAppraiser {
    function getAppraisal(IERC721 nft, uint256 id) external view returns (uint256){
        return 1000000000;
    }
}