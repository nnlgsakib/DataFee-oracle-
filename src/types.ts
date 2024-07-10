// Assuming this is your types.ts file

export interface UrlElement {
    url: string;
    element?: string;
}

export interface UrlData {
    url: string;
    data: string;
    sizeExceeded?: boolean; // Add this line
}
