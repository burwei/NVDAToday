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
 