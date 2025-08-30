// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// 从 OpenZeppelin 导入标准的 ERC20 实现
// 需要安装 yarn add @openzeppelin/contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 定义我们的代币合约，它继承自 OpenZeppelin 的 ERC20 合约
contract MyToken is ERC20 {
    string public constant TOKENNAME = "WWERC20TOKEN";
    string public constant TOKENYMBOL = "WWB";
    uint256 public constant TOKEN_INITSUPPLY = 1000;

    constructor() ERC20(TOKENNAME, TOKENYMBOL) {
        // 将初始供应量的代币铸造给部署合约的人（msg.sender）
        _mint(msg.sender, TOKEN_INITSUPPLY);
    }
}
