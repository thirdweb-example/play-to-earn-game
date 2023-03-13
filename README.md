# thirdweb Play-to-Earn Example

This example project is a simple Play-to-Earn (P2E) game!

## The Idea

The game is a "mining" game, where your character mines for gold gems!

In the beginning, you start out with nothing! In order to play the game, you need to:

1. Mint your character NFT (ERC-1155 using the [Edition Drop](https://portal.thirdweb.com/pre-built-contracts/edition-drop) contract)
2. Purchase a pickaxe NFT from the "Shop" (Another ERC-1155 using an [Edition Drop](https://portal.thirdweb.com/pre-built-contracts/edition-drop) contract)
3. "Equip" (stake) the pickaxe NFT in the [Mining](./contracts/contracts/Mining.sol) contract (built with [thirdweb deploy](https://portal.thirdweb.com/thirdweb-deploy))
4. Start earning "Gold Gems"; ERC-20 tokens (using the [Token](https://portal.thirdweb.com/pre-built-contracts/token) contract)

<!-- Image of miner -->
<img src='./application/public/mine.gif' height='48'>
<img src='./application/public/pickaxe.png'  height='48'>
<img src='./application/public/gold-gem.png' height='48'>

You can use the GEMs you earn to purchase higher tier pickaxes, which will increase your rewards per block.

```js
( 0 + 1 ) * 10_000_000_000_000 / 100_000_000_000_000_000  gold gems per block.
```

Once you have earned enough GEM tokens, you can use them to purchase higher tier pickaxes.

For example, when you buy the "Stone Hammer" (token ID `1`) for 10 GEMs, you will earn:

```js
// 1 (Token ID of stone hammer) + 1 = Rewards Multiplier
// 10_000_000_000_000 / 100_000_000_000_000_000 = The number of GEMs rewarded per block (since the token has 18 decimals)
( 1 + 1 ) * 10_000_000_000_000 / 100_000_000_000_000_000 gold gems per block.
```

**Check out the Demo here**: https://play-to-earn.thirdweb-example.com/

## Using this Example

You can create your own copy of this project by running the following command:

```bash
npx thirdweb create --template play-to-earn
```

Inside the [contractAddresses](./application/const/contractAddresses.ts) file, you can change the contract addresses to your own contracts.

This project uses 4 contracts built with thirdweb:

| Name      | Contract Type            | Description                    | Link                                                                                                                        |
| --------- | ------------------------ | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Gold Gems | Token (ERC-20)           | Gold Gems Rewards Token        | [View on thirdweb dashboard](https://thirdweb.com/dashboard/mumbai/token/0x18B18e5D2375c592997e1eaFf6C77A6bd24F5c44)        |
| Pickaxes  | Edition Drop (ERC-1155)  | Pickaxe NFTs                   | [View on thirdweb dashboard](https://thirdweb.com/dashboard/mumbai/edition-drop/0x9d33597aD43bE6295Fe7626baDBF72B862F71bB2) |
| Miners    | Edition Drop (ERC-1155)  | Character NFTs                 | [View on thirdweb dashboard](https://thirdweb.com/dashboard/mumbai/edition-drop/0x16A131b7e5a62E8fe83f0993aAF2ECCaBF519382) |
| Mining    | Custom (thirdweb deploy) | Staking and rewarding contract | [View on thirdweb dashboard](https://thirdweb.com/dashboard/mumbai/0x90E438ba4Bf62573FEC13F792F051E8c96C41636/)             |

Learn how to deploy and configure these contracts using the thirdweb portal documentation:

- [Edition Drop](https://portal.thirdweb.com/pre-built-contracts/edition-drop)
- [Token](https://portal.thirdweb.com/pre-built-contracts/token)
- [thirdweb deploy](https://portal.thirdweb.com/thirdweb-deploy)

## Guide

Below, you can find an explanation of the key areas of the project and code snippets explained!

### Project Structure

The project is divided into two parts:

1. The [application](./application) folder contains the code for the front-end of the application.

2. The [contracts](./contracts) folder contains our smart contract set up, including our [Mining](./contracts/contracts/Mining.sol) contract. We're using [Hardhat](https://hardhat.ethereum.org/) so that we can write tests or scripts to interact with the smart contracts locally.

### Deploying the Mining Contract

We can deploy the `Mining` contract using [thirdweb deploy](https://portal.thirdweb.com/thirdweb-deploy)!

```bash
# Change to the contracts folder
cd contracts

# Deploy the Mining contract
npx thirdweb deploy
```

### Mining Contract Explained

The way that the game works is by staking a "pickaxe" NFT into the Mining contract.

Then, the contract uses `block.timestamp` to calculate the player's reward.

The reward logic is calculated as follows:

```js
// blocks passed since last payout * reward multiplier * rewards per block
```

```solidity
function calculateRewards(address _player)
    public
    view
    returns (uint256 _rewards)
{
    // If playerLastUpdate or playerPickaxe is not set, then the player has no rewards.
    if (!playerLastUpdate[_player].isData || !playerPickaxe[_player].isData) {
        return 0;
    }

    // Calculate the time difference between now and the last time they staked/withdrew/claimed their rewards
    uint256 timeDifference = block.timestamp - (playerLastUpdate[_player].value + 1);

    // Calculate the rewards they are owed
    uint256 rewards = timeDifference * 10_000_000_000_000 * playerPickaxe[_player].value;

    // Return the rewards
    return rewards;
}
```

`rewards` uses the Token ID of the staked pickaxe NFT as the rewards multiplier.

In order to keep track of this information, we have two mappings:

```solidity
struct MapValue {
    bool isData;
    uint256 value;
}

mapping (address => MapValue) public playerPickaxe;

mapping (address => MapValue) public playerLastUpdate;
```

1. `playerPickaxe`: This mapping tracks the current pickaxe (token ID of the NFT) that the player has staked.

2. `playerLastUpdate`: This mapping tracks the last time that the player was paid out their rewards.

When the contract is created, we pass in the values of the other contracts we created:

1. The Pickaxe Edition Drop contract
2. The Gold Gems Token contract

```solidity
// Store our two other contracts here (Edition Drop and Token)
DropERC1155 public immutable pickaxeNftCollection;
TokenERC20 public immutable rewardsToken;

// Constructor function to set the rewards token and the NFT collection addresses
constructor(DropERC1155 pickaxeContractAddress, TokenERC20 gemsContractAddress) {
    pickaxeNftCollection = pickaxeContractAddress;
    rewardsToken = gemsContractAddress;
}
```

This allows us to do things like check if the player has a specific NFT, and transfer tokens to and from the contract.

Now, there are three key functions in the contract.

1. Stake (send pickaxe to the contract)
2. Withdraw (get pickaxe back from the contract)
3. Claimed (pay out the player's rewards)

**Stake**

- `safeTransferFrom`'s the pickaxe the player currently has staked back to them.
- `calculateRewards` and `transfer`'s the player's rewards to them.
- `safeTransferFrom`'s the pickaxe they are staking from the player to the contract.
- Updates the mappings accordingly.

**Withdraw**

- `calculateRewards` and `transfer`'s the player's rewards to them.
- `safeTransferFrom`'s the pickaxe the player currently has staked back to them.
- Updates the mappings accordingly.

**Claim**

- `calculateRewards` and `transfer`'s the player's rewards to them.
- Updates the mappings accordingly.

---

## Application

The application interacts with all `4` of the contracts we created by using the thirdweb SDK.

You can learn more about the thirdweb SDK's here:

- [React](https://portal.thirdweb.com/react)
- [TypeScript](https://portal.thirdweb.com/typescript)

### Connecting to Wallets

To allow users to interact with our contracts and make transactions, we need to connect to their wallets. Firstly, we wrap our application in the `ThirdwebProvider`:

```tsx
function MyApp({ Component, pageProps }: AppProps) {
  return (
    <ThirdwebProvider activeChain="mumbai">
      <Component {...pageProps} />
    </ThirdwebProvider>
  );
}
```

Which allows us to use any of the React SDK's hooks in our application!

On the [index.tsx](./application/pages/index.tsx) page, we use [useMetamask](https://portal.thirdweb.com/react/react.usemetamask) and [useAddress](https://portal.thirdweb.com/react/react.useaddress) to connect and read to the user's wallet.

```tsx
const connectWithMetamask = useMetamask();
const address = useAddress();
```

The logic on the homepage is:

1. Load the user's owned NFTs from the `Miners` NFT contract to see if they have a character NFT already.

```tsx
const {
  data: ownedNfts,
  isLoading,
  isError,
} = useOwnedNFTs(editionDrop, address);
```

2. If they have a character, show them the `Play Game` button.

3. If they don't have a character, show them the `Claim` button, allowing them to claim an NFT from our Edition Drop contract:

```tsx
export default function MintContainer() {
  const editionDrop = useEditionDrop(CHARACTER_EDITION_ADDRESS);
  const { mutate: claim, isLoading } = useClaimNFT(editionDrop);
  const address = useAddress();

  return (
    <div className={styles.collectionContainer}>
      <h1>Edition Drop</h1>
      <button
        onClick={() =>
          claim({
            quantity: 1,
            to: address as string,
            tokenId: 0,
          })
        }
      >
        {isLoading ? "Loading..." : "Claim"}
      </button>
    </div>
  );
}
```

Once they have claimed their character, they can play the game.

The logic of the game page is on the [play](./application/pages/play.tsx) page.

### The Play Page

The role of this page is to connect to all of the contracts and pass this information down to a set of components.

Firstly, we connect to all of our contracts:

```tsx
const { contract: miningContract } = useContract(MINING_CONTRACT_ADDRESS);
const characterContract = useEditionDrop(CHARACTER_EDITION_ADDRESS);
const pickaxeContract = useEditionDrop(PICKAXE_EDITION_ADDRESS);
const tokenContract = useToken(GOLD_GEMS_ADDRESS);
```

There are several components that show different information and pull data from the contracts.

1. [CurrentGear Component](./application/components/CurrentGear.tsx) - Shows the owned character NFT and currently staked pickaxe
2. [Rewards Component](./application/components/Rewards.tsx) - Shows the available rewards in the mining contract, the balance of the connected wallet, and a client-side estimation of the rewards they have earnt since they loaded the page in this session.
3. [OwnedGear Component](./application/components/OwnedGear.tsx) - Shows the owned pickaxes the wallet has and an "Equip" button to stake it.
4. [Shop Component](./application/components/Shop.tsx) - Shows all of the pickaxes in the Pickaxe Edition Drop contract, the price for each, and a "Buy" button to claim it.

### Current Gear

**Contracts Used in this Component**:

- **Mining Contract** - View the currently staked pickaxe
- **Character Contract** - View the metadata of the character NFT
- **Pickaxe Contract** - View the metadata of the staked pickaxe token

This component simply shows the user the character NFT they own, the pickaxe they currently have staked, and an animation of the character "mining".

It looks like this:

![Current Gear Preview](https://cdn.hashnode.com/res/hashnode/image/upload/v1655947595125/-iVRlmtNi.png)

To get the metadata of the character NFT:

```tsx
// Since we only have 1 character of token ID 0, it's quite easy to get the metadata.
const { data: playerNft } = useNFT(characterContract, 0);
```

To get the staked pickaxe:

```tsx
// playerPickaxe is the name of the mapping we created in the contract.
// It maps walletAddress -> staked token ID.
const p = (await miningContract.call(
  "playerPickaxe",
  address
)) as ContractMappingResponse;
```

To get the metadata of the staked pickaxe:

```tsx
// Here, p.value is the token ID.
const pickaxeMetadata = await pickaxeContract.get(p.value);
```

### Rewards

**Contracts Used in this Component**:

- **Mining Contract** - View the available rewards of the connected wallet
- **Token Contract** - View token metadata and balance of connected wallet

This component shows:

- The metadata of the rewards token (name and image)
- The balance of the connected wallet of the token
- The "unclaimed" rewards the user can claim from the connected wallet
- A client-side estimation of the rewards the user has earned since they loaded the page in this session

It looks like this:

<div align='center'>

![Rewards Component](https://cdn.hashnode.com/res/hashnode/image/upload/v1655947877637/6iVmVzMfd.png)

</div>

To get the metadata of the token:

```tsx
const { data: tokenMetadata } = useMetadata(tokenContract);
```

To get the balance of the connected wallet:

```tsx
const address = useAddress();
const { data: currentBalance } = useTokenBalance(tokenContract, address);
```

To get the "unclaimed" rewards:

```tsx
const u = await miningContract.call("calculateRewards", address);
```

To claim the rewards from the contract:

```tsx
await miningContract.call("claim");
```

There is a fun little component within this one caled [ApproxRewards](./application/components/ApproxRewards.tsx) that estimates the rewards that have been earnt during this session. \_It's probably not that accurate, it just looks pretty cool! It:

- Reads the token ID of the currently staked pickaxe
- Multiplies it by the rewards amount `10_000_000_000_000`
- Multiplies this amount by the amount of time that this sessino has been running

### Owned Gear

**Contracts Used in this Component**:

- **Pickaxe Contract** - View all of the owned pickaxes from the Pickaxe Edition Drop contract
- **Mining Contract** - To stake a selected pickaxe

This component shows the user the NFTs that they own from the pickaxe edition drop contract, and allows them to stake/equip them.

It looks like this:

![Rewards Component](https://cdn.hashnode.com/res/hashnode/image/upload/v1655949865562/MLp4NsEew.png)

To view all of their owned pickaxes:

```tsx
const address = useAddress();
const { data: ownedPickaxes, isLoading } = useOwnedNFTs(
  pickaxeContract,
  address
);
```

Map / Display each using the [`ThirdwebNftMedia`](https://portal.thirdweb.com/react/react.thirdwebnftmedia) component to display the metadata:

```tsx
return (
  <div>
    {ownedPickaxes?.map((p) => (
      <div key={p.metadata.id.toString()}>
        <ThirdwebNftMedia metadata={p.metadata} />
        <h3>{p.metadata.name}</h3>

        <button onClick={() => equip(p.metadata.id)}>Equip</button>
      </div>
    ))}
  </div>
);
```

To stake/"equip" a pickaxe:

Since our contract attempts to transfer tokens from the wallet to the contract, we need to provide the contract approval to do so, before calling the `stake` function

```tsx
async function equip(id: BigNumber) {
  if (!address) return;

  // The contract requires approval to be able to transfer the pickaxe
  const hasApproval = await pickaxeContract.isApproved(
    address,
    MINING_CONTRACT_ADDRESS
  );

  if (!hasApproval) {
    await pickaxeContract.setApprovalForAll(MINING_CONTRACT_ADDRESS, true);
  }

  await miningContract.call("stake", id);
}
```

At this point, the page reloads and the user's character will start "mining", and earning rewards!

### Shop

**Contracts Used in this Component**:

- **Pickaxe Contract** - View all of the pickaxes available in the Pickaxe Edition Drop contract

The shop is a component that maps over all of the NFTs inside the Pickaxe Edition Drop contract, and displays them, including a "Buy" button for each; allowing the user to claim the NFT for a price (in GEMs).

It looks like this:

![Rewards Component](https://cdn.hashnode.com/res/hashnode/image/upload/v1655949917550/en2h7OUda.png)

The price for each pickaxe NFT is configured with the drop's [claim phases](https://portal.thirdweb.com/pre-built-contracts/edition-drop#setting-claim-phases).

The claim phases allows us to use our GEMs token as the currency for the NFT.

To display all of the pickaxes in the contract:

```tsx
export default function Shop({ pickaxeContract }: Props) {
  const { data: availablePickaxes } = useNFTs(pickaxeContract);

  return (
    <>
      <div className={styles.nftBoxGrid}>
        {availablePickaxes?.map((p) => (
          <ShopItem
            pickaxeContract={pickaxeContract}
            item={p}
            key={p.metadata.id.toString()}
          />
        ))}
      </div>
    </>
  );
}
```

Since the price information is inside the claim phases, we map them out into a `ShopItem` component, which fetches the claim phase information for each item:

```tsx
const { data: claimCondition } = useActiveClaimCondition(
  pickaxeContract,
  item.metadata.id
);
```

To claim a pickaxe NFT:

```tsx
const { mutate: claimNft } = useClaimNFT(pickaxeContract);
```

```tsx
async function buy(id: BigNumber) {
  if (!address) return;

  try {
    claimNft({
      to: address,
      tokenId: id,
      quantity: 1,
    });
  } catch (e) {
    console.error(e);
    alert("Something went wrong. Are you sure you have enough tokens?");
  }
}
```

### Art Creators

_The art used in this project is used under the CC-0 license._

That said, we want to credit the awesome artists for their work:

- Pirate Bomb by pixelfrog: https://pixelfrog-assets.itch.io/pirate-bomb
- RPG Item Pack by alexs-assets: https://alexs-assets.itch.io/16x16-rpg-item-pack-2
- Gold Gem by Davit Masia - https://kronbits.itch.io/matriax-free-assets

## Join our Discord!

For any questions, suggestions, join our discord at [https://discord.gg/thirdweb](https://discord.gg/thirdweb).
