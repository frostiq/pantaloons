import { ethers, utils } from 'ethers'
import axios from 'axios'
import 'dotenv/config'

// Import ABIs
import Appraiser from './build/contracts/Appraiser.json' assert {type: "json"};

const APPRAISER_CONTRACT_ADDRESS = Appraiser.networks[3].address;

let httpProvider = new ethers.providers.JsonRpcProvider(`https://ropsten.infura.io/v3/${process.env.INFURA_KEY}`);
let appraiserContract = new ethers.Contract(APPRAISER_CONTRACT_ADDRESS, Appraiser.abi, httpProvider);

// Get signer from a private key
let privateKey = process.env.MNEMONIC;
let wallet = new ethers.Wallet(privateKey, httpProvider);

// Connect the wallet w the appraiser
let appraiserContractWithSigner = appraiserContract.connect(wallet);

let contractAddresses = [
    // '0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d',
    '0xf87e31492faf9a91b02ee0deaad50d51d56d5d4d',
    '0x5cc5b05a8a13e3fbdb0bb9fccd98d38e50f90c38',
    // '0x1485297e942ce64e0870ece60179dfda34b4c625'
]

async function uploadAppraisal(nftAddress) {
    const api_endpoint = `https://nameless-plateau-97799.herokuapp.com//getLTV?address=${nftAddress}`;
    const results = await axios.get(api_endpoint).then((res) => {
        return res.data;
      });
      
      const price = utils.parseEther(results.current_price.toString())
      const volatility = utils.parseEther(results.volatility.toString())
      const loanAmount = utils.parseEther(results.rec_loan_amount.toString())

      let tx = await appraiserContractWithSigner.setAppraisal(nftAddress, volatility, price, loanAmount);
      await tx.wait();
      appraiserContract.on("AppraisalSubmitted", (nftAddress, lastPrice, recommendedLoanAmount, lastUpdateTimestamp) => {
        console.log(`Appraisal for NFT address ${nftAddress} submitted`)
    })
}

for (const address of contractAddresses) {
    await uploadAppraisal(address)
}

