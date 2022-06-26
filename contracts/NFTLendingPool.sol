// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "abdk-libraries-solidity/ABDKMath64x64.sol";
import "./INFTLendingPool.sol";

contract NFTLendingPool is INFTLendingPool, ERC20 {
    using ABDKMath64x64 for int128;

    IERC20 public underlyingToken;

    constructor() ERC20("Pantaloons USDC", "pUSDC") {}

    address owner;
    bool stopBorrows;
    uint256 totalSupplied;
    uint256 totalBorrowed;
    uint256 totalRepaid;
    uint256 nbOfLoans;
    uint256 borrowIndex = 1e18; 


    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    // Mapping of account addresses to outstanding borrow balances
    mapping(address => BorrowSnapshot) internal accountBorrows;

    mapping(IERC721 => uint256) public assetPrice;
    mapping(IERC721 => mapping(uint256 => address)) public depositor;
    mapping(uint256 => Loan) public loan;

    event Borrowed(address indexed borrower, uint256 amount);
    event Repaid(uint256 indexed loanId, uint256 amount);
    event Bought(uint256 indexed loanId, uint256 price);
    event Withdraw(address indexed supplier, uint256 amount);
    event Deposit(address indexed borrower, uint256 id);

    struct Loan {
        IERC721 collection;
        uint256 tokenId;
        uint256 amount;
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

        uint256 withdrawAmount = ABDKMath64x64
            .divu(1, 1)
            .div(exchangeRate)
            .mulu(redeemTokens);
        underlyingToken.transfer(msg.sender, withdrawAmount);
    }



    function borrowBalanceStoredInternal(address account) internal view returns (uint) {
        /* Get borrowBalance and borrowIndex */
        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];

        /* If borrowBalance = 0 then borrowIndex is likely also 0.
         * Rather than failing the calculation with a division by 0, we immediately return 0 in this case.
         */
        if (borrowSnapshot.principal == 0) {
            return 0;
        }

        /* Calculate new borrow balance using the interest index:
         *  recentBorrowBalance = borrower.borrowBalance * market.borrowIndex / borrower.borrowIndex
         */
        uint principalTimesIndex = borrowSnapshot.principal * borrowIndex;
        return principalTimesIndex / borrowSnapshot.interestIndex;
    }

    function borrow(uint256 borrowAmount) external {

        uint256 amount = borrowAmount;
       // assetPrice * 0.20;
        underlyingToken.transfer(msg.sender, amount);
        totalBorrowed += amount;

        emit Borrowed(msg.sender, amount);
    }

    function depositNFT(IERC721 nft, uint256 id) external {
        depositor[nft][id] = msg.sender;
        nft.transferFrom(msg.sender, address(this), id);
        emit Deposit(msg.sender, id);
    }

    function withdrawNFT(IERC721 nft, uint256 id) external {
      require (depositor[nft][id] == msg.sender);
        delete depositor[nft][id];
        nft.transferFrom(address(this), msg.sender, id);
        emit Withdraw(msg.sender, id);
    }
 
    function repayBorrow(uint256 repayAmount) external {
      /*
        uint256 repaid = loan[loanId].amount + underlyingToken.transferFrom(msg.sender, address(this), repaid);
        totalRepaid += repaid;
        emit Repaid(loanId, repaid);

*/
    }

    function liquidateBorrow(IERC721 nft, uint256 id) external {}

    function appraise(IERC721 nft, uint256 appraisal) external {}

    function exchangeRateStored() public returns (int128) {
        int128 half = ABDKMath64x64.divu(1, 2);
        return half;
    }
}
