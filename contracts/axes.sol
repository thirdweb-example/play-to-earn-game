// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
/$$   /$$ /$$$$$$$$ /$$$$$$$$ /$$$$$$$         /$$$$$$        /$$$$$$$$ /$$$$$$   /$$$$$$  /$$      /$$$$           /$$$  
| $$$ | $$| $$_____/| $$_____/| $$__  $$       /$$__  $$      |__  $$__//$$__  $$ /$$__  $$| $$     /$$  $$         |_  $$ 
| $$$$| $$| $$      | $$      | $$  \ $$      | $$  \ $$         | $$  | $$  \ $$| $$  \ $$| $$    |__/\ $$       /$$ \  $$
| $$ $$ $$| $$$$$   | $$$$$   | $$  | $$      | $$$$$$$$         | $$  | $$  | $$| $$  | $$| $$        /$$/      |__/  | $$
| $$  $$$$| $$__/   | $$__/   | $$  | $$      | $$__  $$         | $$  | $$  | $$| $$  | $$| $$       /$$/             | $$
| $$\  $$$| $$      | $$      | $$  | $$      | $$  | $$         | $$  | $$  | $$| $$  | $$| $$      |__/         /$$  /$$/
| $$ \  $$| $$$$$$$$| $$$$$$$$| $$$$$$$/      | $$  | $$         | $$  |  $$$$$$/|  $$$$$$/| $$$$$$$$ /$$        |__//$$$/ 
|__/  \__/|________/|________/|_______/       |__/  |__/         |__/   \______/  \______/ |________/|__/           |___/ 
*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "./lib/BlackHolePrevention.sol";

//WE COULD INTRODUCE RANDOM MINTING??

//COREY: MAKE EACH AXE VARYING IN DURABILITY
//REPAIR FUNCTION
//EACH TIME SOMETHING IS MINED AXE IS DAMAGED
//IF THE AXE REACHES 0 IT BROKES(BURNS??)
//IF YOU REPAIR IT EVERYTHING FINE.
//DIVIDED IT BY QUALITY

contract Axes is ERC1155, Ownable, VRFConsumerBaseV2, ReentrancyGuard, BlackholePrevention{

  using SafeMath for uint256;
  using Strings for uint256;
   
  // Maps
  mapping(uint => string) public tokenURI;
  mapping(uint256 => uint256) public randomMap; // maps a tokenId to a random number
  mapping(bytes32 => uint256) public requestMap; // maps a requestId to a tokenId

    struct axe{
    uint id;
    string rarity;
    string URI;
    address owner;
    uint durability;
  }

  //property details
  mapping(uint => axe[])public mapAxe;

  mapping (uint => uint) public supplies;
  mapping(uint => bool) public pass;

  mapping(uint => uint)mintRate;
  
  //MAX NUMBER 65535
  uint16 public axe1;
  uint16 public axe2;
  uint16 public axe3;

/**
* Parameters from the constructor from polygon mumbai also key hash
* https://docs.chain.link/docs/vrf/v2/supported-networks/#polygon-matic-mumbai-testnet
* first address verifies that the numbers from the chainlink protocol are actually random
*/
  //chainlink wise VRF
  VRFCoordinatorV2Interface COORDINATOR;
  uint64 s_subscriptionId;
  address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
  bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
  uint32 callbackGasLimit = 100000;
  uint16 requestConfirmations = 3;
  uint32 numWords =  1;
  uint256[] public s_randomWords;
  uint256 public s_requestId;
  uint256 public s_randomRange;
  address s_owner;
   
  constructor(uint64 subscriptionId) ERC1155("") VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;
  }

  /** 
  * Requests randomness 
  */
  function getRandomNumber() external {
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  function fulfillRandomWords(
  uint256, /* requestId */
  uint256[] memory randomWords
) internal override {
  s_randomRange = (randomWords[0] % 4) + 1;
   }


  function constructTokenURI(uint256 tokenId)
        public
        view
        returns(string memory)
    {
        // get random number from map
        uint256 randomNumber = randomMap[tokenId];
        // build tokenURI from randomNumber
        string memory randomTokenURI = string(abi.encodePacked(tokenURI[tokenId], randomNumber.toString(), ".png"));
        
        // metadata
        string memory name = string(abi.encodePacked("token #", tokenId.toString()));
        string memory description = "Dirt is the best";

        // prettier-ignore
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked('{"name":"', name, '", "description":"', description, '", "image": "', randomTokenURI, '"}')
                    )
                )
            )
        );
    }


//CREATE AN ID FOR EACH ERC1155
//REQUIRE THAT THE USER HAS A PIONEER?
  function mintAxe(uint _id, uint _erc1155Id) external payable {
    //TODO: INITIALIZE THE VALUES OF THE MINT RATE
    require(msg.value >= mintRate[_id], "Not enough ether sent");
    require(balanceOf(msg.sender, _id) < 1, "You can't have more than 1");
    //COREY: 1 MINT PASS. ALLOW ACORDING TO A WHITELIST.
    //WHEN THEY ARE MINTING HAVE STILL AVAILBALE IN OTHER BUNCH
    if(_id == 1){
      require(axe1 < supplies[_id],"no more axes");
      axe1 ++;
    }else if(_id == 2){
      require(axe2 < supplies[_id],"no more axes");
      axe2 ++;
    }else if(_id == 3){
      require(axe3 < supplies[_id],"no more axes");
      axe3 ++;
    }
    _mint(msg.sender , _id, 1, "");
    //TODO: UPDATE THE OWNER ADDRESS OF THE STRUCT
    
  }

  function TeamMint(address beneficiary, uint256 quantity, uint _id) external onlyOwner {
        //require(quantity + _numberMinted(beneficiary) <= MAX_MINTS, "Exceeded the limit");
        //require(totalSupply() + quantity <= MAX_SUPPLY_PROJECT, "Not enough tokens left for team");
        _mint(beneficiary, _id, quantity,"");
        //TODO: CREATE A VARIABLE THAT GETS THE QUANTITY WHEN MINTED AND SUM IT UP EVRYTIME MINTED. NOT MORE THAN 100
  }
  
  // function mintAxe2() external payable {
  //   require(balanceOf(msg.sender, 2) < 1, "You can't have more than 1");
  //   require(msg.value >= 0.1 ether,"more ether");
  //   _mint(msg.sender , 2, 1, "");
  //   //TODO: UPDATE THE OWNER ADDRESS OF THE STRUCT
  // }
  

//***************************KEY FUNCTIONS***************************
  function createAxe(string memory _rarity, uint _id, string memory _uri, uint _durability)external onlyOwner{
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
    mapAxe[_id].push(axe(_id,_rarity,_uri,msg.sender, _durability));
  }

  function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }

  function setMintRate(uint _id, uint _price)external onlyOwner{
    mintRate[_id] = _price;
  }

//*******************************NOT SUPER IMPORTANT FUNCTIONS*****************************
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

  function withdrawEther(address payable receiver, uint256 amount) external virtual onlyOwner {
    _withdrawEther(receiver, amount);
  }

  function withdrawErc20(address payable receiver, address tokenAddress, uint256 amount) external virtual onlyOwner {
    _withdrawERC20(receiver, tokenAddress, amount);
  }

  function withdrawERC721(address payable receiver, address tokenAddress, uint256 tokenId) external virtual onlyOwner {
    _withdrawERC721(receiver, tokenAddress, tokenId);
  }

  

  fallback()external payable{}

  receive() external payable{}
   

}



    