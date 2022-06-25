// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import 'abdk-libraries-solidity/ABDKMath64x64.sol';
import "./INFTLendingPool.sol";

contract NFTLendingPool is INFTLendingPool, ERC20 {
    using ABDKMath64x64 for int128; 

    IERC20 public underlyingToken;

    constructor() ERC20("Pantaloons USDC", "pUSDC") {
    }

    function mint(uint256 amount) external {
        int128 exchangeRate = exchangeRateStored();

        underlyingToken.transferFrom(msg.sender, address(this), amount);
        uint256 mintTokens = exchangeRate.mulu(amount);

        _mint(msg.sender, mintTokens);
    }

    function redeem(uint256 redeemTokens) external {
        int128 exchangeRate = exchangeRateStored();

        _burn(msg.sender, redeemTokens);

        uint256 withdrawAmount = ABDKMath64x64.divu(1, 1).div(exchangeRate).mulu(redeemTokens);
        underlyingToken.transfer(msg.sender, withdrawAmount);
    }

    function borrow(uint256 borrowAmount) external {}

    function depositNFT(IERC721 nft, uint256 id) external {}

    function withdrawNFT(IERC721 nft, uint256 id) external {}

    function repayBorrow(uint256 repayAmount) external {}

    function liquidateBorrow(IERC721 nft, uint256 id) external {}

    function appraise(IERC721 nft, uint256 appraisal) external {}

    function exchangeRateStored() public returns (int128){
        int128 half = ABDKMath64x64.divu(1, 2);
        return half;
    }
}
