// ignition/modules/SimpleStorage.ts
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("SimpleStorageModule", (m) => {
  // 部署SimpleStorage合约
  const simpleStorage = m.contract("SimpleStorage");

  return { simpleStorage };
});
