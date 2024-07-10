// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Oracle_v8 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct Data {
        string data;
        uint256 timestamp;
    }

    struct UrlElement {
        string defaultElement;
        bool exists;
    }

    mapping(bytes32 => Data) private dataStore; // Use bytes32 key for efficient storage
    mapping(string => UrlElement) private urlElementStore;
    string[] private urlList;

    event DataUpdated(string url, string element, string data, uint256 timestamp);
    event UrlElementUpdated(string url, string element);
    event UrlElementDeleted(string url);

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
        transferOwnership(initialOwner);
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    function _getKey(string memory _url, string memory _element) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_url, _element));
    }

    function updateData(string memory _url, string memory _element, string memory _data) public onlyOwner {
        bytes32 key = _getKey(_url, _element);
        dataStore[key] = Data({
            data: _data,
            timestamp: block.timestamp
        });
        emit DataUpdated(_url, _element, _data, block.timestamp);
    }

    function updateDataBatch(string[] memory _urls, string[] memory _elements, string[] memory _data) public onlyOwner {
        require(_urls.length == _elements.length && _urls.length == _data.length, "Mismatched array lengths");
        for (uint256 i = 0; i < _urls.length; i++) {
            bytes32 key = _getKey(_urls[i], _elements[i]);
            dataStore[key] = Data({
                data: _data[i],
                timestamp: block.timestamp
            });
            emit DataUpdated(_urls[i], _elements[i], _data[i], block.timestamp);
        }
    }

    function getData(string memory _url, string memory _element) public view returns (string memory, uint256) {
        bytes32 key = _getKey(_url, _element);
        Data memory data = dataStore[key];
        return (data.data, data.timestamp);
    }

    function addUrlElement(string memory _url, string memory _element) public onlyOwner {
        if (!urlElementStore[_url].exists) {
            urlList.push(_url);
        }
        urlElementStore[_url] = UrlElement({defaultElement: _element, exists: true});
        emit UrlElementUpdated(_url, _element);
    }

    function modifyUrlElement(string memory _url, string memory _newElement) public onlyOwner {
        require(urlElementStore[_url].exists, "URL does not exist");
        urlElementStore[_url].defaultElement = _newElement;
        emit UrlElementUpdated(_url, _newElement);
    }

    function deleteUrlElement(string memory _url) public onlyOwner {
        require(urlElementStore[_url].exists, "URL does not exist");
        delete urlElementStore[_url];
        emit UrlElementDeleted(_url);

        for (uint256 i = 0; i < urlList.length; i++) {
            if (keccak256(bytes(urlList[i])) == keccak256(bytes(_url))) {
                urlList[i] = urlList[urlList.length - 1];
                urlList.pop();
                break;
            }
        }

        for (uint256 i = 0; i < urlList.length; i++) {
            bytes32 key = _getKey(_url, urlList[i]);
            delete dataStore[key];
        }
    }

    function getUrlElement(string memory _url) public view returns (string memory) {
        UrlElement memory urlElement = urlElementStore[_url];
        require(urlElement.exists, "URL does not exist");
        return urlElement.defaultElement;
    }

    function getAllUrls() public view returns (string[] memory) {
        return urlList;
    }

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
