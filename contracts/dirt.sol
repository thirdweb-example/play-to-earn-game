// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Dirt is ERC1155, Ownable, VRFConsumerBaseV2 {

  using SafeMath for uint256;
  using Strings for uint256;
       
  // Maps
  mapping(uint => string) public tokenURI;
  mapping(uint256 => uint256) public randomMap; // maps a tokenId to a random number
  mapping(bytes32 => uint256) public requestMap; // maps a requestId to a tokenId

    struct dirt{
    uint id;
    string richness;
    string URI;
    address owner;
  }

  //property details
  mapping(uint => dirt[])public mapDirt;


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
   // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.
  uint32 callbackGasLimit = 100000;

  // The default is 3, but you can set this higher.
  uint16 requestConfirmations = 3;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  //uint256 public randomResult;
  uint32 numWords =  1;
  uint256[] public s_randomWords;
  uint256 public s_requestId;
  uint256 public s_randomRange;
  address s_owner;
   
  constructor(uint64 subscriptionId) ERC1155("") VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;
    // _mint(msg.sender, blackDirt, 100, "");
    // _mint(msg.sender, brownDirt, 100, "");
    // _mint(msg.sender, yellowDirt, 100, "");
    // _mint(msg.sender, goldDirt, 100, "");
  }

  //Chainlink wise
  /** 
  * Requests randomness 
  */
  function getRandomNumber() external {
    // require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    // return requestRandomness(keyHash, fee);
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  /**
   * Callback function used by VRF CoordinatorV2
   */

  function fulfillRandomWords(
  uint256, /* requestId */
  uint256[] memory randomWords
) internal override {
  // Assuming only one random word was requested.
  s_randomRange = (randomWords[0] % 4) + 1;
//   if(s_randomRange == 1){
//       _mint(msg.sender, blackDirt, 1, "");
//     }else if(s_randomRange == 2){
//       _mint(msg.sender, brownDirt, 100, "");
//     }else if(s_randomRange == 3){
//       _mint(msg.sender, yellowDirt, 100, "");
//     }else if(s_randomRange == 4){
//       _mint(msg.sender, goldDirt, 100, "");
//     }
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


//*********IMPORTANT FUNCTIONS&*******************************
//TODO: CHANGE ALL THE MINTING LOGIC
  function mint(address _to, uint _id, uint _amount) external {
    _mint(_to, _id, _amount, "");
    //TODO: UPDATE THE OWNER ADDRESS OF THE STRUCT OR TAKE IT OUT
  }
  
  function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }

   function createDirt(string memory _richness, uint _id, string memory _uri)external onlyOwner{
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
    mapDirt[_id].push(dirt(_id,_richness,_uri,msg.sender));
  }

//*********NOT IMPORTANT FUNCTIONS*********
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

   
}



    