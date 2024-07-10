// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Oracle_v7 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct Data {
        string data;
        uint256 timestamp;
    }

    struct UrlElement {
        string defaultElement;
        bool exists;
    }

    // Nested mapping to store data for each element under each URL
    mapping(string => mapping(string => Data)) private dataStore;
    mapping(string => UrlElement) private urlElementStore;
    string[] private urlList;

    event DataUpdated(string url, string element, string data, uint256 timestamp);
    event UrlElementUpdated(string url, string element);
    event UrlElementDeleted(string url);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        transferOwnership(initialOwner);
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    // Update data for a specific element of a URL
    function updateData(string memory _url, string memory _element, string memory _data) public onlyOwner {
        Data storage data = dataStore[_url][_element];
        data.data = _data;
        data.timestamp = block.timestamp;
        emit DataUpdated(_url, _element, _data, block.timestamp);
    }

    // Update data for the default element of multiple URLs
    function updateDataBatch(string[] memory _urls, string[] memory _elements, string[] memory _data) public onlyOwner {
        require(_urls.length == _elements.length && _urls.length == _data.length, "Mismatched array lengths");
        for (uint256 i = 0; i < _urls.length; i++) {
            dataStore[_urls[i]][_elements[i]] = Data({
                data: _data[i],
                timestamp: block.timestamp
            });
            emit DataUpdated(_urls[i], _elements[i], _data[i], block.timestamp);
        }
    }

    // Retrieve data for the default element of a URL
    function getData(string memory _url) public view returns (string memory, uint256) {
        UrlElement memory urlElement = urlElementStore[_url];
        require(urlElement.exists, "URL does not exist");
        Data memory data = dataStore[_url][urlElement.defaultElement];
        return (data.data, data.timestamp);
    }

    // Add a new URL and set its default element
    function addUrlElement(string memory _url, string memory _element) public onlyOwner {
        if (!urlElementStore[_url].exists) {
            urlList.push(_url);
        }
        urlElementStore[_url] = UrlElement({defaultElement: _element, exists: true});
        emit UrlElementUpdated(_url, _element);
    }

    // Modify the default element for a URL
    function modifyUrlElement(string memory _url, string memory _newElement) public onlyOwner {
        require(urlElementStore[_url].exists, "URL does not exist");
        urlElementStore[_url].defaultElement = _newElement;
        emit UrlElementUpdated(_url, _newElement);
    }

    // Delete a URL and its data
    function deleteUrlElement(string memory _url) public onlyOwner {
        require(urlElementStore[_url].exists, "URL does not exist");
        delete urlElementStore[_url];
        emit UrlElementDeleted(_url);

        // Remove from urlList
        for (uint256 i = 0; i < urlList.length; i++) {
            if (keccak256(bytes(urlList[i])) == keccak256(bytes(_url))) {
                urlList[i] = urlList[urlList.length - 1];
                urlList.pop();
                break;
            }
        }

        // Delete all data associated with this URL
        for (uint256 i = 0; i < urlList.length; i++) {
            delete dataStore[_url][urlList[i]];
        }
    }

    // Get the default element for a specific URL
    function getUrlElement(string memory _url) public view returns (string memory) {
        UrlElement memory urlElement = urlElementStore[_url];
        require(urlElement.exists, "URL does not exist");
        return urlElement.defaultElement;
    }

    // Get all URLs
    function getAllUrls() public view returns (string[] memory) {
        return urlList;
    }

    // Get all URLs and their default elements
    function getAllUrlElements() public view returns (string[] memory, string[] memory) {
        uint256 count = urlList.length;
        string[] memory urls = new string[](count);
        string[] memory elements = new string[](count);

        for (uint256 i = 0; i < count; i++) {
            urls[i] = urlList[i];
            elements[i] = urlElementStore[urlList[i]].defaultElement;
        }

        return (urls, elements);
    }
}