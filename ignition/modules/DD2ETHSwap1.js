const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DD2ETHSwap1", (m) => {
    const dD2ETHSwap1 = m.contract("DD2ETHSwap1");
    return { dD2ETHSwap1 };
});