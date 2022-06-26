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

  address owner;
  bool stopBorrows;
  uint totalSupplied;
  uint totalBorrowed;
  uint totalRepaid;
  uint nbOfLoans;



  mapping(IERC721 => uint) public assetPrice;
  mapping(IERC721 => mapping(uint256 => address)) public depositor;
  mapping(uint => Loan) public loan;

  event Borrowed(address indexed borrower, uint loanId,  uint amount);
  event Repaid(uint indexed loanId, uint amount);
  event Bought(uint indexed loanId, uint price);
  event Withdrew(address indexed supplier, uint amount);

    struct Loan {
        IERC721 collection;
        uint tokenId;
        uint loanDate;
        uint amount;
        address borrowedBy;
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

    function borrow(uint256 borrowAmount) external {
    
    IERC721(collection).transferFrom(msg.sender, address(this), tokenId);
    uint amount = assetPrice[collection] - calculateInterests(assetPrice*0.20);
    loan[nbOfLoans] = Loan({
      collection: collection,
      tokenId: tokenId,
      loanDate: block.timestamp,
      amount: amount,
      borrowedBy: msg.sender
    });
    pUSDC.transfer(msg.sender, amount);
    totalBorrowed += amount;

    emit Borrowed(msg.sender, nbOfLoans, amount);
    nbOfLoans++;
    }

    function depositNFT(IERC721 nft, uint256 id) external {
        
        depositor[token][tokenId] = msg.sender;
    }

    function withdrawNFT(IERC721 nft, uint256 id) external {


        depositor[token][tokenId]

    }

    function repayBorrow(uint256 repayAmount) external {

    uint repaid = loan[loanId].amount + 
    pUSDC.transferFrom(msg.sender, address(this), repaid);
    IERC721(loan[loanId].collection).transferFrom(address(this), msg.sender, loan[loanId].tokenId);
    totalRepaid += repaid;

    emit Repaid(loanId, repaid);

    }

    function liquidateBorrow(IERC721 nft, uint256 id) external {}

    function appraise(IERC721 nft, uint256 appraisal) external {




    }

    function exchangeRateStored() public returns (int128){
        int128 half = ABDKMath64x64.divu(1, 2);
        return half;
    }
}
