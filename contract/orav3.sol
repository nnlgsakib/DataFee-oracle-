// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Oracle_v3 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct Data {
        string data;
        uint256 timestamp;
    }

    mapping(string => Data) private dataStore;

    event DataUpdated(string url, string data, uint256 timestamp);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        transferOwnership(initialOwner);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function updateData(string memory _url, string memory _data) public onlyOwner {
        Data storage data = dataStore[_url];
        data.data = _data;
        data.timestamp = block.timestamp;
        emit DataUpdated(_url, _data, block.timestamp);
    }
     function updateDataBatch(string[] memory _urls, string[] memory _data) public onlyOwner {
        require(_urls.length == _data.length, "Mismatched array lengths");
        for (uint256 i = 0; i < _urls.length; i++) {
            dataStore[_urls[i]] = Data({
                data: _data[i],
                timestamp: block.timestamp
            });
            emit DataUpdated(_urls[i], _data[i], block.timestamp);
        }
    }

    function getData(string memory _url) public view returns (string memory, uint256) {
        Data memory data = dataStore[_url];
        return (data.data, data.timestamp);
    }
}
