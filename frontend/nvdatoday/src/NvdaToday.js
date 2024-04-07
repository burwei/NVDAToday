import React, { useState } from 'react';

function NvdaToday() {
    const [price, setPrice] = useState('$945.12'); // Mocked price, you'll fetch this from your contract
    const [betAmount, setBetAmount] = useState('');
    const [network, setNetwork] = useState('Ethereum'); // Default network, you'll need to provide the logic for changing networks
    const [address, setAddress] = useState(''); // Default address, you'll need to provide the logic for changing addresses

    // Add your functions for interacting with your smart contract here.
    // This will include fetching the price, placing bets, etc.

    const handleBetAmountChange = (event) => {
        setBetAmount(event.target.value);
    };

    const placeBet = (betDirection) => {
        console.log(`Placing bet to ${betDirection} with amount: ${betAmount}`);
        // Here you would have logic to interact with your contract to place a bet
    };

    return (
        <div className="nvda-today">
            <h1>NVDA Today</h1>
            <div className="price-info">
                <h3>Last price: {price}</h3>
                <p>Updated at 21:00:01 UTC</p> {/* You should dynamically fetch this */}
            </div>
            <div className="pool-section">
                <div className="pool-box">
                    <label>Bet Lower Pool:</label>
                    <input
                        type="text"
                        value={betAmount}
                        onChange={handleBetAmountChange}
                        placeholder="25 finney"
                    />
                </div>
                <div className="pool-box">
                    <label>Bet Higher Pool:</label>
                    <input
                        type="text"
                        value={betAmount}
                        onChange={handleBetAmountChange}
                        placeholder="76 finney"
                    />
                </div>
            </div>
            <div className="config-section">
                <label>Network:</label>
                <select value={network} onChange={(e) => setNetwork(e.target.value)}>
                    <option value="local-anvil-testnet">Local anvil (testnet)</option>
                    <option value="local-hardhat-testnet">Local Hardhat (testnet)</option>
                    <option value="arbitrum-sepolia-testnet">Arbitrum Sepolia (testnet)</option>
                    <option value="arbitrum-one-mainnet">Arbitrum One (mainnet)</option>
                    <option value="bnb-mainnet">BNB (mainnet)</option>
                </select>
            </div>
            <div className="config-section">
                <label>Address:</label>
                <input
                    type="text"
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    placeholder="25 finney"
                />
                <label>or</label>
                <button className="connect-metamask" onClick={() => { }}>Connect MetaMask</button>
            </div>
            <div className="config-section">
                <label>Your bet:</label>
                <input
                    type="text"
                    value={betAmount}
                    onChange={handleBetAmountChange}
                    placeholder="25"
                />
                <label> + contract fee 0.01 finney = </label>
                <label>25.01 finney</label>
            </div>
            <div className="bet-section">
                <button className="bet-button red" onClick={() => placeBet('lower')}>Bet Lower</button>
                <button className="bet-button green" onClick={() => placeBet('higher')}>Bet Higher</button>
            </div>
            <div className="action-buttons">
                <button className="grey">Process Bets</button>
                {/* Add other action buttons as needed */}
            </div>
        </div>
    );
}

export default NvdaToday;
