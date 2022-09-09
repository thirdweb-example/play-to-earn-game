// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 /$$       /$$$$$$$$ /$$$$$$$$ /$$ /$$$$$$         /$$$$$$  /$$$$$$$$ /$$$$$$$$       /$$$$$$$$ /$$   /$$ /$$$$$$$$       /$$   /$$ /$$   /$$ /$$   /$$  /$$$$$$  /$$       /$$$$$$$$  /$$$$$$  /$$
| $$      | $$_____/|__  $$__/| $//$$__  $$       /$$__  $$| $$_____/|__  $$__/      |__  $$__/| $$  | $$| $$_____/      | $$  /$$/| $$$ | $$| $$  | $$ /$$__  $$| $$      | $$_____/ /$$__  $$| $$
| $$      | $$         | $$   |_/| $$  \__/      | $$  \__/| $$         | $$            | $$   | $$  | $$| $$            | $$ /$$/ | $$$$| $$| $$  | $$| $$  \__/| $$      | $$      | $$  \__/| $$
| $$      | $$$$$      | $$      |  $$$$$$       | $$ /$$$$| $$$$$      | $$            | $$   | $$$$$$$$| $$$$$         | $$$$$/  | $$ $$ $$| $$  | $$| $$      | $$      | $$$$$   |  $$$$$$ | $$
| $$      | $$__/      | $$       \____  $$      | $$|_  $$| $$__/      | $$            | $$   | $$__  $$| $$__/         | $$  $$  | $$  $$$$| $$  | $$| $$      | $$      | $$__/    \____  $$|__/
| $$      | $$         | $$       /$$  \ $$      | $$  \ $$| $$         | $$            | $$   | $$  | $$| $$            | $$\  $$ | $$\  $$$| $$  | $$| $$    $$| $$      | $$       /$$  \ $$    
| $$$$$$$$| $$$$$$$$   | $$      |  $$$$$$/      |  $$$$$$/| $$$$$$$$   | $$            | $$   | $$  | $$| $$$$$$$$      | $$ \  $$| $$ \  $$|  $$$$$$/|  $$$$$$/| $$$$$$$$| $$$$$$$$|  $$$$$$/ /$$
|________/|________/   |__/       \______/        \______/ |________/   |__/            |__/   |__/  |__/|________/      |__/  \__/|__/  \__/ \______/  \______/ |________/|________/ \______/ |__/
*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

// import "./lib/BlackHolePrevention.sol";
// BlackholePrevention

import "./dirt.sol"; 
import "./goldDust.sol"; 

contract PaydirtPan is ERC1155, Ownable, ReentrancyGuard, ERC1155Receiver, ERC1155Holder{

  // Store our two other contracts here (Edition Drop and Token)
  Dirt public immutable NFTs1155;
  GoldDust public immutable rewardsToken;
    
  string public name;
  string public symbol;

  mapping(uint => string) public tokenURI;
  mapping(uint => bool) public pause;

  struct Pan{
    uint id;
    string URI;
    address owner;
  }

   //pan details
   mapping(uint => Pan[])public pans;

  uint minCleaningTime = 3 days;
  uint CleaningEndTime;
  uint mintedPans = 0;
    
  struct DIrt {
    bool isCleaning;
    uint256 id;
    uint256 CleaningEndTime;
    uint256 stakingEndTime;
  }

  mapping (address => DIrt) public dirt;

  constructor(GoldDust _goldDust20, Dirt _dirt1155) ERC1155("") {
    NFTs1155 = _dirt1155;
    rewardsToken = _goldDust20;
  }

  
  function cleanDirt(uint256 _tokenId) external nonReentrant {
        // Ensure the player has at least 1 of the token they are trying to stake
        require(balanceOf(msg.sender, 1) >= 1 , "you do not have any pan to clean with");
        require(NFTs1155.balanceOf(msg.sender, _tokenId) >= 1, "You must have at least 1 tool to stake");
        require(!dirt[msg.sender].isCleaning, "already clenaing");

        // Transfer the dirt to the contract
        NFTs1155.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "Cleaning  your dirt");
       
        // Update the dirt mapping (the _tokenId will have to be from dirt)
        dirt[msg.sender].id = _tokenId;
        dirt[msg.sender].isCleaning = true;
        dirt[msg.sender].CleaningEndTime = block.timestamp + CleaningEndTime;
    }


    function withdrawDirt() external nonReentrant {
        // Ensure the player has dirt
        //TODO: CREATE AN IF STATEMENT THAT IF THE CLINNING TIME HAS NOT FINISHED DO NOT PAY
        require(dirt[msg.sender].isCleaning, "You do not have dirt to withdraw.");
        require(block.timestamp > dirt[msg.sender].stakingEndTime,"Can't withdraw before 1 week");
        _goldDustLogic();
        // Send the dirt back to the player
        //CHECK THE ID LOGIC
        NFTs1155.safeTransferFrom(address(this), msg.sender, dirt[msg.sender].id, 1, "Returning your dirt");
        // Update the dirt mapping
        dirt[msg.sender].isCleaning = false;

    }

    function claimGold() external nonReentrant {
      //TODO: Require that the cleaning time has ended
      //TODO: COULD INTRODUCE SOME ENERGY
      require(dirt[msg.sender].isCleaning, "Nothing staked");
      _goldDustLogic();
      //BURN THE DIRT? OR SEND IT TO OUR WALLET TO SELL IT AGAIN??

    }        

  function createPan(uint _id, string memory _uri)external onlyOwner{
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
    pans[_id].push(Pan(_id,_uri,msg.sender));
  }

  function mintPan() external payable {
    require(balanceOf(msg.sender, 1) < 1, "");
    require(msg.value >= 0.05 ether,"more ether");
    _mint(msg.sender , 1, 1, "");
    mintedPans++;
    pans[1][mintedPans].id = mintedPans;
    pans[1][mintedPans].owner = msg.sender;
  }

  //CHANGE THE LOGIC
  function mintPan(address _to, uint _id, uint _amount) external onlyOwner{
    _mint(_to, _id, _amount, "");
  }

//*******************NOT ESSENTIAL FUNCTIONS*************************
  function Pause(bool _pause, uint _mintId) external onlyOwner {
    require(pause[_mintId] != _pause, "alredy paused/unpaused");
    pause[_mintId] = _pause;
  }

  // function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external onlyOwner {
  //   _mintBatch(_to, _ids, _amounts, "");
  // }

  // function burn(uint _id, uint _amount) external {
  //   _burn(msg.sender, _id, _amount);
  // }


  function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }

  function uri(uint _id) public override view returns (string memory) {
    return tokenURI[_id];
  }

//****************************BLACKHOLE PREVENTION FUNCTIONS**************************

    /**
    * @dev Enables Paydirt to withdraw the funds that are deposited in the contract
    */

  function withdraw() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }

  // function withdrawEther(address payable receiver, uint256 amount) external virtual onlyOwner {
  //   _withdrawEther(receiver, amount);
  // }

  // function withdrawErc20(address payable receiver, address tokenAddress, uint256 amount) external virtual onlyOwner {
  //   _withdrawERC20(receiver, tokenAddress, amount);
  // }

  // function withdrawERC721(address payable receiver, address tokenAddress, uint256 tokenId) external virtual onlyOwner {
  //   _withdrawERC721(receiver, tokenAddress, tokenId);
  // }

  // fallback()external payable{}

  // receive() external payable{}
  

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
    //return super.supportsInterface(interfaceId);
    return(ERC1155.supportsInterface(interfaceId) || 
    //ERC1155Holder.supportsInterface(interfaceId) ||
    ERC1155Receiver.supportsInterface(interfaceId));
  }

  //LOGIC 
  //***************CHECK WHETHER WE HAVE TO PUT ONLYOWNER*****************************************
  function _goldDustLogic() internal {
    if(dirt[msg.sender].id == 1 && dirt[msg.sender].stakingEndTime < block.timestamp ){
      rewardsToken.transferFrom(address(this), msg.sender,100);
    }else if(dirt[msg.sender].id == 2 && dirt[msg.sender].stakingEndTime < block.timestamp ){
      rewardsToken.transferFrom(address(this), msg.sender,200);
    }else if(dirt[msg.sender].id == 3 && dirt[msg.sender].stakingEndTime < block.timestamp ){
      rewardsToken.transferFrom(address(this), msg.sender,300);
    }else if(dirt[msg.sender].id == 4 && dirt[msg.sender].stakingEndTime < block.timestamp ){
      rewardsToken.transferFrom(address(this), msg.sender,400);
    }else if(dirt[msg.sender].id == 5 && dirt[msg.sender].stakingEndTime < block.timestamp ){
      rewardsToken.transferFrom(address(this), msg.sender,500);
    }else if(dirt[msg.sender].id == 6 && dirt[msg.sender].stakingEndTime < block.timestamp ){
      rewardsToken.transferFrom(address(this), msg.sender,600);
    }
  }
}
    