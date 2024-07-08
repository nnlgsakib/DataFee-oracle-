import { fetchData } from "./src/fetchData";
import { UrlData } from "./src/types";
import { urlElements } from "./src/url";
import { updateContract } from "./src/dataPusher";
async function main() {
    while (true) {
        const urlDataArray: UrlData[] = [];
        for (const urlElement of urlElements) {
            try {
                const urlData = await fetchData(urlElement);
                urlDataArray.push(urlData);
            } catch (error) {
                console.error(`[ERROR] Error processing URL ${urlElement.url}:`, error);
            }
        }
        if (urlDataArray.length > 0) {
            await updateContract(urlDataArray);
        }
        await new Promise((resolve) => setTimeout(resolve, 60000)); // Wait for 1 minute
    }
}

main().catch((error) => {
    console.error("[ERROR] Error in main function:", error);
});