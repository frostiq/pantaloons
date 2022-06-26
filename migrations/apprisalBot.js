const hre = require("hardhat");
import { ethers } from 'ethers'
import axios from 'axios'

// Import ABIs
import Appraiser from '../artifacts/contracts/Appraiser.sol/Appraiser.json'

const APPRAISER_CONTRACT_ADDRESS = '';

let httpProvider = new ethers.providers.JsonRpcProvider();
let appraiserContract = new ethers.Contract(APPRAISER_CONTRACT_ADDRESS, Appraiser, httpProvider);

// Get signer from a private key
let privateKey = '';
let wallet = new ethers.Wallet(privateKey, httpProvider);

// Connect the wallet w the appraiser
let appraiserContractWithSigner = appraiserContract.connect(wallet);

// Listen to the event, and then call our API
appraiserContract.on("AppraisalRequested", (nftAddress, defaultProbability, loanTime, requesterAddress) => {
    const api_endpoint = `https://nameless-plateau-97799.herokuapp.com//getLTV?address=${nftAddress}`;
    // fields: collection_address, current_price, volatility, loan_time, rec_ltv, rec_loan_amount, liquidation_prob
    const results = axios.get(api_endpoint).then((res) => {
        return res.data;
      });

    // Send this information to the smart contract
    let tx = await appraiserContractWithSigner.setAppraisal(nftAddress, results.volatility, results.current_price, results.rec_loan_amount);
    await tx.wait();

    appraiserContract.on("AppraisalSubmitted", (nftAddress, lastPrice, recommendedLoanAmount, lastUpdateTimestamp) => {
        console.log(`Appraisal for NFT address ${nftAddress} submitted`)
    })

})




