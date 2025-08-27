// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SimpleStorage {
    // 存储的数据
    uint256 private storedData;
    address public owner;

    // 事件
    event DataStored(
        address indexed user,
        uint256 indexed oldValue,
        uint256 indexed newValue,
        uint256 timestamp
    );
    event DataRetrieved(
        address indexed user,
        uint256 indexed value,
        uint256 timestamp
    );

    constructor() {
        owner = msg.sender;
        storedData = 0;
    }

    // 存储数据
    function store(uint256 _data) public {
        uint256 oldValue = storedData;
        storedData = _data;
        emit DataStored(msg.sender, oldValue, _data, block.timestamp);
    }

    // 获取数据
    function retrieve() public returns (uint256) {
        emit DataRetrieved(msg.sender, storedData, block.timestamp);
        return storedData;
    }

    // 只读获取数据（不触发事件）
    function get() public view returns (uint256) {
        return storedData;
    }

    // 获取合约信息
    function getContractInfo() public view returns (address, uint256, uint256) {
        return (owner, storedData, block.timestamp);
    }
}
