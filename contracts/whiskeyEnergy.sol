// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



contract Energy is ERC1155, Ownable{

  using SafeMath for uint256;
  using Strings for uint256;
       
  // Maps
  mapping(uint => string) public tokenURI;
  mapping(uint256 => uint256) public randomMap;   // maps a tokenId to a random number
  mapping(bytes32 => uint256) public requestMap; // maps a requestId to a tokenId

  struct Energy{
    uint id;
    uint power;
    string uri;
    address owner;
  }

   bool public paused;
   uint public idSupply;
   

  //property details
  mapping(uint => Energy[])public mapEnergy;
  //map the id of the energy to the power
  mapping(uint => uint)public refillEnergy;
  //mapping to see the costs (id mintRate)
  mapping(uint => uint)public mintRate;

  constructor() ERC1155("") {
    
  }

//*********IMPORTANT FUNCTIONS&*******************************
//TODO: CHANGE ALL THE MINTING LOGIC
//CHECK WHETHER THE mintrate is in ETHER OR WEI OR GWEI.
//I would do 0.1 eth for 1 basic refill and 0.15 super refill
  function mint(uint _id, uint _amount) external payable{
    require(_id <= idSupply, "not existing");
    require(!paused,"paused");
    require(balanceOf(msg.sender, 1) < 5, "You can't have more than 5");
    require(msg.value >= mintRate[_id], "more ether");
    _mint(msg.sender, _id, _amount, "");
    //TODO: UPDATE THE OWNER ADDRESS OF THE STRUCT OR TAKE IT OUT
  }
  
  function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }

   function createDirt(uint _power, uint _id, string memory _uri)external onlyOwner{
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
    mapEnergy[_id].push(Energy(_id,_power,_uri,msg.sender));
  }

  function Pause(bool _pause) external onlyOwner {
    require(paused != _pause, "alredy paused/unpaused");
    paused = _pause;
  }

  function setMintRate(uint _id, uint256 _mintRate) external onlyOwner {
    mintRate[_id] = _mintRate;
  }

  //Customize the quantity o energy types we want
  function changeIdSupply(uint _idSupply)external onlyOwner{
    idSupply = _idSupply;
  }

//*********NOT IMPORTANT FUNCTIONS*********

//   function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external onlyOwner {
//     _mintBatch(_to, _ids, _amounts, "");
//   }

  function burn(uint _id, uint _amount) external {
    _burn(msg.sender, _id, _amount);
  }

//   function burnBatch(uint[] memory _ids, uint[] memory _amounts) external {
//     _burnBatch(msg.sender, _ids, _amounts);
//   }

//   function burnForMint(address _from, uint[] memory _burnIds, uint[] memory _burnAmounts, uint[] memory _mintIds, uint[] memory _mintAmounts) external onlyOwner {
//     _burnBatch(_from, _burnIds, _burnAmounts);
//     _mintBatch(_from, _mintIds, _mintAmounts, "");
//   }

  function uri(uint _id) public override view returns (string memory) {
    return tokenURI[_id];
  }

   
}



    