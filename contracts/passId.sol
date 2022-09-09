// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//ipfs://bafkreibgnjvjmsrhokhheidy7rtjqqt3dc6q7mgck2ioe4wgtwg43gulea

/**
 /$$      /$$  /$$$$$$  /$$   /$$ /$$   /$$  /$$$$$$        /$$$$$$$  /$$        /$$$$$$  /$$     /$$       /$$     /$$   /$$ /$$   /$$  /$$$$ 
| $$  /$ | $$ /$$__  $$| $$$ | $$| $$$ | $$ /$$__  $$      | $$__  $$| $$       /$$__  $$|  $$   /$$/      |  $$   /$$/  /$$/| $$$ | $$ /$$  $$
| $$ /$$$| $$| $$  \ $$| $$$$| $$| $$$$| $$| $$  \ $$      | $$  \ $$| $$      | $$  \ $$ \  $$ /$$/        \  $$ /$$/  /$$/ | $$$$| $$|__/\ $$
| $$/$$ $$ $$| $$$$$$$$| $$ $$ $$| $$ $$ $$| $$$$$$$$      | $$$$$$$/| $$      | $$$$$$$$  \  $$$$/          \  $$$$/  /$$/  | $$ $$ $$    /$$/
| $$$$_  $$$$| $$__  $$| $$  $$$$| $$  $$$$| $$__  $$      | $$____/ | $$      | $$__  $$   \  $$/            \  $$/  /$$/   | $$  $$$$   /$$/ 
| $$$/ \  $$$| $$  | $$| $$\  $$$| $$\  $$$| $$  | $$      | $$      | $$      | $$  | $$    | $$              | $$  /$$/    | $$\  $$$  |__/  
| $$/   \  $$| $$  | $$| $$ \  $$| $$ \  $$| $$  | $$      | $$      | $$$$$$$$| $$  | $$    | $$              | $$ /$$/     | $$ \  $$   /$$  
|__/     \__/|__/  |__/|__/  \__/|__/  \__/|__/  |__/      |__/      |________/|__/  |__/    |__/              |__/|__/      |__/  \__/  |__/ 
*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//PERMISSION FOR THE FUNCTION TO UPDATE
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MintPassEarlyPioneers is ERC1155, Ownable, ReentrancyGuard, AccessControl{

  struct MintPass{
    //CHECK IF USED IS NECESSARY
    bool used;
    uint id;
    uint totalId;
    uint supply;
  }
  
  uint256 public mintRate = 0 ether;

  bytes32 public constant OPEN_ROLE = 0xefa06053e2ca99a43c97c4a4f3d8a394ee3323a8ff237e625fba09fe30ceb0a4;

  //CHECK IF THE PAS HAS BEEN USED
  mapping(address => MintPass) public addressToPass;
  //CHANGE THIS NESTED MAPPING
  mapping(address => mapping(uint => bool)) public usedPass;  
  mapping (uint => uint) public supplies;
  mapping(uint => string) public tokenURI;
  mapping(uint => bool) public pass;

  MintPass[] public mintpass;
  uint public totalMinted = 0;

  //MAX NUMBER 65535
  uint16 public pass1;
  uint16 public pass2;
  uint16 public pass3;

  bool public enableTransfer = false;
 
  constructor() ERC1155("") {
    pass[1] = false;
    pass[2] = false;
    pass[3] = false;
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function mintPassCommunity(uint _id) external payable nonReentrant{
    //TODO: CHECK THE MATHS
    require(pass[_id] == true, "not open for that id");
    require(msg.value >= mintRate, "Not enough ether sent");
    require(balanceOf(msg.sender, _id) < 1, "You can't have more than 1");
    //COREY: 1 MINT PASS. ALLOW ACORDING TO A WHITELIST.
    //WHEN THEY ARE MINTING HAVE STILL AVAILBALE IN OTHER BUNCH
    if(_id == 1){
      require(pass1 < supplies[_id],"no more passes");
      pass1 ++;
    }else if(_id == 2){
      require(pass2 < supplies[_id],"no more passes");
      pass2 ++;
    }else if(_id == 3){
      require(pass3 < supplies[_id],"no more passes");
      pass3 ++;
    }
    _mint(msg.sender, _id, 1, "");
    totalMinted ++;
    //pass[totalMinted] = false;
    //*********************************
    //mintpass.push(MintPass(false, _id, totalMinted, supplies[_id]));
    //********************************
    usedPass[msg.sender][_id] = false;
    addressToPass[msg.sender].id = _id;
    addressToPass[msg.sender].supply = supplies[_id];
  }
  
  function mintPassOwners(address _to, uint _id, uint16 _amount) external onlyOwner {
    _mint(_to, _id, _amount, "");
     if(_id == 1){
      pass1 = pass1 +_amount;
    }else if(_id == 2){
      pass2 = pass2 + _amount;
    }else if(_id == 3){
      pass3 = pass3 +_amount;
    }
  }

  function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }

  function uri(uint _id) public override view returns (string memory) {
    return tokenURI[_id];
  }

  function OpenMinting(bool _open, uint _passId) external onlyOwner {
    pass[_passId] = _open;
  }

  // function updateMintPass (bool _used) public {
  //   addressToPass[msg.sender].used = _used;
  // }

  function setSupplies(uint _id, uint _supply)public onlyOwner{
    supplies[_id] = _supply;
  }

  //VULNERABLE(EVERYONE CAN UPDATE ABOUT ANYONE)
  function checkIsUsed(address _address, uint _id, bool _used)external onlyRole(OPEN_ROLE){
    usedPass[_address][_id] = _used;
  }
  
  /**
  * @dev Enables Paydirt to withdraw the funds that are deposited in the contract
  */

  function withdraw() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }

  //****************************TRANSFER WISE TO MAKE THE PASS UNTRANSFERABLE*********************

  function enableTransfering(bool _tranfer) public onlyOwner{
    enableTransfer = _tranfer;
  }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(enableTransfer == true, "you can't transfer");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

     function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
       require(enableTransfer == true, "you can't transfer");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

  //CHECK WHETHER WE HAVE TO ADD THE KEYWORD SUPER
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        //return super.supportsInterface(interfaceId);
        return(ERC1155.supportsInterface(interfaceId) || 
        AccessControl.supportsInterface(interfaceId));
  }

  fallback()external payable{}

  receive() external payable{}


}
    