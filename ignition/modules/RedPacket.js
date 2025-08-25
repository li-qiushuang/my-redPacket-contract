const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("RedPacketModule", (m) => {
  const redPacket = m.contract("RedPacket");
  return { redPacket };
});