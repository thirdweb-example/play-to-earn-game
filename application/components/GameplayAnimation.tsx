import React from "react";
import styles from "../styles/Gameplay.module.css";
import EditionDropMetadata from "../types/EditionDropMetadata";

const GoldGem = (
  <div className={styles.slide}>
    <img src="./gold-gem.png" height="48" width="48" alt="gold-gem" />
  </div>
);

type Props = {
  pickaxe: EditionDropMetadata | undefined;
};

export default function GameplayAnimation({ pickaxe }: Props) {
  if (!pickaxe) {
    return <div style={{ marginLeft: 8 }}>I need a pickaxe!</div>;
  }

  return (
    <div className={styles.slider}>
      <div className={styles.slideTrack}>
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
        {GoldGem}
      </div>
    </div>
  );
}
