# NVDAToday
NVDAToday is a simple web3 app that allows users to bet on whether the NVDA stock price will be higher or lower than the previous price. Winners will share the pool.  

It's my first web3 app and it's for learning purpose.  


## How does it work?
 - On local testnet (ex: hardhat node, foundry anvil)
    ```mermaid
    flowchart
    A[deploy contract]
    B["users bet next price (higher or lower)"]
    C[contract owner manually settle bets with a new price]
    D[calculate rewards and send them to winners' account<br>base on the stake they put]
    E[update latest NVDA price in the contract]

    A --> B
    B --> C
    C --> D
    D --> E
    E --> B
    ```

 - On public mainnet/testnet (ex: BNB Mainnet, Arbitrum Sepolia)
    ```mermaid
    flowchart
    A[deploy contract]
    B["users bet next price (higher or lower)"]
    C["one of the user triggers the contract to process bets
    1. only one trigger will be accepted per day
    2. user who triggers the process will be rewarded
    3. process could only be triggered between 21:00~23:59 UTC"]
    D[get latest NVDA stock price from chainlink]
    E[calculate rewards and send them to winners' account<br>base on the stake they put]
    F[update latest NVDA price in the contract]

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> B
    ```
## Run it using local anvil testnet
1. Start anvil
   ```
   // open a terminal to run anvil (directory: /NvdaToday)
   anvil
   ``` 
2. Deploy NvdaToday contract
   ```
   // open a new terminal from the same directory
   cd smart_contract
   forge create src/NvdaToday.sol:NvdaToday --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   ```
3. Create .env.local and run React app
   ```
   // move to frontend directory
   cd ../frontend/nvdatoday
   
   // remove the .env.local file if exists, and write to the file
   rm .env.local
   echo "REACT_APP_CONTRACT_ADDRESS_ANVIL=DEPLOYMENT_ADDRESS_OF_THE_CONTRACT" >> .env.local
   echo "REACT_APP_RPC_URL_ANVIL=http://localhost:8545" >> .env.local
   echo "REACT_APP_GAS_LIMIT=1000000" >> .env.local

   npm start
   ```
