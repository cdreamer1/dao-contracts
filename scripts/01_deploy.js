const { ethers } = require("hardhat");
const { MOCK_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  // Deploy the MockNFTMarketplace contract first
  const MockNFTMarketplace = await ethers.getContractFactory(
    "MockNFTMarketplace"
  );
  const mockNftMarketplace = await MockNFTMarketplace.deploy();

  console.log("MockNFTMarketplace deployed to: ", mockNftMarketplace.target);

  // Now deploy the NFTDAO contract
  const NFTDAO = await ethers.getContractFactory("NFTDAO");
  const nftDAO = await NFTDAO.deploy(
    mockNftMarketplace.target,
    MOCK_NFT_CONTRACT_ADDRESS,
    {
      value: ethers.parseEther("0.1"),
    }
  );

  console.log("NFTDAO deployed to: ", nftDAO.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
