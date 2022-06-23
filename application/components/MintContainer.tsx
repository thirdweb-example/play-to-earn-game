import {
  ThirdwebNftMedia,
  useAddress,
  useClaimNFT,
  useEditionDrop,
} from "@thirdweb-dev/react";
import React from "react";
import { CHARACTER_EDITION_ADDRESS } from "../const/contractAddresses";
import styles from "../styles/Home.module.css";

export default function MintContainer() {
  const editionDrop = useEditionDrop(CHARACTER_EDITION_ADDRESS);
  const { mutate: claim, isLoading } = useClaimNFT(editionDrop);
  const address = useAddress();

  return (
    <div className={styles.collectionContainer}>
      <h1>Edition Drop</h1>

      <p>Claim your Character NFT to start playing!</p>

      <div className={`${styles.nftBox} ${styles.spacerBottom}`}>
        <img src="./mine.gif" style={{ height: 200 }} />
      </div>

      <button
        className={`${styles.mainButton} ${styles.spacerBottom}`}
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
