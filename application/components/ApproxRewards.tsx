import { ethers } from "ethers";
import React, { useEffect, useState } from "react";

type Props = {};

// This component gives a very rough estimation of how many tokens have been earned in the current session
// Assuming there is a block every 2.1 seconds on Polygon, and the rewards of gwei is 20_000_000 per block
// The total amount of tokens earned is:
// 20_000_000 * 2.1 * blocks_in_session
// This is a rough estimation of how many tokens have been earned in the current session

export default function ApproxRewards({}: Props) {
  // We can kick off a timer when this component is mounted
  // Each 2.1 seconds, we can update the amount of tokens earned
  // This is a rough estimation of how many tokens have been earned in the current session

  const everyMillisecondAmount = parseInt((20000000 / 2.1).toFixed(0));

  const [amount, setAmount] = useState<number>(0);

  useEffect(() => {
    // set interval counter
    const interval = setInterval(() => {
      // update the amount of tokens earned
      setAmount(amount + everyMillisecondAmount);
    }, 100);
    // clear interval when component unmounts
    return () => clearInterval(interval);
  }, [amount, everyMillisecondAmount]);

  return (
    <p style={{ width: 370, overflow: "hidden" }}>
      Earned this session: <b>{ethers.utils.formatEther(amount)}</b>
    </p>
  );
}
