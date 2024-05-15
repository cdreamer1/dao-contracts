const { ethers } = require("hardhat");
const { TOKEN_NAME, TOKEN_SYMBOL, TOKEN_SUPPLY, INITIAL_OWNER, MINT_PRICE, TOKEN_URI } = require("../constants");

async function main() {
  const NFTContract = await ethers.getContractFactory(
    "RocketNFT"
  );
  const nftContract = await NFTContract.deploy(
    TOKEN_NAME,
    TOKEN_SYMBOL,
    TOKEN_URI,
    MINT_PRICE,
    TOKEN_SUPPLY,
    INITIAL_OWNER
  );

  console.log("NFT contract deployed to: ", nftContract.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
