import { oracleContract } from "./provider";
import { UrlElement } from "./types";
export async function fetchUrlElements(): Promise<UrlElement[]> {
    const [urls, elements] = await oracleContract.getAllUrlElements();
    const urlElements: UrlElement[] = [];
    for (let i = 0; i < urls.length; i++) {
        urlElements.push({ url: urls[i], element: elements[i] });
    }
    return urlElements;
}