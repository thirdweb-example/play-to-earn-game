//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

import "./dirt.sol"; 
import "./goldDust.sol";


//TODO: CHECK DIFFERENCES BETWEEN RECEIVER AND HOLDER 1155
contract dirtToGold is Ownable, ReentrancyGuard, ERC1155Receiver, ERC1155Holder{

  uint minCleaningTime = 3 days;
  uint CleaningEndTime;
    
    struct DIrt {
        bool isCleaning;
        uint256 id;
        uint256 CleaningEndTime;
    }

  mapping (address => DIrt) public dirt;
 
  Dirt public immutable NFTs1155;
  GoldDust public immutable rewardsNFT;
 
  constructor(GoldDust _gold, Dirt _dirt1155) {
    NFTs1155 = _dirt1155;
    rewardsNFT = _gold;
  }

  function cleanDirt(uint256 _tokenId) external nonReentrant {
        // Ensure the player has at least 1 of the token they are trying to stake
        require(NFTs1155.balanceOf(msg.sender, _tokenId) >= 1, "You must have at least 1 tool to stake");

        // If they have dirt already, send it back to them.
        if (dirt[msg.sender].isCleaning) {
            // Transfer using safeTransfer
            NFTs1155.safeTransferFrom(address(this), msg.sender, dirt[msg.sender].id, 1, "Returning your old dirt");
        }

        // Transfer the axe to the contract
        NFTs1155.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "Staking your axe");
       
        // Update the dirt mapping
        dirt[msg.sender].id = _tokenId;
        dirt[msg.sender].isCleaning = true;
        dirt[msg.sender].cleaningEndTime = block.timestamp + CleaningEndTime;
    }


    function withdrawDirt() external nonReentrant {
        // Ensure the player has dirt
        //TODO: CREATE AN IF STATEMENT THAT IF THE CLINNING TIME HAS NOT FINISHED DO NOT PAY
        require(dirt[msg.sender].isCleaning, "You do not have an axe to withdraw.");
        require(block.timestamp > dirt[msg.sender].stakingEndTime,"Can't withdraw before 1 week");

        if (dirt[msg.sender].id == 1){
        rewardsNFT.transferFrom(address(this), msg.sender,100);
        }else if (dirt[msg.sender].id == 2){
        rewardsNFT.transferFrom(address(this), msg.sender,200);
        }else if (dirt[msg.sender].id == 3){
        rewardsNFT.transferFrom(address(this), msg.sender,300);
        }else if (dirt[msg.sender].id == 4){
        rewardsNFT.transferFrom(address(this), msg.sender,400);
        }else if (dirt[msg.sender].id == 5){
        rewardsNFT.transferFrom(address(this), msg.sender,500);
        }else if (dirt[msg.sender].id == 6){
        rewardsNFT.transferFrom(address(this), msg.sender,600);
        }

        // Send the dirt back to the player
        NFTs1155.safeTransferFrom(address(this), msg.sender, dirt[msg.sender].id, 1, "Returning your old axe");

        // Update the dirt mapping
        dirt[msg.sender].isCleaning = false;

    }

    function claimGold() external nonReentrant {
        //TODO: Require that the cleaning time has ended
        //TODO: COULD INTRODUCE SOME ENERGY
        require(dirt[msg.sender].isCleaning, "Nothing staked");
        
        if (dirt[msg.sender].id == 1){
        rewardsNFT.transferFrom(address(this), msg.sender,100);
        }else if (dirt[msg.sender].id == 2){
        rewardsNFT.transferFrom(address(this), msg.sender,200);
        }else if (dirt[msg.sender].id == 3){
        rewardsNFT.transferFrom(address(this), msg.sender,300);
        }else if (dirt[msg.sender].id == 4){
        rewardsNFT.transferFrom(address(this), msg.sender,400);
        }else if (dirt[msg.sender].id == 5){
        rewardsNFT.transferFrom(address(this), msg.sender,500);
        }else if (dirt[msg.sender].id == 6){
        rewardsNFT.transferFrom(address(this), msg.sender,600);
        }
    }        

   function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Receiver) returns (bool) {
        return(ERC1155Receiver.supportsInterface(interfaceId));
    }

    
  fallback()external payable{}

  receive() external payable{}
}