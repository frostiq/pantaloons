// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "abdk-libraries-solidity/ABDKMath64x64.sol";
import "./INFTLendingPool.sol";
import "./IAppraiser.sol";

contract NFTLendingPool is INFTLendingPool, ERC20 {
    using ABDKMath64x64 for int128;

    IERC20 public underlyingToken;
    IAppraiser public appraiser;

    constructor() ERC20("Pantaloons USDC", "pUSDC") {}

    address owner;
    bool stopBorrows;
    uint256 totalSupplied;
    uint256 totalBorrowed;
    uint256 totalRepaid;
    uint256 nbOfLoans;

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
    mapping(address => NFT[]) public depositedCollateral;
    mapping(uint256 => Loan) public loan;

    event Borrowed(address indexed borrower, uint256 loanId, uint256 amount);
    event Repaid(uint256 indexed loanId, uint256 amount);
    event Bought(uint256 indexed loanId, uint256 price);
    event Withdrew(address indexed supplier, uint256 amount);
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

    function borrow(uint256 borrowAmount) external {
        uint256 principalTimesIndex = borrowSnapshot.principal * borrowIndex;
        uint256 TotalDebt = principalTimesIndex / borrowSnapshot.interestIndex;

        uint256 amount = borrowAmount;
        assetPrice * 0.20;
        loan[nbOfLoans] = Loan({
            collection: collection,
            tokenId: tokenId,
            amount: amount,
            borrowedBy: msg.sender
        });
        underlyingToken.transfer(msg.sender, amount);
        totalBorrowed += amount;

        emit Borrowed(msg.sender, nbOfLoans, amount);
        nbOfLoans++;
    }

    function depositNFT(IERC721 nft, uint256 id) external {
        depositor[token][id] = msg.sender;
        nft.transferFrom(msg.sender, address(this), id);
        emit Deposit(msg.sender, id);
    }

    function withdrawNFT(IERC721 nft, uint256 id) external {
        delete depositor[token][id] = msg.sender;
        nft.transferFrom(address(this), msg.sender, id);
        emit Withdraw(msg.sender, id);
    }

    function repayBorrow(uint256 repayAmount) external {
        uint256 repaid = loan[loanId].amount +
            pUSDC.transferFrom(msg.sender, address(this), repaid);
        IERC721(loan[loanId].collection).transferFrom(
            address(this),
            msg.sender,
            loan[loanId].tokenId
        );
        totalRepaid += repaid;

        emit Repaid(loanId, repaid);
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
            NFT nft = depositedCollateral[borrower][index];
            sum += appraiser.appraise(nft.token, nft.index);
        }

        return sum;
    }
}
