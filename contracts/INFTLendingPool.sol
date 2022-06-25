// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFTLendingPool {
    function mint(uint256 mintAmount) external;

    function redeem(uint256 redeemTokens) external;

    function borrow(uint256 borrowAmount) external;

    function depositNFT(IERC721 nft, uint256 id) external;

    function withdrawNFT(IERC721 nft, uint256 id) external;

    function repayBorrow(uint256 repayAmount) external;

    function liquidateBorrow(IERC721 nft, uint256 id) external;

    function appraise(IERC721 nft, uint256 appraisal) external;
}
