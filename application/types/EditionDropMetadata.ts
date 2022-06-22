import { Json } from "@thirdweb-dev/sdk";
import { BigNumber } from "ethers";

type EditionDropMetadata = {
  metadata: {
    [x: string]: Json;
  };
  supply: BigNumber;
};

export default EditionDropMetadata;
