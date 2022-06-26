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

let contractAddresses = [
    '0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d',
    '0xf87e31492faf9a91b02ee0deaad50d51d56d5d4d',
    '0x5cc5b05a8a13e3fbdb0bb9fccd98d38e50f90c38',
    '0x1485297e942ce64E0870EcE60179dFda34b4C625'
]

function uploadAppraisal(contract_address) {
    const api_endpoint = `https://nameless-plateau-97799.herokuapp.com//getLTV?address=${contract_address}`;
    const results = axios.get(api_endpoint).then((res) => {
        return res.data;
      });
      let tx = await appraiserContractWithSigner.setAppraisal(nftAddress, results.volatility, results.current_price, results.rec_loan_amount);
      await tx.wait();
      appraiserContract.on("AppraisalSubmitted", (nftAddress, lastPrice, recommendedLoanAmount, lastUpdateTimestamp) => {
        console.log(`Appraisal for NFT address ${nftAddress} submitted`)
    })
}

contractAddresses.forEach(uploadAppraisal);

