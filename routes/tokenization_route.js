const Web3 =  require("web3");
const fs = require("fs")
const express = require('express');
const { body, validationResult } = require('express-validator');
const contract_info = JSON.parse(fs.readFileSync('./build/contracts/FractionalAsset.json', 'utf8'));
//const infura_provider = "http://127.0.0.1:8545";
const infura_provider = process.env.INFURA_ID




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


router.get('/tokenize', 
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

        // get the Ethereum node
        var web3 = new Web3(new Web3.providers.HttpProvider(infura_provider));

        // get network id and contract address
        const network_id = await web3.eth.net.getId();
        const deployed_id = contract_info.networks[network_id];

        // create contract instance
        const contract = await new web3.eth.Contract(contract_info.abi, deployed_id.address);

        var eth_accounts = await web3.eth.getAccounts();

        // // call the tokenization function
        // let asset_id = await contract.methods.tokenize(asset_ticker, asset_total_amount, price_per_token, total_supply).send({
        //     from: eth_accounts[0],
        //     gasLimit: 1000000
        //     });

        res.send({success: true, data: {asset_ticker: asset_ticker}});
});

router.get('/total_assets', async (req, res) => {

    // get the Ethereum node
    var web3 = new Web3(new Web3.providers.HttpProvider(infura_provider));

    // get network id and contract address
    const network_id = await web3.eth.net.getId();
    const deployed_id = contract_info.networks[network_id];

    // create contract instance
    const contract = await new web3.eth.Contract(contract_info.abi, deployed_id.address);

    var eth_accounts = await web3.eth.getAccounts();

    let total_assets = await contract.methods.get_total_assets().call(
        {
            from: eth_accounts[0],
            gasLimit: 100000000
        }
    );

    res.send({success: true, data: {assets: total_assets}});
});


router.get('/', (req, res) =>{

    res.send({success: true, data: {page: "homepage"}});

});


module.exports = router;

