pragma solidity 0.5.1;

///@author Isaac Coffie
///@title A contract to register and manage assets stored on the blockchain

contract Asset {
    
    //Structure for a land
    struct Land {
        string size;
        address owner;
        uint token_id;
        uint price;
        string gps;
        string details;
        uint date_created; 
    }
    
    //structure for a building
    struct Building {
        string size;
        address owner;
        uint token_id;
        uint price;
        string gps;
        string details;
        uint num_rooms;
        uint date_created; 
    }
     
    // A map of lands
    mapping(uint => Land) private landMaps;
    
    // A map of Buildings
    mapping(uint => Building) private buildingMaps;
    
    mapping(address => Building) private userbuildingMaps;
    
    uint private numLands;
    uint private numBuildings;

    
    
    //constructor
    constructor() public{
        numLands = 0;
        numBuildings = 0;
    }
    
    //modifier to restrict access to functions 
    modifier onlyOwner(address my_address){
        require(my_address == msg.sender, "Only owner can call this function");
        _;
    }
    
    //creates new land
    function createNewLand(address user_addres,  string memory size, uint price, string memory gps, string memory details) public returns (uint) {
        
        uint id = uint(keccak256(abi.encodePacked(msg.sender, now)));
        Land memory thisLand = Land(size, user_addres, id, price, gps, details, now);
        landMaps[id] = thisLand;
        numLands+=1;
        return id;
    }
    
    //creates new building
    function createNewBuilding(address user_addres, uint num_rooms, string memory size, uint price, string memory gps, string memory details) public returns (uint) {
        
        uint id = uint(keccak256(abi.encodePacked(msg.sender, now)));
        Building memory thisBuilding = Building(size, user_addres, id, price, gps, details,num_rooms, now);
        buildingMaps[id] = thisBuilding;
        numBuildings+=1;
        return id;
    }
    
    //get's information about a land
    function getLandDetails(uint land_id) public view returns (uint, address, uint, string memory, string memory, string memory, uint){
         Land memory tempLand = landMaps[land_id];
        if (tempLand.token_id != 0){
            return (tempLand.token_id, tempLand.owner, tempLand.price,
            tempLand.size, tempLand.gps, tempLand.details,
             tempLand.date_created);
        }
        
    }
    
    //get's information about a building
    function getBuildingDetails(uint building_id) public view returns (uint, address, uint, string memory, string memory, string memory, uint, uint){
        Building memory tempBuilding = buildingMaps[building_id];
        
        if (tempBuilding.token_id != 0){
            return (tempBuilding.token_id, tempBuilding.owner, tempBuilding.price,
            tempBuilding.size, tempBuilding.gps, tempBuilding.details,
            tempBuilding.num_rooms, tempBuilding.date_created);
        }
        
    }
    
    //change price of a land
    function changeLandPrice(uint land_id, uint new_price, address user_addres) public onlyOwner(user_addres) returns(bool){
        
        Land memory tempLand = landMaps[land_id];
        if (tempLand.token_id != 0){
            landMaps[land_id].price = new_price;
            return true;
        }else{
            return false;
        }
    }
    
    //change price of a building
    function changeBuildingPrice(uint building_id, uint new_price, address user_addres) public onlyOwner(user_addres) returns(bool){
        
        Building memory tempBuilding = buildingMaps[building_id];
        if (tempBuilding.token_id != 0){
            buildingMaps[building_id].price = new_price;
            return true;
        }else{
            return false;
        }
    }
    
    //change owner of an asset
    function changeOwner(uint _token_id, address from_user_addres, address to_user_addres, uint asset_type) public  returns(bool){
        //asset_type 1 == building
        if (asset_type == 1){
            Building memory tempBuilding = buildingMaps[_token_id];
            if ((tempBuilding.token_id != 0) && (tempBuilding.owner == from_user_addres)){
                buildingMaps[_token_id].owner = to_user_addres;
                return true;
            }else{
                return false;
            }
        }
        
        //asset_type 2 == land
        if (asset_type == 2){
            Land memory tempLand = landMaps[_token_id];
            if ((tempLand.token_id != 0) && (tempLand.owner == from_user_addres)){
                landMaps[_token_id].owner = to_user_addres;
                return true;
            }else{
                return false;
            }
        }
        
    }
    
    //returns the price of an asset
    function getPrice(uint token_id, uint asset_type) public view returns (uint){
        
        if(asset_type == 1){
            Building memory tempBuilding = buildingMaps[token_id];
            return tempBuilding.price;
        } else if(asset_type == 0){
             Land memory tempLand = landMaps[token_id];
             return tempLand.price;
        } else{return 0;}
            
    }
    
    //gets total number of buildins and lands created on the smart contract
    function getNumBuildings() view public returns(uint){return numBuildings;}
    function getNumLands() view public returns(uint){return numLands;}

    
}