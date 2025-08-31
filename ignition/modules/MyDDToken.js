const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MyDDToken", (m) => {
        const myDDToken = m.contract("MyDDToken");
        return { myDDToken };
});