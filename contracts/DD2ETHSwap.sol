// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DD2ETHSwap is ERC20, Ownable, ReentrancyGuard {
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

    constructor() ERC20("DD Token", "DD") Ownable(msg.sender) {
        // 初始铸造100万代币给合约部署者
        // _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    /**
     * @dev 将ETH兑换为DD代币
     */
    function swapEthToDd() external payable nonReentrant {
        require(msg.value > 0, "Must send ETH");

        // 计算应得的DD代币数量
        uint256 ddAmount = msg.value * EXCHANGE_RATE;

        // 检查合约是否有足够的代币余额
        require(
            balanceOf(address(this)) >= ddAmount,
            "Insufficient DD tokens in contract"
        );

        // 向用户发送DD代币
        _transfer(address(this), msg.sender, ddAmount);

        // 触发事件
        emit EthToDdSwapped(msg.sender, msg.value, ddAmount);
    }

    /**
     * @dev 将DD代币兑换为ETH
     * @param ddAmount 要兑换的DD代币数量
     */
    function swapDdToEth(uint256 ddAmount) external nonReentrant {
        require(ddAmount > 0, "DD amount must be greater than 0");

        // 计算应得的ETH数量
        uint256 ethAmount = ddAmount / EXCHANGE_RATE;

        // 检查合约是否有足够的ETH余额
        require(
            address(this).balance >= ethAmount,
            "Insufficient ETH in contract"
        );

        // 从用户转移DD代币到合约
        _transfer(msg.sender, address(this), ddAmount);

        // 向用户发送ETH
        (bool success, ) = msg.sender.call{value: ethAmount}("");
        require(success, "ETH transfer failed");

        // 触发事件
        emit DdToEthSwapped(msg.sender, ddAmount, ethAmount);
    }

    /**
     * @dev 向合约存入DD代币，使其可用于兑换
     */
    function depositDdTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        _transfer(msg.sender, address(this), amount);
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
    function withdrawDdTokens(uint256 amount) external onlyOwner {
        require(amount <= balanceOf(address(this)), "Insufficient DD balance");
        _transfer(address(this), owner(), amount);
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
        return balanceOf(address(this));
    }

    // 接收ETH的fallback函数
    receive() external payable {}
}
