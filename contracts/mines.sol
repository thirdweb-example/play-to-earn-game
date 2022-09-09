// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//ADD ROYALTIES OT THE NFTSSSSS
//SET A MAX NUMBER OF STAKING PIONEERS TO BE ABLE TO HAVE LL THE MINES WITH PIONEERS

//Mine:  ipfs://bafkreig36rvamk47z3hhnfneilwi2keaf3xvn5croisnyh3yy4xggsbkiu

/**
 /$$      /$$  /$$$$$$  /$$   /$$ /$$   /$$  /$$$$$$        /$$   /$$  /$$$$$$  /$$    /$$ /$$$$$$$$       /$$$$$$$$ /$$   /$$ /$$$$$$$$       /$$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$$ /$$$$$$$         /$$$$$$  /$$$$$$$$       /$$      /$$ /$$$$$$ /$$   /$$ /$$$$$$$$ /$$$$$$ /$$   /$$  /$$$$$$   /$$$$ 
| $$  /$ | $$ /$$__  $$| $$$ | $$| $$$ | $$ /$$__  $$      | $$  | $$ /$$__  $$| $$   | $$| $$_____/      |__  $$__/| $$  | $$| $$_____/      | $$__  $$ /$$__  $$| $$  /$ | $$| $$_____/| $$__  $$       /$$__  $$| $$_____/      | $$$    /$$$|_  $$_/| $$$ | $$|__  $$__/|_  $$_/| $$$ | $$ /$$__  $$ /$$  $$
| $$ /$$$| $$| $$  \ $$| $$$$| $$| $$$$| $$| $$  \ $$      | $$  | $$| $$  \ $$| $$   | $$| $$               | $$   | $$  | $$| $$            | $$  \ $$| $$  \ $$| $$ /$$$| $$| $$      | $$  \ $$      | $$  \ $$| $$            | $$$$  /$$$$  | $$  | $$$$| $$   | $$     | $$  | $$$$| $$| $$  \__/|__/\ $$
| $$/$$ $$ $$| $$$$$$$$| $$ $$ $$| $$ $$ $$| $$$$$$$$      | $$$$$$$$| $$$$$$$$|  $$ / $$/| $$$$$            | $$   | $$$$$$$$| $$$$$         | $$$$$$$/| $$  | $$| $$/$$ $$ $$| $$$$$   | $$$$$$$/      | $$  | $$| $$$$$         | $$ $$/$$ $$  | $$  | $$ $$ $$   | $$     | $$  | $$ $$ $$| $$ /$$$$    /$$/
| $$$$_  $$$$| $$__  $$| $$  $$$$| $$  $$$$| $$__  $$      | $$__  $$| $$__  $$ \  $$ $$/ | $$__/            | $$   | $$__  $$| $$__/         | $$____/ | $$  | $$| $$$$_  $$$$| $$__/   | $$__  $$      | $$  | $$| $$__/         | $$  $$$| $$  | $$  | $$  $$$$   | $$     | $$  | $$  $$$$| $$|_  $$   /$$/ 
| $$$/ \  $$$| $$  | $$| $$\  $$$| $$\  $$$| $$  | $$      | $$  | $$| $$  | $$  \  $$$/  | $$               | $$   | $$  | $$| $$            | $$      | $$  | $$| $$$/ \  $$$| $$      | $$  \ $$      | $$  | $$| $$            | $$\  $ | $$  | $$  | $$\  $$$   | $$     | $$  | $$\  $$$| $$  \ $$  |__/  
| $$/   \  $$| $$  | $$| $$ \  $$| $$ \  $$| $$  | $$      | $$  | $$| $$  | $$   \  $/   | $$$$$$$$         | $$   | $$  | $$| $$$$$$$$      | $$      |  $$$$$$/| $$/   \  $$| $$$$$$$$| $$  | $$      |  $$$$$$/| $$            | $$ \/  | $$ /$$$$$$| $$ \  $$   | $$    /$$$$$$| $$ \  $$|  $$$$$$/   /$$  
|__/     \__/|__/  |__/|__/  \__/|__/  \__/|__/  |__/      |__/  |__/|__/  |__/    \_/    |________/         |__/   |__/  |__/|________/      |__/       \______/ |__/     \__/|________/|__/  |__/       \______/ |__/            |__/     |__/|______/|__/  \__/   |__/   |______/|__/  \__/ \______/   |__/  
*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./lib/BlackHolePrevention.sol";

import "./earlyPioneersAxe.sol";
//import "./earlyPioneersFlattened_flat.sol";
import "./dirt.sol"; 
import "./axes.sol";

contract miningMines is ERC1155, Ownable, ReentrancyGuard, BlackholePrevention {

  //TODO: STE MAX SUPPLY AND HOW MANY CAN THEY MINT
  //TODO: DO THE LOGIC THAT IF YOU HAVE A MINE EARN ROYALTIES ETC.
    
  mapping(uint => string) public tokenURI;

   struct Mines{
    address owner;
    uint id;
  }

  //property details
  mapping(uint => Mines)public mines;
  bool public pausedMine;
  bool public pausedStaking;

  uint mintedMines = 0;
  uint256 public mintRate = 0 ether;

  //OTHER CONTRACTS
  earlyCaliforniaPioneer public earlyPioneer;
  Dirt public rewardsNFT;
  Axes public axes;

  //AXE AND PIONEERS WISE
  uint minStakingTime = 7 days;
  uint stakingEndTime;
    
  struct Pioneer {
    bool isStaked;
    uint256 id;
    uint256 stakingEndTime;
  }

  mapping (address => Pioneer) public pioneer;

  constructor() ERC1155("") {

  }
  function createMines(uint _id, string memory _uri)external onlyOwner{
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
    //mines[_id].push(Mines(msg.sender));
  }

  //NOTICE: ALL 1 because we do not going to have more than one type of mine, if so change the1 for a variable
  function mintMine() external payable {
    require(!pausedMine,"paused");
    require(balanceOf(msg.sender, 1) < 1, "You can't have more than 1");
    require(msg.value >= mintRate, "more ether");
    _mint(msg.sender , 1, 1, "");
    mintedMines ++;
    mines[mintedMines] = Mines(msg.sender, mintedMines);
    //TODO: UPDATE THE OWNER ADDRESS OF THE STRUCT
  }
  
  //TODO: TAKE OUT ONLYOWNER AND DO THE LOGIC
  function mintMinesOwner(address _to, uint _id, uint _amount) external onlyOwner {
    _mint(_to, _id, _amount, "");
  }

  function earnWithMine(uint _tokenId, uint _mineId, uint _amount)public{
    require(balanceOf(msg.sender,1) >= 1, "You must have at least 1 mine to stake");
    //send the mine to us
    safeTransferFrom(msg.sender, address(this), _tokenId, _amount,"transfering mine");
  }


  function stakePioneer(uint256 _tokenId) external nonReentrant {
        require(!pausedStaking,"paused");
        //TODO: CHECK WHETHER THE PIONEER HAS AXES (2ND LINE!!!)
        //TRACK HOM MAY NFTS ARE STAKED IN EACH MINE
        // require(balanceOf(msg.sender,1) >= 1, "You must have at least 1 mine to stake");
        require(earlyPioneer.balanceOf(msg.sender) >= 1, "You must have at least 1 pioneer to stake");
        //GRAB THE TOKENID FROM THE FRONTEND
        //CHECK THE LINE JUST BELLOW
        //require(earlyPioneer.ownerOfId[msg.sender][_tokenId] == true,"not staked");
        require(!pioneer[msg.sender].isStaked, "already staked");
        //IF THE USER "OWNS THE MINE DO X"
        if(balanceOf(msg.sender,1) >= 1){
          //MAKE LESS TIME TO STAKE AND CLAIM ETC
        }
        // Transfer the earlyPioneer to the contract
        earlyPioneer.safeTransferFrom(msg.sender, address(this), _tokenId);
        // Update the pioneer mapping
        pioneer[msg.sender].id = _tokenId;
        pioneer[msg.sender].isStaked = true;
        pioneer[msg.sender].stakingEndTime = block.timestamp + minStakingTime;
  }

  function withdrawPioneer() external nonReentrant {
        // Ensure the player has dirt
        //TODO: CREATE AN IF STATEMENT THAT IF THE CLINNING TIME HAS NOT FINISHED DO NOT PAY
        require(pioneer[msg.sender].isStaked, "You have no pioneer to withdraw.");
        require(block.timestamp > pioneer[msg.sender].stakingEndTime,"Can't withdraw before 1 week");
        //THINKING ABOUT TAKING AWAY THE REWARDS IF THEY UNSTAKE
        _dirtLogic();
        // Send the pioneer back to the player
        //CHECK THE ID LOGIC
        earlyPioneer.safeTransferFrom(address(this), msg.sender, pioneer[msg.sender].id);
        // Update the dirt mapping
        pioneer[msg.sender].isStaked = false;

    }

    function claimGold() external nonReentrant {
      //TODO: Require that the cleaning time has ended
      //TODO: COULD INTRODUCE SOME ENERGY
      require(pioneer[msg.sender].isStaked, "Nothing staked");
      _dirtLogic();
      //BURN THE DIRT? OR SEND IT TO OUR WALLET TO SELL IT AGAIN??

    }        

  //****************SET ADRESSES************************************
   
    function setEarlyPioneersAddress(earlyCaliforniaPioneer _address)external onlyOwner{
      earlyPioneer = _address;
    }

    function setDirtAddress(Dirt _address)external onlyOwner{
      rewardsNFT = _address;   
    }
    
  //****************NOT ESSENTIAL FUNCTIONS*************************
  function PauseMine(bool _pause) external onlyOwner {
    require(pausedMine != _pause, "alredy paused/unpaused");
    pausedMine = _pause;
  }

   function PauseStaking(bool _pause) external onlyOwner {
    require(pausedStaking != _pause, "alredy paused/unpaused");
    pausedStaking = _pause;
  }

  function setMintRate(uint256 _mintRate) external onlyOwner {
    mintRate = _mintRate;
  }


  // function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external onlyOwner {
  //   _mintBatch(_to, _ids, _amounts, "");
  // }

  // function burn(uint _id, uint _amount) external {
  //   _burn(msg.sender, _id, _amount);
  // }

  function uri(uint _id) public override view returns (string memory) {
    return tokenURI[_id];
  }
  
//****************************RECEIVE ETH FUNCTIONS**************************
  fallback()external payable{}

  receive() external payable{}
  

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

//LOGIC 
  //***************CHECK WHETHER WE HAVE TO PUT ONLYOWNER*****************************************
  //REWARDS UPON TEH RARITY OF THE AXE AND WHETHER THE NFT IS VIDEO OR NOT
  function _dirtLogic() internal {
    if(pioneer[msg.sender].id == 1 && pioneer[msg.sender].stakingEndTime < block.timestamp ){
      rewardsNFT.safeTransferFrom(address(this), msg.sender,1,1,"");
    }else if(pioneer[msg.sender].id == 2 && pioneer[msg.sender].stakingEndTime < block.timestamp ){
      rewardsNFT.safeTransferFrom(address(this), msg.sender,2,1,"");
    }else if(pioneer[msg.sender].id == 3 && pioneer[msg.sender].stakingEndTime < block.timestamp ){
      rewardsNFT.safeTransferFrom(address(this), msg.sender,3,1,"");
    }else if(pioneer[msg.sender].id == 4 && pioneer[msg.sender].stakingEndTime < block.timestamp ){
      rewardsNFT.safeTransferFrom(address(this), msg.sender,4,1,"");
    }else if(pioneer[msg.sender].id == 5 && pioneer[msg.sender].stakingEndTime < block.timestamp ){
      rewardsNFT.safeTransferFrom(address(this), msg.sender,5,1,"");
    }else if(pioneer[msg.sender].id == 6 && pioneer[msg.sender].stakingEndTime < block.timestamp ){
      rewardsNFT.safeTransferFrom(address(this), msg.sender,6,1,"");
    }
  }


}
    