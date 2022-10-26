// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

// Import thirdweb contracts
import "@thirdweb-dev/contracts/drop/DropERC1155.sol"; // For my collection of Pickaxes
import "@thirdweb-dev/contracts/token/TokenERC20.sol"; // For my ERC-20 Token contract
import "@thirdweb-dev/contracts/openzeppelin-presets/utils/ERC1155/ERC1155Holder.sol";

// OpenZeppelin (ReentrancyGuard)
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Mining is ReentrancyGuard, ERC1155Holder {
    // Store our two other contracts here (Edition Drop and Token)
    DropERC1155 public immutable pickaxeNftCollection;
    TokenERC20 public immutable rewardsToken;

    // Constructor function to set the rewards token and the NFT collection addresses
    constructor(
        DropERC1155 pickaxeContractAddress,
        TokenERC20 gemsContractAddress
    ) {
        pickaxeNftCollection = pickaxeContractAddress;
        rewardsToken = gemsContractAddress;
    }

    struct MapValue {
        bool isData;
        uint256 value;
    }

    // Mapping of player addresses to their current pickaxe
    // By default, player has no pickaxe. They will not be in the mapping.
    // Mapping of address to pickaxe is not set until they stake a one.
    // In this example, the tokenId of the pickaxe is the multiplier for the reward.
    mapping(address => MapValue) public playerPickaxe;

    // Mapping of player address until last time they staked/withdrew/claimed their rewards
    // By default, player has no last time. They will not be in the mapping.
    mapping(address => MapValue) public playerLastUpdate;

    function stake(uint256 _tokenId) external nonReentrant {
        // Ensure the player has at least 1 of the token they are trying to stake
        require(
            pickaxeNftCollection.balanceOf(msg.sender, _tokenId) >= 1,
            "You must have at least 1 of the pickaxe you are trying to stake"
        );

        // If they have a pickaxe already, send it back to them.
        if (playerPickaxe[msg.sender].isData) {
            // Transfer using safeTransfer
            pickaxeNftCollection.safeTransferFrom(
                address(this),
                msg.sender,
                playerPickaxe[msg.sender].value,
                1,
                "Returning your old pickaxe"
            );
        }

        // Calculate the rewards they are owed, and pay them out.
        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.transfer(msg.sender, reward);

        // Transfer the pickaxe to the contract
        pickaxeNftCollection.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            1,
            "Staking your pickaxe"
        );

        // Update the playerPickaxe mapping
        playerPickaxe[msg.sender].value = _tokenId;
        playerPickaxe[msg.sender].isData = true;

        // Update the playerLastUpdate mapping
        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }

    function withdraw() external nonReentrant {
        // Ensure the player has a pickaxe
        require(
            playerPickaxe[msg.sender].isData,
            "You do not have a pickaxe to withdraw."
        );

        // Calculate the rewards they are owed, and pay them out.
        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.transfer(msg.sender, reward);

        // Send the pickaxe back to the player
        pickaxeNftCollection.safeTransferFrom(
            address(this),
            msg.sender,
            playerPickaxe[msg.sender].value,
            1,
            "Returning your old pickaxe"
        );

        // Update the playerPickaxe mapping
        playerPickaxe[msg.sender].isData = false;

        // Update the playerLastUpdate mapping
        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }

    function claim() external nonReentrant {
        // Calculate the rewards they are owed, and pay them out.
        uint256 reward = calculateRewards(msg.sender);
        rewardsToken.transfer(msg.sender, reward);

        // Update the playerLastUpdate mapping
        playerLastUpdate[msg.sender].isData = true;
        playerLastUpdate[msg.sender].value = block.timestamp;
    }

    // ===== Internal ===== \\

    // Calculate the rewards the player is owed since last time they were paid out
    // The rewards rate is 20,000,000 per block.
    // This is calculated using block.timestamp and the playerLastUpdate.
    // If playerLastUpdate or playerPickaxe is not set, then the player has no rewards.
    function calculateRewards(address _player)
        public
        view
        returns (uint256 _rewards)
    {
        // If playerLastUpdate or playerPickaxe is not set, then the player has no rewards.
        if (
            !playerLastUpdate[_player].isData || !playerPickaxe[_player].isData
        ) {
            return 0;
        }

        // Calculate the time difference between now and the last time they staked/withdrew/claimed their rewards
        uint256 timeDifference = block.timestamp -
            playerLastUpdate[_player].value;

        // Calculate the rewards they are owed
        uint256 rewards = timeDifference *
            10_000_000_000_000 *
            (playerPickaxe[_player].value + 1);

        // Return the rewards
        return rewards;
    }
}
