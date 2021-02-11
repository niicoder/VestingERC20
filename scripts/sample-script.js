// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require('hardhat')

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const ChainGuardians = await hre.ethers.getContractFactory('ChainGuardians')
  const CG = await ChainGuardians.deploy(
    'ChainGuardians',
    'CGB',
    '100000000000000000000000',
  )

  await CG.deployed()

  console.log('ChainGuardians deployed to:', CG.address)

  await hre.run('verify:verify', {
    address: CG.address,
    constructorArguments: ['ChainGuardians', 'CGB', '100000000000000000000000'],
  })

  console.log('ChainGuardians verified!')

  const Vesting = await hre.ethers.getContractFactory('Vesting')
  const vester = await Vesting.deploy(CG.address)

  await vester.deployed()

  console.log('Vesting deployed to:', vester.address)

  await hre.run('verify:verify', {
    address: vester.address,
    constructorArguments: [CG.address],
  })

  console.log('Vesting verified!')
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
