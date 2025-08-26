// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract RedPacket {
    struct Packet {
        address creator;
        uint256 totalAmount;
        uint256 totalCount;
        uint256 claimedCount;
        uint256 remainingAmount;
        bool isActive;
        string message; // 新增：留言信息
        mapping(address => bool) claimed;
    }

    mapping(bytes32 => Packet) public packets;
    bytes32[] public packetIds;

    event PacketCreated(
        bytes32 indexed packetId,
        address indexed creator,
        uint256 totalAmount,
        uint256 totalCount,
        string message // 新增：在事件中包含留言
    );
    
    event PacketClaimed(
        bytes32 indexed packetId,
        address indexed claimer,
        uint256 amount
    );
    
    event PacketSettled(
        bytes32 indexed packetId,
        address indexed settler,
        uint256 refundAmount
    );

    modifier onlyCreator(bytes32 packetId) {
        require(packets[packetId].creator == msg.sender, "Only creator can call");
        _;
    }

    modifier packetExists(bytes32 packetId) {
        require(packets[packetId].creator != address(0), "Packet does not exist");
        _;
    }

    function createPacket(uint256 totalCount, string memory message) external payable returns (bytes32) {
        require(msg.value > 0, "Must send ETH");
        require(totalCount > 0, "At least one red packet");
        require(bytes(message).length <= 100, "Message too long"); // 限制留言长度

        bytes32 packetId = keccak256(abi.encodePacked(msg.sender, block.timestamp, msg.value, message));
        
        Packet storage newPacket = packets[packetId];
        newPacket.creator = msg.sender;
        newPacket.totalAmount = msg.value;
        newPacket.totalCount = totalCount;
        newPacket.remainingAmount = msg.value;
        newPacket.isActive = true;
        newPacket.message = message; // 存储留言

        packetIds.push(packetId);

        emit PacketCreated(packetId, msg.sender, msg.value, totalCount, message);
        return packetId;
    }

    function claim(bytes32 packetId) external packetExists(packetId) {
        Packet storage packet = packets[packetId];
        
        require(packet.isActive, "Packet is not active");
        require(!packet.claimed[msg.sender], "Already claimed");
        require(packet.claimedCount < packet.totalCount, "All packets claimed");

        uint256 amount = calculateClaimAmount(packetId);
        require(amount > 0, "No amount to claim");

        packet.claimed[msg.sender] = true;
        packet.claimedCount++;
        packet.remainingAmount -= amount;

        payable(msg.sender).transfer(amount);

        emit PacketClaimed(packetId, msg.sender, amount);

        // Auto settle if all claimed
        if (packet.claimedCount == packet.totalCount) {
            packet.isActive = false;
        }
    }

    function calculateClaimAmount(bytes32 packetId) public view packetExists(packetId) returns (uint256) {
        Packet storage packet = packets[packetId];
        
        if (!packet.isActive || packet.claimedCount >= packet.totalCount) {
            return 0;
        }

        // 平均分配逻辑
        uint256 remainingClaims = packet.totalCount - packet.claimedCount;
        return packet.remainingAmount / remainingClaims;
    }

    function settlePacket(bytes32 packetId) external packetExists(packetId) {
        Packet storage packet = packets[packetId];
        
        require(packet.isActive, "Packet already settled");
        require(block.timestamp > creationTime(packetId) + 24 hours || 
                msg.sender == packet.creator, "Only creator can settle before 24h");

        uint256 refundAmount = packet.remainingAmount;
        packet.isActive = false;
        packet.remainingAmount = 0;

        if (refundAmount > 0) {
            payable(packet.creator).transfer(refundAmount);
        }

        emit PacketSettled(packetId, msg.sender, refundAmount);
    }

    function getPacketInfo(bytes32 packetId) external view returns (
        address creator,
        uint256 totalAmount,
        uint256 totalCount,
        uint256 claimedCount,
        uint256 remainingAmount,
        bool isActive,
        string memory message // 新增：返回留言信息
    ) {
        Packet storage packet = packets[packetId];
        return (
            packet.creator,
            packet.totalAmount,
            packet.totalCount,
            packet.claimedCount,
            packet.remainingAmount,
            packet.isActive,
            packet.message // 返回留言
        );
    }

    function hasClaimed(bytes32 packetId, address user) external view returns (bool) {
        return packets[packetId].claimed[user];
    }

    function getAllPacketIds() external view returns (bytes32[] memory) {
        return packetIds;
    }

    function creationTime(bytes32 packetId) internal view returns (uint256) {
        // 这里简化处理，实际项目中可能需要记录创建时间
        return uint256(packetId) % block.timestamp;
    }
}