// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "abdk-libraries-solidity/ABDKMath64x64.sol";
import "./INFTLendingPool.sol";
import "./IAppraiser.sol";

// TODO:
// - borrowIndex updates
// - liquidation
// - calculateCollateralValue finish
// - Superfluid
// - Lender interest rate

contract NFTLendingPool is INFTLendingPool, ERC20 {
    using ABDKMath64x64 for int128;

    IERC20 public underlyingToken;

    constructor() ERC20("Pantaloons USDC", "pUSDC") {}

    uint256 public totalSupplied;
    uint256 public totalBorrowed;
    uint256 public totalRepaid;
    uint256 public borrowIndex = 1e18;

    IAppraiser public appraiser;

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    struct NFT {
        IERC721 token;
        uint256 id;
    }

    // Mapping of account addresses to outstanding borrow balances
    mapping(address => BorrowSnapshot) internal accountBorrows;

    mapping(IERC721 => uint256) public assetPrice;
    mapping(IERC721 => mapping(uint256 => address)) public depositor;
    mapping(address => NFT[]) depositedCollateral; 
    mapping(uint256 => Loan) public loan;

    event Borrowed(address indexed borrower, uint256 amount);
    event Repaid(address indexed borrower, uint256 amount);
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

    function borrowBalanceStoredInternal(address account)
        internal
        view
        returns (uint256)
    {
        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];

        if (borrowSnapshot.principal == 0) {
            return 0;
        }

        uint256 principalTimesIndex = borrowSnapshot.principal * borrowIndex;
        return principalTimesIndex / borrowSnapshot.interestIndex;
    }

    function depositNFT(IERC721 nft, uint256 id) external {
        depositor[nft][id] = msg.sender;
        nft.transferFrom(msg.sender, address(this), id);
        emit Deposit(msg.sender, id);
    }

    function withdrawNFT(IERC721 nft, uint256 id) external {
        // TODO: LTV check
        require(depositor[nft][id] == msg.sender);
        delete depositor[nft][id];
        nft.transferFrom(address(this), msg.sender, id);
        emit Withdraw(msg.sender, id);
    }

    function borrow(uint256 borrowAmount) external {
        // TODO: LTV check

        uint accountBorrowsPrev = borrowBalanceStoredInternal(msg.sender);
        uint accountBorrowsNew = accountBorrowsPrev + borrowAmount;
        uint totalBorrowsNew = totalBorrowed + borrowAmount;

        accountBorrows[msg.sender].principal = accountBorrowsNew;
        accountBorrows[msg.sender].interestIndex = borrowIndex;
        totalBorrowed = totalBorrowsNew;


        uint256 amount = borrowAmount;
        underlyingToken.transfer(msg.sender, amount);

        emit Borrowed(msg.sender, amount);
    }

    function repayBorrow(uint256 repayAmount) external {
        underlyingToken.transferFrom(msg.sender, address(this), repayAmount);
        totalRepaid += repayAmount;

        uint accountBorrowsPrev = borrowBalanceStoredInternal(msg.sender);
        uint accountBorrowsNew = accountBorrowsPrev - repayAmount;
        uint totalBorrowsNew = totalBorrowed - repayAmount;

        /* We write the previously calculated values into storage */
        accountBorrows[msg.sender].principal = accountBorrowsNew;
        accountBorrows[msg.sender].interestIndex = borrowIndex;
        totalBorrowed = totalBorrowsNew;

        emit Repaid(msg.sender, repayAmount);
    }

    function liquidateBorrow(IERC721 nft, uint256 id) external {}

    function exchangeRateStored() public returns (int128) {
        int128 half = ABDKMath64x64.divu(1, 2);
        return half;
    }

    function calculateCollateralValue(address borrower)
        public
        returns (uint256)
    {
        uint256 length = depositedCollateral[borrower].length;
        uint256 sum = 0;
        for (uint256 index = 0; index < length; index++) {
            NFT storage nft = depositedCollateral[borrower][index];
            sum += appraiser.getAppraisal(nft.token, nft.id);
        }

        return sum;
    }
}
