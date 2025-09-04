const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DD2ETHSwap", (m) => {
        const dD2ETHSwap = m.contract("DD2ETHSwap");
        return { dD2ETHSwap };
});