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


    uint public total_assets; // total number of assets tokenized

    address public owner; // the owner of this smart contract

    mapping (string => Portfolio[]) private user_portfolio; // maps a user to a list of portfolio

    mapping(uint => Digital_Asset) private braqqet_assets; // A map of lands

    // ensure that only the owner can perform this operation where ever is_owner is used
    modifier is_owner(){
        require(msg.sender == owner, "Caller is not the owner of this contract");
        _;
    }

    event NewAssetCreatedEvent(string asset_ticker, uint asset_token_id);
    error NotEnoughFunds(string user_id, uint requested, uint available);

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
        
        emit NewAssetCreatedEvent(ticker, asset_id);
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

    
    function get_owner() external view returns (address){
        return owner;
    }

    function buy_asset(string calldata user_id, string calldata asset_ticker, uint size) external is_owner returns (bool is_successful){

        // check if user has already bought some assets
        Portfolio[] storage portfolio = user_portfolio[user_id];

        if (portfolio.length > 0){

            for (uint i = 0; i < portfolio.length; i++){
                // check if user wants to add to an existing asset
                if (keccak256(abi.encodePacked((portfolio[i].asset_ticker))) == keccak256(abi.encodePacked((asset_ticker)))) {
                    portfolio[i].size += size;
                    portfolio[i].created_timestamp = block.timestamp;
                    return true; 
                }
            }

        } else{
            Portfolio memory new_portfolio = Portfolio(asset_ticker, size, block.timestamp);
            portfolio.push(new_portfolio);
            return true;
        }

        return false;
    }

    function sell_asset(string calldata user_id, string calldata asset_ticker, uint size) external is_owner returns (bool is_successful){

        // check if user has already bought some assets
        Portfolio[] storage portfolio = user_portfolio[user_id];

        if (portfolio.length > 0){

            for (uint i = 0; i < portfolio.length; i++){
                // check if user wants to add to an existing asset
                if (keccak256(abi.encodePacked((portfolio[i].asset_ticker))) == keccak256(abi.encodePacked((asset_ticker)))) {

                    // you cannot sell more than you own
                    if (portfolio[i].size >= size){
                        portfolio[i].size -= size;
                        portfolio[i].created_timestamp = block.timestamp;
                        return true; 
                    } else{
                        revert NotEnoughFunds(user_id, size, portfolio[i].size);

                    }

                }
            }
            return false;
        }
        return false;
    }
}
