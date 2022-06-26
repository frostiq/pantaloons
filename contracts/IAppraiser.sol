// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAppraiser {
    function getAppraisal(IERC721 nft, uint256 id) external view returns (uint256, uint256);
}