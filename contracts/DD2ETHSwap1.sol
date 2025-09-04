// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// DD2ETHSwap1这个是最新的兑换合约，之前的DD2ETHSwap 好像有两个问题：旧的定义了发币与另一个发币会冲突，还有就是这个新合约需要写入发币合约的地址

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DD2ETHSwap1 is Ownable, ReentrancyGuard {
    // DD代币合约
    IERC20 public ddToken;

    // 兑换率：1 ETH = 1000 DD代币
    uint256 public constant EXCHANGE_RATE = 1000;

    // 事件：ETH兑换DD代币
    event EthToDdSwapped(
        address indexed user,
        uint256 ethAmount,
        uint256 ddAmount
    );

    // 事件：DD代币兑换ETH
    event DdToEthSwapped(
        address indexed user,
        uint256 ddAmount,
        uint256 ethAmount
    );

    // 修饰符：确保DD代币地址已设置
    modifier ddTokenSet() {
        require(address(ddToken) != address(0), "DD token address not set");
        _;
    }

    constructor() Ownable(msg.sender) {
        // DD代币地址将通过 setDdTokenAddress 函数设置
    }

    /**
     * @dev 设置DD代币合约地址（只有所有者可以调用）
     */
    function setDdTokenAddress(address _ddTokenAddress) external onlyOwner {
        require(_ddTokenAddress != address(0), "Invalid DD token address");
        ddToken = IERC20(_ddTokenAddress);
    }

    /**
     * @dev 将ETH兑换为DD代币
     */
    function swapEthToDd() external payable nonReentrant ddTokenSet {
        require(msg.value > 0, "Must send ETH");

        // 计算应得的DD代币数量
        uint256 ddAmount = msg.value * EXCHANGE_RATE;

        // 检查合约是否有足够的DD代币余额
        require(
            ddToken.balanceOf(address(this)) >= ddAmount,
            "Insufficient DD tokens in contract"
        );

        // 从合约向用户转移DD代币
        require(
            ddToken.transfer(msg.sender, ddAmount),
            "DD token transfer failed"
        );

        // 触发事件
        emit EthToDdSwapped(msg.sender, msg.value, ddAmount);
    }

    /**
     * @dev 将DD代币兑换为ETH
     * @param ddAmount 要兑换的DD代币数量
     */
    function swapDdToEth(uint256 ddAmount) external nonReentrant ddTokenSet {
        require(ddAmount > 0, "DD amount must be greater than 0");

        // 计算应得的ETH数量
        uint256 ethAmount = ddAmount / EXCHANGE_RATE;

        // 检查合约是否有足够的ETH余额
        require(
            address(this).balance >= ethAmount,
            "Insufficient ETH in contract"
        );

        // 从用户转移DD代币到合约
        require(
            ddToken.transferFrom(msg.sender, address(this), ddAmount),
            "DD token transfer failed"
        );

        // 向用户发送ETH
        (bool success, ) = msg.sender.call{value: ethAmount}("");
        require(success, "ETH transfer failed");

        // 触发事件
        emit DdToEthSwapped(msg.sender, ddAmount, ethAmount);
    }

    /**
     * @dev 所有者可以提取合约中的ETH
     */
    function withdrawEth(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
    }

    /**
     * @dev 所有者可以提取合约中的DD代币
     */
    function withdrawDdTokens(uint256 amount) external onlyOwner ddTokenSet {
        require(
            amount <= ddToken.balanceOf(address(this)),
            "Insufficient DD balance"
        );
        require(ddToken.transfer(owner(), amount), "Transfer failed");
    }

    /**
     * @dev 获取合约中的ETH余额
     */
    function getEthBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev 获取合约中的DD代币余额
     */
    function getDdBalance() external view returns (uint256) {
        require(address(ddToken) != address(0), "DD token not set");
        return ddToken.balanceOf(address(this));
    }

    /**
     * @dev 获取DD代币合约地址
     */
    function getDdTokenAddress() external view returns (address) {
        return address(ddToken);
    }

    // 接收ETH的fallback函数
    receive() external payable {}
}
