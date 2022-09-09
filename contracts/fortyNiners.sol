// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/** @notice     IMPLEMENTATION ERC721A
* 1 Reduces wasted storage of token metadata
* 2 Limits the ownership state variables updates once per batch mint
*/

contract fortyNiners is ERC721A, Ownable, ReentrancyGuard{
  uint256 MAX_MINTS = 10;
  uint256 MAX_SUPPLY_PUBLIC = 90000;
  uint256 MAX_SUPPLY_PROJECT = 100000;
  bool public Paused = false;
   

/**
* @dev ****Change when mainnet***** 
*/

    uint256 public mintRate = 0 ether;

    constructor() ERC721A("Forty Niners", "Wellcome to Paydirt! Wanna have fun? y/n") {

    }

    /**
     * @dev Enables the NFT minting using SafeMint
     * SafeMint function is similar to mint but it  checks if you are sending the minted token to a Contract that is capable to manage NFTs or not.
     * Therefore it prevents the tokens to be lost 
    */

    function mint(uint256 quantity) external payable {
        require(quantity + _numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_SUPPLY_PUBLIC, "Not enough tokens left for public");
        require(msg.value >= (mintRate * quantity), "Not enough ether sent");
        _safeMint(msg.sender, quantity);
    }
    
    //theorically we could still mint more than 1000, but we have to keep it max 1000.
    function TeamMint(address beneficiary, uint256 quantity) external payable onlyOwner {
        require(quantity + _numberMinted(beneficiary) <= MAX_MINTS, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_SUPPLY_PROJECT, "Not enough tokens left for team");
        require(msg.value >= (mintRate * quantity), "Not enough ether sent");
        _safeMint(beneficiary, quantity);
    }

    /**
    * @dev Enables Paydirt to edit the cost for each NFT. 0$
    */
    function setMintRate(uint256 _mintRate) external onlyOwner {
        mintRate = _mintRate;
    }

    function Pause(bool _paused) external onlyOwner {
        Paused = _paused;
    }

/**
  * @notice Metadatawise
  * it is not 100% save because private variables can be still seen if decoded.
  * for testing purposes: ipfs://bafybeieyetlp2c2vubffzjjap7utuz5jwo2k5b5kupvezfchc5tnfg4fh4/
*/

  string private _baseTokenURI;

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

  function withdrawMoney() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }


  function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);
  }

  fallback()external payable{}

  receive() external payable{}

}