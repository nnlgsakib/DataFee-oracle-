export const oracleAbi = [
    "function updateDataBatch(string[] memory _urls, string[] memory _data) public",
    "function addUrlElement(string memory _url, string memory _element) public",
    "function getUrlElement(string memory _url) public view returns (string memory)",
    "function getAllUrls() public view returns (string[] memory)",
    "function getAllUrlElements() public view returns (string[] memory, string[] memory)",
];