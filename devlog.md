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