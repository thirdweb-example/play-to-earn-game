// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 /$$$$$$$  /$$$$$$$$        /$$$$$$         /$$$$$$  /$$$$$$$$ /$$$$$$$$ /$$$$$$$$ /$$       /$$$$$$$$ /$$$$$$$  /$$
| $$__  $$| $$_____/       /$$__  $$       /$$__  $$| $$_____/|__  $$__/|__  $$__/| $$      | $$_____/| $$__  $$| $$
| $$  \ $$| $$            | $$  \ $$      | $$  \__/| $$         | $$      | $$   | $$      | $$      | $$  \ $$| $$
| $$$$$$$ | $$$$$         | $$$$$$$$      |  $$$$$$ | $$$$$      | $$      | $$   | $$      | $$$$$   | $$$$$$$/| $$
| $$__  $$| $$__/         | $$__  $$       \____  $$| $$__/      | $$      | $$   | $$      | $$__/   | $$__  $$|__/
| $$  \ $$| $$            | $$  | $$       /$$  \ $$| $$         | $$      | $$   | $$      | $$      | $$  \ $$    
| $$$$$$$/| $$$$$$$$      | $$  | $$      |  $$$$$$/| $$$$$$$$   | $$      | $$   | $$$$$$$$| $$$$$$$$| $$  | $$ /$$
|_______/ |________/      |__/  |__/       \______/ |________/   |__/      |__/   |________/|________/|__/  |__/|__/                                                                                                                                                                                                                                                                                                                                 
*/

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./mintEarlyPioneersPass.sol";

/** @notice     IMPLEMENTATION ERC721A
* 1 Reduces wasted storage of token metadata
* 2 Limits the ownership state variables updates once per batch mint
*/

contract earlyCaliforniaPioneer is ERC721A, Ownable, ReentrancyGuard{

    uint32 MAX_MINTS = 1;
    //uint32 MAX_SUPPLY_PUBLIC = 900;
    uint32 MAX_SUPPLY_PROJECT = 1000;
    uint32 MAX_SUPPLY_BROOKLING = 187;
    uint32 MAX_SUPPLY_DONNER_PARTY = 507;
    uint32 MAX_SUPPLY_OREGON = 900;
    
    string private _baseTokenURI;
    
    struct PauseMints{
      bool paused;
    }

    mapping(uint => bool) public pause;

    MintPassEarlyPioneers public mintPass;

    //mintPass.MintPass = mintPass.addressToPass[msg.sender];

    MintPassEarlyPioneers.MintPass passStruct;

    struct BirthCertificate{
      bool used;
    }

    mapping (address => BirthCertificate)public usedPass;
  
    uint256 public mintRate = 0 ether;

    constructor() ERC721A("Early California Pioneers", "Let's Mine Some Gold") {
      //Parameter errased: MintPassEarlyPioneers _mintPass
      //mintPass = _mintPass;
      //only 1 = check!
      pause[1] = true;
      pause[2] = true;
      pause[3] = true;
    }

    /**
     * @dev Enables the NFT minting using SafeMint
     * SafeMint function is similar to mint but it  checks if you are sending the minted token to a Contract that is capable to manage NFTs or not.
     * Therefore it prevents the tokens to be lost 
     * U gotta have a mint pass babyyyyyy
    */
      function Mint(uint _passId) external payable {
      //STILL ABLE TO SEND THE PASS TO ANOTHER ADDRESS AND USE IT
      //NOT POSSIBLE TO CREATE A FNCTION IN THE MINT PASS CONTRACT BECAUSE YOU CAN'T ALLOW THIS ADDRESS TO ENTER THE FUCNTION BECAUSE THIS CONTRACT GOES AFTER THAN THE OTHER ONE
      //require(mintPass.addressToPass[msg.sender].used == false, "pass unused");
      require(pause[_passId] == false,"paused");
      require(mintPass.balanceOf(msg.sender, _passId) >= 1, "No pass no fun");
      require(_numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
      require(totalSupply() + 1 <= MAX_SUPPLY_BROOKLING, "Not enough tokens left for public");
      require(msg.value >= mintRate, "Not enough ether sent");
      _safeMint(msg.sender, _passId);
      mintPass.checkIsUsed(msg.sender,_passId,true);

      //usedPass[msg.sender].used = true;
      //CALL COREY!!!!!!!!!!
      //ONLY CALLABLE BY THIS CONTRACT
      //MAKE IT EVEYRHTING IN 1 FUNCTION. ESPECIFY IN THE METADATA.
      //WHETHER IF IT IS ANIMATED OR NOT ().

    }

     //theorically we could still mint more than 1000, but we have to keep it max 1000.
    function TeamMint(address beneficiary, uint256 quantity) external onlyOwner {
        require(quantity + _numberMinted(beneficiary) <= MAX_MINTS, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_SUPPLY_PROJECT, "Not enough tokens left for team");
        _safeMint(beneficiary, quantity);
        //TODO: CREATE A VARIABLE THAT GETS THE QUANTITY WHEN MINTED AND SUM IT UP EVRYTIME MINTED. NOT MORE THAN 100
    }


    // function BrooklingMint() external payable {
    //   //STILL ABLE TO SEND THE PASS TO ANOTHER ADDRESS AND USE IT
    //   require(usedPass[msg.sender].used == false, "pass unused");
    //   require(pause[1] == false,"paused");
    //   require(mintPass.balanceOf(msg.sender, 1) >= 1, "No pass no fun");
    //   require(_numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
    //   require(totalSupply() + 1 <= MAX_SUPPLY_BROOKLING, "Not enough tokens left for public");
    //   require(msg.value >= mintRate, "Not enough ether sent");
    //   _safeMint(msg.sender, 1);
    //   usedPass[msg.sender].used = true;
      //mintPass.safeTransferFrom(msg.sender, address(this), 1, 1, "");
      //NEED TO UPDATE THE STRUCT ***IMPOSSIBLEEEEE****
      //mintPass.addressToPass[msg.sender] = passStruct(true,1);
      //BURN THE PASS(AIMING TO MAKE AN UNTRANSFEARABLE PASS)
      //mintPass.burn(1,1);

      //CALL COREY!!!!!!!!!!
      //ONLY CALLABLE BY THIS CONTRACT
      //MAKE IT EVEYRHTING IN 1 FUNCTION. ESPECIFY IN THE METADATA.
      //WHETHER IF IT IS ANIMATED OR NOT ().

    //}
    // function DonnerPartyMint() external payable {
    //   require(pause[2] == false,"paused");
    //   require(mintPass.balanceOf(msg.sender, 2) >= 1, "No pass no fun");
    //   require(_numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
    //   require(totalSupply() + 1 <= MAX_SUPPLY_DONNER_PARTY, "Not enough tokens left for public");
    //   require(msg.value >= mintRate, "Not enough ether sent");
    //   _safeMint(msg.sender, 1);
    // }

    // function OregonMint() external payable {
    //     require(pause[3] == false,"paused");
    //     require(mintPass.balanceOf(msg.sender, 2) >= 1, "No pass no fun");
    //     require(_numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
    //     require(totalSupply() + 1 <= MAX_SUPPLY_OREGON, "Not enough tokens left for public");
    //     require(msg.value >= mintRate, "Not enough ether sent");
    //     _safeMint(msg.sender, 1);
    // }
    
    /**
    * @dev Enables Paydirt to withdraw the funds that are deposited in the contract
    */

    function withdraw() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
    }

    /**
    * @dev Justs for prevention(change the mint pass contract address)
    */
    function setMintPassAddress(MintPassEarlyPioneers _passAddress)public onlyOwner{
      mintPass = _passAddress;
    }
    
    /**
    * @dev Enables Paydirt to edit the cost for each NFT
    */
    function setMintRate(uint256 _mintRate) external onlyOwner {
      mintRate = _mintRate;
    }

    function Pause(bool _pause, uint _mintId) external onlyOwner {
      require(pause[_mintId] != _pause, "alredy paused/unpaused");
      pause[_mintId] = _pause;
    }

/**
  * @dev Sets the base URI for all token IDs.
  * It is automatically added as a prefix to the value returned in tokenURI.
*/   

  function setBaseURI(string memory baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);
  }

  fallback()external payable{}

  receive() external payable{}

}