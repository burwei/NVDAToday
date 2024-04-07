# Development log

## Day 1: setup env for Hardhat
 The steps are mainly following the steps from https://www.youtube.com/watch?v=yD3BsYlRLA4
 - Install needed dependencies:  
   ```
   brew install node
   npm init // use all default settings (continous "enter")
   npm install hardhat // use all default settings (continous "enter")
   ```
 - Downgrade node to use the hardhat supported version (from v21.x.x to v20.x.x LTS version):  
   ```
   brew search node // check the available latest stable verison
   brew install node@20 // 20 is the previous LTS version at this point
   brew unlink node
   brew link node@20
   brew link --force --overwrite node@20
   echo 'export PATH="/usr/local/opt/node@20/bin:$PATH"' >> ~/.zshrc
   ```
   After this there will be no warning when you run "npx hardhat test" or "npx hardhat compile".  
 - Create basic project layout:  
   ```
   npx hardhat
   ```
 - Try compile and test:  
   ```
   npm hardhat test
   ```

## Day 1: setup env for Foundry
 - Install Solidity vscode plugin (developed by Juan Balanco), and set the following settings:  
   ```
   "solidity.packageDefaultDependenciesDirectory": "lib",
   "solidity.packageDefaultDependenciesContractsDirectory": "src"
   ```
 - Install Foundry:  
   ```
   curl -L https://foundry.paradigm.xyz | bash
   source /Users/burwei/.zshenv
   brew install libusb 
   foundryup
   ```
 - Create basic project layout:  
   ```
   forge init smart_contract
   ```
 - Run unit tests:  
   ```
   cd smart_contract
   forge test
   ```
 - Deploy example Counter contract to anvil:  
   ```
   // open another terminal
   anvil

   // back to our previous terminal where we're in /smart_contract
   forge create src/Counter.sol:Counter --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   ```

## Day 2: setup Foundry + Remix IDE development env and workflow
 - Install remixd: 
   ```
   npm install -g @remix-project/remixd
   ```
 - Spin up the manual testing env:  
   ```
   // open a new terminal
   anvil

   // open another new terminal (in the directory we're going to share the files)
   remixd
   ``` 
   And do the following:  
   1. Open https://remix.ethereum.org.  
   2. Connect to file system.  
   3. Choose the corresponding contract version.
   4. Connect to Dev - Foundry Provider.  
 - Deploy contract and do the manual testing:  
   1. forge clean
   2. forge compile 
   3. forge create src/Counter.sol:Counter --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 
   4. Set the "At Address" and interact manually with the contract using Remix IDE.  
 - Shutdown the manual testing env:  
   ```
   // in anvil terminal
   ctrl + c

   // in remixd terminal
   ctrl + c

   // in forge terminal, remove the files added by Remix IDE when interacting with the contract
   // and clean forge artifacts
   rm -r src/artifacts
   forge clean
   ```

## Day 2: create React app for Counter contract
 - Install packages ane build app:  
   ```
   mkdir frontend
   cd frontend
   npx create-react-app counter
   cd counter
   npm install ethers@5.7.2    // must be 5.7.2 (the latest version 5, version 6 is unstable and won't work)
   ```
 - Do the development: All the files are in frontend/counter
 - Spin up anvil (no remixd needed) and deploy the contract using forge
   ```
   // in anvil terminal
   anvil

   // in forge terminal
   forge clean
   forge compile
   forge create src/Counter.sol:Counter --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80  
   ```
 - Create the .env_local:  
   ```
   REACT_APP_CONTRACT_ADDRESS=YourContractAddressHere   // copy the address from anvil terminal
   REACT_APP_RPC_URL=http://localhost:8545
   ```
 - Add Counter.json to frontend/counter/src/abi/Counter.json from smart_contract/out/Counter.sol/Counter.json.   
   Remember only need to copy the abi array, don't copy the whole file.  
 - Run the React app:  
   ```
   // in react terminal
   npm start
   ```
## Day 3&4: not doing much, only figuring out a new development workflow 
 - Writing code and unit test on local (vscode + forge)
 - Manual testing using Remix IDE and anvil:  
   1. Start anvil
   2. Copy the contract to deploy from local file system to Remix IDE (need to change the import part by using github URL)
   3. Connect Remix IDE to anvil
   4. Compile and deploy contract using Remix IDE
   5. Interact with the contract using Remix IDE UI
   6. Stop anvil after testing
 - In this approach, no need to clean any artifacts in local file system.

## Day 4&5: chage game rule and figure out a tip of importing library
 - Import the library:  
   - Commit all the changes, or git stash them. forge needs a clean working and staging area to install library.  
   - Use `forge install <github repo>` to install library
   - Run `forge remapping` to see the path of the library, so that you know how to import it in .sol file.  
 - Game rule chages:  
 - The original game rule doesn't work due to the followings:  
   - The gas fee is unignorably high so we need to set a minimum bet limit
   - To schedule a time-based callback is too expensive (chainlink Time-Based Upkeep uses roughly 110K gas per call, [more info](https://docs.chain.link/chainlink-automation/guides/job-scheduler#entering-upkeep-details))
   - So I changed the game rule and the latest version is present in README.md file.    