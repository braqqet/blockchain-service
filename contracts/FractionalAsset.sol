// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract FractionalAsset {
    
 // a structure to represent an asset
    struct Digital_Asset {
        string ticker;
        uint amount;
        uint price_per_token;
        uint total_supply;
        uint in_circulation;
        uint created_timestamp;
        uint updated_timestamp;
        address created_by;
    }

    // a structure to represent a user's portfolio
    struct Portfolio {
        string asset_ticker;
        uint size;
        uint created_timestamp;
    }

    //Digital_Asset[] public braqqet_assets; // an array to keep track of all assets ever tokenized

    uint public total_assets; // total number of assets tokenized

    address public owner; // the owner of this smart contract

    mapping (string => Portfolio[]) private user_portfolio; // maps a user to a list of portfolio

    mapping(uint => Digital_Asset) private braqqet_assets; // A map of lands

    // ensure that only the owner can perform this operation where ever is_owner is used
    modifier is_owner(){
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor(){
        owner = msg.sender;
        total_assets = 0;
    }

    // a function to tokenize assets on the blockchain
    function tokenize(string memory ticker, uint amount,  uint token_price, uint total_supply) is_owner external returns (uint){
        
        uint asset_id = uint(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
        Digital_Asset memory asset = Digital_Asset(ticker, amount, token_price, total_supply, 0, block.timestamp, block.timestamp, msg.sender);
        braqqet_assets[asset_id] = asset;
        total_assets+=1;
        return asset_id;
    }

    //get's information about a land
    function get_asset_details(uint asset_id) public view returns (string memory, uint, uint, uint, uint){
         Digital_Asset memory temp_asset = braqqet_assets[asset_id];
        if (temp_asset.total_supply != 0){

            return (temp_asset.ticker, temp_asset.amount, temp_asset.total_supply, temp_asset.in_circulation, temp_asset.created_timestamp);
        } else{
            return ('',0,0,0,0);
        }
        
    }

    function get_total_assets() external view returns (uint){
        return total_assets;
    }
}
