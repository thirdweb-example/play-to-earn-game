//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

import "./earlyCaliforniaPioneers.sol";
import "./dirt.sol"; 
import "./axes.sol"; 

  
contract axeToDirt is Ownable, ReentrancyGuard, ERC1155Receiver, ERC1155Holder{

  uint minStakingTime = 7 days;
  uint stakingEndTime;
    
    struct AXE {
      bool isStaked;
      uint256 id;
      uint256 stakingEndTime;
    }

  mapping (address => AXE) public axe;
 
  Dirt public immutable rewardsNFT;
  Axes public immutable NFTs1155;
  earlyCaliforniaPioneer public immutable earlyPioneers;

  constructor(Axes _axes, Dirt _dirt1155, earlyCaliforniaPioneer _pioneers721) {
    NFTs1155 = _axes;
    rewardsNFT = _dirt1155;
    earlyPioneers = _pioneers721;
  }

  function stakeAxe(uint256 _tokenId) external nonReentrant {
      //TODO: MAKE THE LOGIC IF YOU OWN A PIONEER MORE DIRT IN EXCHANGE
      // Ensure the player has at least 1 of the token they are trying to stake
      //POTENTIAL BREAK: EARLY PIONERS CAN BE SENT TO OTHER ACCOUNTS AFTER STAKING SO THEY CAN STAKE MORE
      require(earlyPioneers.balanceOf(msg.sender) >= 1, "You must have at least 1 pioneer to stake");
      require(NFTs1155.balanceOf(msg.sender, _tokenId) >= 1, "You must have at least 1 tool to stake");

        // If they have a pickaxe already, send it back to them.
        if (axe[msg.sender].isStaked) {
            // Transfer using safeTransfer
            NFTs1155.safeTransferFrom(address(this), msg.sender, axe[msg.sender].id, 1, "Returning your old dirt");
        }
        // Transfer the axe to the contract
        NFTs1155.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "Staking your axe");
       
        // Update the dirt mapping
        axe[msg.sender].id = _tokenId;
        axe[msg.sender].isStaked = true;
        axe[msg.sender].stakingEndTime = block.timestamp + minStakingTime;
    }


    function withdrawAxe() external nonReentrant {
        // Ensure the player has an axe
        require(axe[msg.sender].isStaked, "You do not have an axe to withdraw.");
        require(block.timestamp > axe[msg.sender].stakingEndTime,"Can't withdraw before 1 week");

        //AT THE MOMENT WE JUST HAVE 2 TOOLS
        if (axe[msg.sender].id == 1){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,1,1,"");
        }else if (axe[msg.sender].id == 2){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,2,1,"");
        }else if (axe[msg.sender].id == 3){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,3,1,"");
        }else if (axe[msg.sender].id == 4){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,4,1,"");
        }else if (axe[msg.sender].id == 5){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,5,1,"");
        }else if (axe[msg.sender].id == 6){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,6,1,"");
        }

        // Send the axe back to the player
        NFTs1155.safeTransferFrom(address(this), msg.sender, axe[msg.sender].id, 1, "Returning your old axe");

        // Update the axe mapping
        axe[msg.sender].isStaked = false;

    }

    function claimDirt() external nonReentrant {

        //INTRODUCE ENERGY
        require(axe[msg.sender].isStaked, "Nothing staked");
    
        if (axe[msg.sender].id == 1){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,1,1,"");
        }else if (axe[msg.sender].id == 2){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,2,1,"");
        }else if (axe[msg.sender].id == 3){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,3,1,"");
        }else if (axe[msg.sender].id == 4){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,4,1,"");
        }else if (axe[msg.sender].id == 5){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,5,1,"");
        }else if (axe[msg.sender].id == 6){
        rewardsNFT.safeTransferFrom(address(this), msg.sender,6,1,"");
        }
    }        


   function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Receiver) returns (bool) {
        return(ERC1155Receiver.supportsInterface(interfaceId));
    }

    
  fallback() external payable{}

  receive() external payable{}
}