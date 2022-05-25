const Web3 =  require("web3");
const fs = require("fs")
const express = require('express');
require("dotenv").config();
const { body, validationResult } = require('express-validator');
const contract_info = JSON.parse(fs.readFileSync('./build/contracts/FractionalAsset.json', 'utf8'));
//const infura_provider = "http://127.0.0.1:8545";
const infura_provider = process.env.INFURA_ID;
const contract_address = process.env.CONTRACT_ADDRESS;
const network = process.env.ETHEREUM_NETWORK;





const router = express.Router();

const connect_to_blockchain = async() => {

    var web3 = new Web3(new Web3.providers.HttpProvider(infura_provider));

    // get network id and contract address
    const network_id = await web3.eth.net.getId();
    const deployed_id = contract_info.networks[network_id];

    //console.log(network_id);
    console.log(deployed_id);

    // create contract instance
    const contract = await new web3.eth.Contract(contract_info.abi, deployed_id.address);
    return [web3, contract];
}

async function handleTransferEvent(event) {
    try{
      //const fromAddress = event.returnValues.asset_ticker
      const tokenId = event.returnValues.asset_id
      console.log("SOMEONE TRANSFERED NFT!", tokenId);
    }
    catch(err) {
      console.log(err)
      console.log("ERROR WHILE HANDLING TRANSFER EVENT")
    }
  }

router.post('/tokenize', 
    body('total_supply').not().isEmpty(),
    body('asset_ticker').not().isEmpty(),
    body('price_per_token').not().isEmpty(),
    body('total_amount').not().isEmpty(),
    async (req, res) => {

        // Finds the validation errors in this request and wraps them in an object with handy functions
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
        }

        var total_supply = req.body.total_supply;
        var asset_ticker = req.body.asset_ticker;
        var price_per_token = req.body.price_per_token;
        var asset_total_amount = req.body.total_amount;

        var asset_token_id = '';
        var blockchain_asset_ticker = '';
        var transaction_hash = '';
        var block_hash = '';

        // get the Ethereum node
        var web3 = new Web3(new Web3.providers.HttpProvider(`https://${network}.infura.io/v3/${process.env.INFURA_PROJECT_ID}`));

        // Creating a signing account from a private key
        const signer = await web3.eth.accounts.privateKeyToAccount(process.env.SIGNER_PRIVATE_KEY);
        web3.eth.accounts.wallet.add(signer);

        // create contract instance
        const contract = await new web3.eth.Contract(contract_info.abi, contract_address, {
            from: signer.address
        });

        // call the tokenization function
        const tx = contract.methods.tokenize(asset_ticker, asset_total_amount, price_per_token, total_supply);
        const response = await tx
            .send({
            from: signer.address,
            gasLimit: await tx.estimateGas(),
            })
            .on("receipt", (receipt) => {

                var event_returned_values = receipt.events.NewAssetCreatedEvent.returnValues;
                asset_token_id = event_returned_values.asset_token_id;
                blockchain_asset_ticker = event_returned_values.asset_ticker;
                transaction_hash = receipt.events.NewAssetCreatedEvent.transactionHash;
                block_hash = receipt.events.NewAssetCreatedEvent.blockHash;
                console.log(receipt);
              });
            // The transaction is now on chain!
        console.log(`Mined in block ${response.blockNumber}`);
        res.send({success: true, data: {asset_ticker: blockchain_asset_ticker, asset_id: asset_token_id, 
            transaction_hash: transaction_hash,
        block_hash: block_hash}});
});

router.get('/total_assets', async (req, res) => {

    // get the Ethereum node
    var web3 = new Web3(new Web3.providers.HttpProvider(`https://${network}.infura.io/v3/${process.env.INFURA_PROJECT_ID}`));

    // Creating a signing account from a private key
    const signer = await web3.eth.accounts.privateKeyToAccount(process.env.SIGNER_PRIVATE_KEY);
    web3.eth.accounts.wallet.add(signer);

    // create contract instance
    const contract = await new web3.eth.Contract(contract_info.abi, contract_address, {
        from: signer.address
    });

    let total_assets = await contract.methods.get_total_assets().call(
        {
            from: signer.address,
            gasLimit: 25000
        }
    );
    res.send({success: true, data: {assets: total_assets}});
});


router.get('/', async (req, res) =>{

    res.send({success: true, data: {page: "homepage"}});

});


module.exports = router;

