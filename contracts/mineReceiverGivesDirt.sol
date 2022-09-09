//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 /$$       /$$$$$$$$ /$$$$$$$$ /$$ /$$$$$$        /$$      /$$ /$$$$$$ /$$   /$$ /$$$$$$$$        /$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$$        /$$$$$$   /$$$$$$  /$$       /$$$$$$$  /$$
| $$      | $$_____/|__  $$__/| $//$$__  $$      | $$$    /$$$|_  $$_/| $$$ | $$| $$_____/       /$$__  $$ /$$__  $$| $$$    /$$$| $$_____/       /$$__  $$ /$$__  $$| $$      | $$__  $$| $$
| $$      | $$         | $$   |_/| $$  \__/      | $$$$  /$$$$  | $$  | $$$$| $$| $$            | $$  \__/| $$  \ $$| $$$$  /$$$$| $$            | $$  \__/| $$  \ $$| $$      | $$  \ $$| $$
| $$      | $$$$$      | $$      |  $$$$$$       | $$ $$/$$ $$  | $$  | $$ $$ $$| $$$$$         |  $$$$$$ | $$  | $$| $$ $$/$$ $$| $$$$$         | $$ /$$$$| $$  | $$| $$      | $$  | $$| $$
| $$      | $$__/      | $$       \____  $$      | $$  $$$| $$  | $$  | $$  $$$$| $$__/          \____  $$| $$  | $$| $$  $$$| $$| $$__/         | $$|_  $$| $$  | $$| $$      | $$  | $$|__/
| $$      | $$         | $$       /$$  \ $$      | $$\  $ | $$  | $$  | $$\  $$$| $$             /$$  \ $$| $$  | $$| $$\  $ | $$| $$            | $$  \ $$| $$  | $$| $$      | $$  | $$    
| $$$$$$$$| $$$$$$$$   | $$      |  $$$$$$/      | $$ \/  | $$ /$$$$$$| $$ \  $$| $$$$$$$$      |  $$$$$$/|  $$$$$$/| $$ \/  | $$| $$$$$$$$      |  $$$$$$/|  $$$$$$/| $$$$$$$$| $$$$$$$/ /$$
|________/|________/   |__/       \______/       |__/     |__/|______/|__/  \__/|________/       \______/  \______/ |__/     |__/|________/       \______/  \______/ |________/|_______/ |__/
*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

import "./Pioneers.sol";
import "./dirt.sol"; // For my collection of Pickaxes
import "./axes.sol"; // For my ERC-20 Token contract

contract dirtMines is ERC1155, Ownable, ReentrancyGuard, ERC1155Receiver, ERC1155Holder{

  // Store our two other contracts here (Edition Drop and Token)
  Dirt public immutable rewardsToken;
  Axes public immutable NFTs1155;
  Pioneers public immutable pioneers;
    
  mapping(uint => string) public tokenURI;

   struct Mines{
    uint id;
    string name;
    string URI;
    address owner;
  }

   //property details
   mapping(uint => Mines[])public mines;

   struct MapValue {
        bool isData;
        uint256 value;
    }

    // Mapping of player addresses to their current dirt
    // By default, player has no dirt. They will not be in the mapping.
    // Mapping of address to dirt is not set until they stake a one.
    // In this example, the tokenId of the dirt is the multiplier for the reward.
    mapping (address => MapValue) public axe;

    // Mapping of player address until last time they staked/withdrew/claimed their rewards
    // By default, player has no last time. They will not be in the mapping.
    mapping (address => MapValue) public playerLastUpdate;

  constructor(Axes _axes, Dirt _dirt1155, Pioneers _pioneers721) ERC1155("") {
    NFTs1155 = _axes;
    rewardsToken = _dirt1155;
    pioneers = _pioneers721;
  }

  function mintMines(address _to, uint _id, uint _amount) external onlyOwner {
    _mint(_to, _id, _amount, "");
  }

  function createMines(string memory _mineName, uint _id, string memory _uri)external onlyOwner{
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
    mines[_id].push(Mines(_id,_mineName,_uri,msg.sender));
  }

  function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external onlyOwner {
    _mintBatch(_to, _ids, _amounts, "");
  }

  function burn(uint _id, uint _amount) external {
    _burn(msg.sender, _id, _amount);
  }

  function burnBatch(uint[] memory _ids, uint[] memory _amounts) external {
    _burnBatch(msg.sender, _ids, _amounts);
  }

  function burnForMint(address _from, uint[] memory _burnIds, uint[] memory _burnAmounts, uint[] memory _mintIds, uint[] memory _mintAmounts) external onlyOwner {
    _burnBatch(_from, _burnIds, _burnAmounts);
    _mintBatch(_from, _mintIds, _mintAmounts, "");
  }

  function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }

  function uri(uint _id) public override view returns (string memory) {
    return tokenURI[_id];
  }

//   function changeMyMineName(uint _mineId)external{
//       Mines memory mine = Mines.id;
//       require(msg.sender == mines[_mineId].owner,'not the owner of the mine');
//   }

  function stake(uint256 _tokenId) external nonReentrant {
        // Ensure the player has at least 1 of the token they are trying to stake
        require(pioneers.balanceOf(msg.sender) >= 1, "You must have at least 1 pioneer to stake");
        require(NFTs1155.balanceOf(msg.sender, _tokenId) >= 1, "You must have at least 1 tool to stake");

        // If they have a pickaxe already, send it back to them.
        if (axe[msg.sender].isData) {
            // Transfer using safeTransfer
            NFTs1155.safeTransferFrom(address(this), msg.sender, axe[msg.sender].value, 1, "Returning your old dirt");
        }

        // Calculate the rewards they are owed, and pay them out.
        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.safeTransferFrom(address(this), msg.sender,1,1,"");

        // Transfer the pickaxe to the contract
        NFTs1155.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "Staking your pickaxe");
       
        // Update the dirt mapping
        axe[msg.sender].value = _tokenId;
        axe[msg.sender].isData = true;

        // Update the playerLastUpdate mapping
        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }


    function withdraw() external nonReentrant {
        // Ensure the player has a pickaxe
        require(axe[msg.sender].isData, "You do not have a pickaxe to withdraw.");

        //TODO:CREATE A COUNTER FOR WHEN THE NFT IS STAKED
        //Calculate Rewards
        if (axe[msg.sender].value == 1){

        }else if (axe[msg.sender].value == 2){

        }else if (axe[msg.sender].value == 3){
            
        }else if (axe[msg.sender].value == 4){
            
        }

        // Calculate the rewards they are owed, and pay them out.
        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.safeTransferFrom(address(this), msg.sender,1,1,"");

        // Send the pickaxe back to the player
        NFTs1155.safeTransferFrom(address(this), msg.sender, axe[msg.sender].value, 1, "Returning your old pickaxe");

        // Update the axe mapping
        axe[msg.sender].isData = false;

        // Update the playerLastUpdate mapping
        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }

    function claim() external nonReentrant {
        //TOD:CREATE A COUNTER FOR WHEN THE NFT IS STAKED
        if (axe[msg.sender].value == 1){

        }else if (axe[msg.sender].value == 2){

        }else if (axe[msg.sender].value == 3){
            
        }else if (axe[msg.sender].value == 4){
            
        }

        // Calculate the rewards they are owed, and pay them out.
        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.safeTransferFrom(address(this), msg.sender,1,1,"");

        // Update the playerLastUpdate mapping
        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }        
    
    function calculateRewards(address _player)
        public
        view
        returns (uint256 _rewards)
    {
        // If playerLastUpdate or axe is not set, then the player has no rewards.
        if (!playerLastUpdate[_player].isData || !axe[_player].isData) {
            return 0;
        }

    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
        //return super.supportsInterface(interfaceId);
        return(ERC1155.supportsInterface(interfaceId) || 
            //ERC1155Holder.supportsInterface(interfaceId) ||
            ERC1155Receiver.supportsInterface(interfaceId));
    }

}
    