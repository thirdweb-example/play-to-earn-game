import { useNFTs } from "@thirdweb-dev/react";
import { EditionDrop } from "@thirdweb-dev/sdk";
import React from "react";
import styles from "../styles/Home.module.css";
import ShopItem from "./ShopItem";

type Props = {
  pickaxeContract: EditionDrop;
};

/**
 * This component shows the:
 * - All of the available pickaxes from the edition drop and their price.
 */
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
