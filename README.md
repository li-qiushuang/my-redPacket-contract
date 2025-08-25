# Sample Hardhat Project
 
## - [ ] npx hardhat --init      【初始化一个 Hardhat 项目】
## - [ ] npx hardhat compile
## npx hardhat ignition deploy ./ignition/modules/RedPacket.js --network sepolia


## 下面是部署成功的信息  
npx hardhat ignition deploy ./ignition/modules/RedPacket.js --network sepolia
[dotenv@17.2.1] injecting env (3) from .env -- tip: 📡 observe env with Radar: https://dotenvx.com/radar
✔ Confirm deploy to network sepolia (11155111)? … yes
Hardhat Ignition 🚀

Deploying [ RedPacketModule ]

Batch #1
  Executed RedPacketModule#RedPacket

[ RedPacketModule ] successfully deployed 🚀

Deployed Addresses

RedPacketModule#RedPacket - 0x4f3181870eA5D23b55e6B01799d3D454cdf6B9A9


### 查看和验证这个合约：
## 打开 Sepolia Etherscan
## 在顶部的搜索框中，粘贴你的合约地址：0x7d8F4fCFc35582E54a91AdA14CD4FA947972F925

## 注意在Sepolia Etherscan 的合约页面，在合同tab标签处把合约开源



## 如果在Sepolia Etherscan这个页面发布合约失败，可以直接用一个命令行搞定
#  npx hardhat verify --network sepolia 0x4f3181870eA5D23b55e6B01799d3D454cdf6B9A9


 
