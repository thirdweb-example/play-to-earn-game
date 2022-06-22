import {
  ThirdwebNftMedia,
  useAddress,
  useMetadata,
  useTokenBalance,
} from "@thirdweb-dev/react";
import { SmartContract, Token } from "@thirdweb-dev/sdk";
import { BigNumber, ethers } from "ethers";
import React, { useEffect, useState } from "react";

import styles from "../styles/Home.module.css";
import ApproxRewards from "./ApproxRewards";

type Props = {
  miningContract: SmartContract<any>;
  tokenContract: Token;
};

/**
 * This component shows the:
 * - Metadata of the token itself (mainly care about image)
 * - The amount this wallet holds of this wallet
 * - The amount this user can claim from the mining contract
 */
export default function Rewards({ miningContract, tokenContract }: Props) {
  const address = useAddress();

  const { data: tokenMetadata } = useMetadata(tokenContract);
  const { data: currentBalance } = useTokenBalance(tokenContract, address);

  const [unclaimedAmount, setUnclaimedAmount] = useState<BigNumber>();

  useEffect(() => {
    (async () => {
      if (!address) return;

      const u = await miningContract.call("calculateRewards", address);
      setUnclaimedAmount(u);
    })();
  }, [address, miningContract]);

  async function claim() {
    if (!address) return;

    await miningContract.call("claim");
  }

  return (
    <div
      style={{ display: "flex", flexDirection: "column", alignItems: "center" }}
    >
      <p>
        Your <b>Gold Gems</b>
      </p>

      {tokenMetadata && (
        <ThirdwebNftMedia
          // @ts-ignore
          metadata={tokenMetadata}
          height={"48"}
        />
      )}
      <p className={styles.noGapBottom}>
        Balance: <b>{currentBalance?.displayValue}</b>
      </p>
      <p>
        Unclaimed:{" "}
        <b>{unclaimedAmount && ethers.utils.formatUnits(unclaimedAmount)}</b>
      </p>

      <ApproxRewards miningContract={miningContract} />

      <button
        onClick={() => claim()}
        className={`${styles.mainButton} ${styles.spacerBottom}`}
      >
        Claim
      </button>
    </div>
  );
}
