import { Web3Button } from "@thirdweb-dev/react";
import Image from "next/image";
import { CHARACTER_EDITION_ADDRESS } from "../const/contractAddresses";
import styles from "../styles/Home.module.css";

export default function MintContainer() {
  return (
    <div className={styles.collectionContainer}>
      <h1>Mint Your Land</h1>

      <p>You need a Land to Purchase Properties.</p>

      <div className={`${styles.nftBox} ${styles.spacerBottom}`}>
        <Image src="" style={{ height: 200 }} alt="mine" />
      </div>

      <div className={styles.smallMargin}>
        <Web3Button
          theme="dark"
          contractAddress={CHARACTER_EDITION_ADDRESS}
          action={(contract) => contract.erc1155.claim(0, 1)}
        >
          Purchase Land = 10 Matic
        </Web3Button>
      </div>
    </div>
  );
}
