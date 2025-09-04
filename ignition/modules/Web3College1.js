const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Web3University", (m) => {
        const web3University = m.contract("Web3University");
        return { web3University };
});