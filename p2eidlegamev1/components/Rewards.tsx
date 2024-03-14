import React from "react";
import {
  ThirdwebNftMedia,
  useAddress,
  useContractRead,
  useMetadata,
  useTokenBalance,
  Web3Button,
} from "@thirdweb-dev/react";
import { SmartContract, Token } from "@thirdweb-dev/sdk";
import { ethers } from "ethers";

import styles from "../styles/Home.module.css";
import ApproxRewards from "./ApproxRewards";
import { MINING_CONTRACT_ADDRESS } from "../const/contractAddresses";

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
  const { data: unclaimedAmount } = useContractRead(
    miningContract,
    "calculateRewards",
    [address]
  );

  return (
    <div
      style={{ display: "flex", flexDirection: "column", alignItems: "center" }}
    >
      <p>
        Your <b>Gold Gems</b>
      </p>

      {tokenMetadata ? (
        <ThirdwebNftMedia
          // @ts-ignore
          metadata={tokenMetadata}
          height={"48"}
        />
      ) : null}
      <p className={styles.noGapBottom}>
        Balance: <b>{currentBalance?.displayValue}</b>
      </p>
      <p>
        Unclaimed:{" "}
        <b>{unclaimedAmount && ethers.utils.formatUnits(unclaimedAmount)}</b>
      </p>

      <ApproxRewards miningContract={miningContract} />

      <div className={styles.smallMargin}>
        <Web3Button
          contractAddress={MINING_CONTRACT_ADDRESS}
          action={(contract) => contract.call("claim")}
        >
          Claim
        </Web3Button>
      </div>
    </div>
  );
}
