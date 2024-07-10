import axios from "axios";
import { UrlElement, UrlData } from "./types";
import { flattenObject } from "./flattener";

const MAX_DATA_SIZE = 5000; // Set a reasonable threshold for the maximum size of data

export async function fetchData(urlElement: UrlElement): Promise<UrlData> {
    console.log(`\n[INFO] Fetching data from ${urlElement.url}`);
    try {
        const response = await axios.get(urlElement.url);
        let data: string;

        if (urlElement.element) {
            const elementValue = response.data[urlElement.element];
            if (typeof elementValue === 'object') {
                const flattenedData = flattenObject(elementValue);
                data = Object.entries(flattenedData)
                    .map(([key, value]) => `${key}:${value}`)
                    .join(" ");
            } else {
                data = `${urlElement.element}:${elementValue}`;
            }
        } else {
            const flattenedData = flattenObject(response.data);
            data = Object.entries(flattenedData)
                .map(([key, value]) => `${key}:${value}`)
                .join(" ");
        }

        if (data.length <= MAX_DATA_SIZE) {
            console.log(`[INFO] Fetched data from ${urlElement.url}: ${data}`);
            return { url: urlElement.url, data, sizeExceeded: false };
        } else {
            console.log(`[INFO] Data fetched from ${urlElement.url} is too big to log.`);
            return { url: urlElement.url, data: "", sizeExceeded: true };
        }
    } catch (error: any) {
        if (error.response) {
            // Server responded with a status other than 2xx
            console.error(`[ERROR] ${urlElement.url} responded with status ${error.response.status}: ${error.response.statusText}`);
        } else if (error.request) {
            // Request was made but no response received
            console.error(`[ERROR] No response received from ${urlElement.url}. The API might be offline.`);
        } else {
            // Something else happened while setting up the request
            console.error(`[ERROR] Error setting up request to ${urlElement.url}: ${error.message}`);
        }
        throw error;
    }
}
