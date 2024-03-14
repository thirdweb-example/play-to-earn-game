import {
  ThirdwebNftMedia,
  useActiveClaimCondition,
  Web3Button,
} from "@thirdweb-dev/react";
import { EditionDrop, NFT } from "@thirdweb-dev/sdk";
import { ethers } from "ethers";
import React from "react";
import { PICKAXE_EDITION_ADDRESS } from "../const/contractAddresses";
import styles from "../styles/Home.module.css";

type Props = {
  pickaxeContract: EditionDrop;
  item: NFT;
};

export default function ShopItem({ item, pickaxeContract }: Props) {
  const { data: claimCondition } = useActiveClaimCondition(
    pickaxeContract,
    item.metadata.id
  );

  return (
    <div className={styles.nftBox} key={item.metadata.id.toString()}>
      <ThirdwebNftMedia
        metadata={item.metadata}
        className={`${styles.nftMedia} ${styles.spacerTop}`}
        height="64"
      />
      <h3>{item.metadata.name}</h3>
      <p>
        Price:{" "}
        <b>
          {claimCondition && ethers.utils.formatUnits(claimCondition?.price)}{" "}
          GEM
        </b>
      </p>

      <div className={styles.smallMargin}>
        <Web3Button
          theme="dark"
          contractAddress={PICKAXE_EDITION_ADDRESS}
          action={(contract) => contract.erc1155.claim(item.metadata.id, 1)}
          onSuccess={() => alert("Purchased!")}
          onError={(error) => alert(error)}
        >
          Buy
        </Web3Button>
      </div>
    </div>
  );
}
