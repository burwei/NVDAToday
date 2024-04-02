import React, { useState, useEffect, useCallback } from 'react';
import contractABI from './abi/Counter.json';
import { ethers } from "ethers";

// Use environment variables for contract address and RPC URL
const contractAddress = process.env.REACT_APP_CONTRACT_ADDRESS;
const rpcURL = process.env.REACT_APP_RPC_URL;

// Initialize ethers.js and the contract
const provider = new ethers.providers.JsonRpcProvider(rpcURL);
const contract = new ethers.Contract(contractAddress, contractABI, provider);

console.log("contract: ", contract);
console.log("provider: ", provider);

function Counter() {
  const [number, setNumber] = useState(0);

  // Function to fetch the current number from the contract
  const fetchNumber = useCallback(async () => {
    console.log('Fetching number...');
    const currentNumber = await contract.number();
    console.log('Fetched number:', currentNumber.toString());
    setNumber(currentNumber.toString());
  }, []);

  // Function to increment the number in the contract
  const incrementNumber = useCallback(async () => {
    console.log('Incrementing number...');
    const signer = provider.getSigner();
    const contractWithSigner = contract.connect(signer);
    await contractWithSigner.increment();
    console.log('Incremented number');
    fetchNumber(); // Update the displayed number after incrementing
  }, [fetchNumber]);

  useEffect(() => {
    fetchNumber(); // Fetch the current number when the component mounts
  }, [fetchNumber]);

  return (
    <div>
      <h1>Current Number: {number}</h1>
      <button onClick={incrementNumber}>Increment Number</button>
      <button onClick={fetchNumber}>Refresh Number</button>
      <p>Contract Number: {number}</p>
    </div>
  );
}

export default Counter;