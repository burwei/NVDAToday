import React, { useState } from 'react';
import './NvdaToday.css';

function NvdaToday() {
    const [lastPrice, setLastPrice] = useState('$945.12');
    const [lastPriceUpdatedAt, setLastPriceUpdatedAt] = useState('21:00:01');
    const [betAmount, setBetAmount] = useState(12);
    const [totalBetHigherAmount, setTotalBetHigherAmount] = useState(120);
    const [totalBetLowerAmount, setTotalBetLowerAmount] = useState(50);
    const [network, setNetwork] = useState('Ethereum');
    const [address, setAddress] = useState('');
    const [showProcessBets, setShowProcessBets] = useState(true);

    const handleBetAmountChange = (event) => {
        setBetAmount(event.target.value);
    };

    const placeBet = (betDirection) => {
        console.log(`Placing bet to ${betDirection} with amount: ${betAmount}`);
    };

    return (
        <div className="nvda-today">
            <div className='title-section'>
                <h1>NVDA Today</h1>
                <p>Will NVDA close higher or lower than previous price?</p>
            </div>
            <div className="price-info">
                <h3>Last Price: {lastPrice}</h3>
                <p>Updated at {lastPriceUpdatedAt} UTC</p>
            </div>
            <div className="pool-section">
                <div className="pool-box-lower">
                    <p>Bet lower total amount (finney):</p>
                    <h3>{totalBetLowerAmount}</h3>
                </div>
                <div className="pool-box-higher">
                    <p>Bet higher total amount (finney):</p>
                    <h3>{totalBetHigherAmount}</h3>
                </div>
            </div>
            <div className="config-section">
                <h4>Network:</h4>
                <select value={network} onChange={(e) => setNetwork(e.target.value)}>
                    <option value="local-anvil-testnet">Local anvil (testnet)</option>
                    <option value="local-hardhat-testnet">Local Hardhat (testnet)</option>
                    <option value="arbitrum-sepolia-testnet">Arbitrum Sepolia (testnet)</option>
                    <option value="arbitrum-one-mainnet">Arbitrum One (mainnet)</option>
                    <option value="bnb-mainnet">BNB (mainnet)</option>
                </select>
            </div>
            <div className="config-section">
                <h4>Address:</h4>
                <input
                    type="text"
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    placeholder="0x1234...5678"
                />
                <p>or</p>
                <button className="connect-wallet" onClick={() => { }}>Wallet</button>
            </div>
            <div className="config-section">
                <h4>Your bet:</h4>
                <input
                    className='bet-amount-input'
                    type="text"
                    value={betAmount}
                    onChange={handleBetAmountChange}
                    placeholder="12"
                />
                <p> + process fee 0.01 = </p>
                <div className="final-bet-amount">
                    <h3>{parseInt(betAmount) + 0.01}</h3>
                    <p>finney</p>
                </div>
            </div>
            <div className="bet-section">
                <button className="bet-button-lower" onClick={() => placeBet('lower')}>Bet Lower</button>
                <button className="bet-button-higher" onClick={() => placeBet('higher')}>Bet Higher</button>
            </div>
            <div className="process-bet-section" style={showProcessBets ? {} : { display: 'none' }} >
                <button className="process-bet-button" onClick={()=> setShowProcessBets(false)}>Process Bets</button>
                <p>No one has triggered the process today.<br></br>You'll get all the process fees if you click "Process Bets".</p>
            </div>
        </div>
    );
}

export default NvdaToday;
