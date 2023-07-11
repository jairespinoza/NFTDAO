const hre = require("hardhat");

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const FriendsContract = await hre.ethers.getContractFactory("Friends");
  const friendsContract = await FriendsContract.deploy();

  console.log("Friends contract is deployed at:", friendsContract.target);

  await sleep(30 * 1000);

  await hre.run("verify:verify", {
    address: friendsContract.target,
    constructorArguments: [],
  });

  console.log("Deploying Marketplace please wait...");

  const fakeNFTMarketplace = await hre.ethers.getContractFactory(
    "NFTMarketplace"
  );
  const FakeNFTMarketplace = await fakeNFTMarketplace.deploy(
    friendsContract.target
  );
  console.log("NFT Marketplace deployed at:", FakeNFTMarketplace.target);

  await sleep(30 * 1000);

  await hre.run("verify:verify", {
    address: FakeNFTMarketplace.target,
    constructorArguments: [friendsContract.target],
  });

  console.log("Deploying DAO contract please wait...");

  const friendsDAO = await hre.ethers.getContractFactory("FriendsDAO");
  const FriendsDAO = await friendsDAO.deploy(friendsContract.target);

  console.log("Friends DAO has been deployed at:", FriendsDAO.target);

  await sleep(30 * 2000);

  await hre.run("verify:verify", {
    address: FriendsDAO.target,
    constructorArguments: [friendsContract.target],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

//WHY IS .TARGET NOT WORKING????
//Not running cause friends contract constructor was empty, gotta fix friends contract since it
