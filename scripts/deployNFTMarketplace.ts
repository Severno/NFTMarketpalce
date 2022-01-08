import hre from "hardhat";

async function main() {
  const NFTMarketplace = await hre.ethers.getContractFactory("NFTMarketplace");
  const nftMarketplace = await NFTMarketplace.deploy(
    "0x5a443704dd4B594B382c22a083e2BD3090A6feF3",
    "0xBd770416a3345F91E4B34576cb804a576fa48EB1"
  );

  console.log(hre.network);
  console.log("NFTMarketplace deployed to:", nftMarketplace.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
