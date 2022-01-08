import hre from "hardhat";

async function main() {
  const NFTBoredCryptons = await hre.ethers.getContractFactory(
    "NFTBoredCryptons"
  );
  const nftBoredCryptons = await NFTBoredCryptons.deploy(
    "BoredCryptons",
    "BRC"
  );

  console.log(hre.network);
  console.log("NFTBoredCryptons deployed to:", nftBoredCryptons.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
