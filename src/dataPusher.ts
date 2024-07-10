import { ethers } from "ethers";
import { UrlData } from "./types";
import { oracleContract, provider } from "./provider";

const MAX_GAS_LIMIT = 5000000000; // Your blockchain's gas limit

export async function updateContract(urlDataArray: UrlData[]): Promise<void> {
    // Filter out data that is too large
    const validUrlDataArray = urlDataArray.filter(data => !data.sizeExceeded);
    const urls = validUrlDataArray.map(data => data.url);
    const data = validUrlDataArray.map(data => data.data);

    try {
        if (urls.length === 0) {
            console.log(`[INFO] No valid data to update the contract.`);
            return;
        }

        console.log(`\n[INFO] Preparing to update contract with data from:`);
        urls.forEach((url, index) => {
            console.log(`  - ${url}: ${data[index]}`);
        });

        const gasPrice = await provider.getGasPrice();
        const gasLimit = await oracleContract.estimateGas.updateDataBatch(urls, data);

        console.log(`[INFO] Estimated gas limit: ${gasLimit.toString()}`);
        console.log(`[INFO] Current gas price: ${ethers.utils.formatUnits(gasPrice, 'gwei')} gwei`);

        if (gasLimit.gt(MAX_GAS_LIMIT)) {
            console.log(`[INFO] Response is too big to store.`);
            return;
        }

        const tx = await oracleContract.updateDataBatch(urls, data, {
            gasLimit: gasLimit,
            gasPrice: gasPrice,
        });

        console.log(`[INFO] Transaction hash: ${tx.hash}`);
        const receipt = await tx.wait();
        console.log(`[INFO] Transaction confirmed in block: ${receipt.blockNumber}`);
        console.log(`[INFO] Gas used: ${receipt.gasUsed.toString()}`);
        console.log(`[INFO] Updated contract with data from:`);
        urls.forEach((url) => console.log(`  - ${url}`));
    } catch (error) {
        console.error(`[ERROR] Error updating contract with data from ${urls.join(", ")}:`, error);
    }
}
