const Web3 =  require("web3");
const fs = require("fs")
const express = require('express');
const contract_info = JSON.parse(fs.readFileSync('./build/contracts/FractionalAsset.json', 'utf8'));
const infura_provider = "http://127.0.0.1:8545";

const router = express.Router();

const connect_to_blockchain = async() => {

    // get the Ethereum node
    const web3 = new Web3(infura_provider);

    // get network id and contract address
    const network_id = await web3.eth.net.getId();
    const deployed_id = contract_info.networks[network_id];
    
    // create contract instance
    const contract = new web3.eth.Contract(contract_info.abi, deployed_id.address);
    var eth_accounts = await web3.eth.getAccounts();

    let total_assets = await contract.methods.get_total_assets().call();

      let asset_id = await contract.methods.tokenize("BTC", 25000, 12, 5000).call({
        from: eth_accounts[0],
        gasLimit: 1000000
        });
        console.log(asset_id);

        let an_asset = await contract.methods.get_asset_details(asset_id).call();
        console.log(an_asset);
        console.log(total_assets);
}


router.post('/tokenize', async (req, res) => {
    var data = req.json; // req.body.total_supply

    // get the Ethereum node
    const web3 = new Web3(infura_provider);

    // get network id and contract address
    const network_id = await web3.eth.net.getId();
    const deployed_id = contract_info.networks[network_id];
    
    // create contract instance
    const contract = new web3.eth.Contract(contract_info.abi, deployed_id.address);
    var eth_accounts = await web3.eth.getAccounts();

    // call the tokenization function
    let asset_id = await contract.methods.tokenize("BTC", 25000, 12, 5000).call({
        from: eth_accounts[0],
        gasLimit: 1000000
        });

    res.send({success: true, data: {asset_id: asset_id}});
});

router.get('/total_assets', async (req, res) => {
    console.log("here");
    // get the Ethereum node
    const web3 = new Web3(infura_provider);

    // get network id and contract address
    const network_id = await web3.eth.net.getId();
    const deployed_id = contract_info.networks[network_id];
    
    // create contract instance
    const contract = new web3.eth.Contract(contract_info.abi, deployed_id.address);
    var eth_accounts = await web3.eth.getAccounts();
    let total_assets = await contract.methods.get_total_assets().call(
        {
            from: eth_accounts[0],
            gasLimit: 100000000
        }
    );

    res.send({success: true, data: {assets: total_assets}});
});


module.exports = router;

