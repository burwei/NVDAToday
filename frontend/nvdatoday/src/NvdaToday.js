import React, { useEffect, useState } from 'react';
import contractABI from './abi/NvdaToday.json';
import { ethers } from "ethers";
import './NvdaToday.css';

const networkLocalAnvil = 'local-anvil-testnet';
const networkArbitrumSepolia = 'arbitrum-sepolia-testnet';
const networkArbitrumOne = 'arbitrum-one-mainnet';
const networkBnb = 'bnb-mainnet';


// Use environment variables for contract address and RPC URL
const contractAddressAnvil = process.env.REACT_APP_CONTRACT_ADDRESS_ANVIL;
const contractAddressArbitrumSepolia = process.env.REACT_APP_CONTRACT_ADDRESS_ARBITRUM_SEPOLIA;
const contractAddressArbitrumOne = process.env.REACT_APP_CONTRACT_ADDRESS_ARBITRUM_ONE;
const contractAddressBnb = process.env.REACT_APP_CONTRACT_ADDRESS_BNB;
const rpcURLAnvil = process.env.REACT_APP_RPC_URL_ANVIL;
const gasLimit = process.env.REACT_APP_GAS_LIMIT;

var provider;
var signer;
var contract;


function NvdaToday() {
    const [lastPrice, setLastPrice] = useState('$---.--');
    const [lastPriceUpdatedAt, setLastPriceUpdatedAt] = useState('YYYY-MM-DD HH:MM:SS');
    const [betAmount, setBetAmount] = useState(5);
    const [totalBetHigherAmount, setTotalBetHigherAmount] = useState(0);
    const [totalBetLowerAmount, setTotalBetLowerAmount] = useState(0);
    const [network, setNetwork] = useState('');
    const [accounts, setAccounts] = useState([]);
    const [selectedAccount, setSelectedAccount] = useState('');
    const [showProcessBets, setShowProcessBets] = useState(true);

    const fetchAccounts = async () => {
        const accs = await provider.listAccounts();
        setAccounts(accs);
        setSelectedAccount(accs[0]);
    };

    const connectLocal = () => {
        provider = new ethers.providers.JsonRpcProvider(rpcURLAnvil);
        signer = provider.getSigner();
        contract = new ethers.Contract(contractAddressAnvil, contractABI, provider);
        fetchAccounts()
    };

    const connectWallet = async () => {
        var contractAddress;
        switch (network) {
            case networkArbitrumSepolia:
                contractAddress = contractAddressArbitrumSepolia;
                break;
            case networkArbitrumOne:
                contractAddress = contractAddressArbitrumOne;
                break;
            case networkBnb:
                contractAddress = contractAddressBnb;
                break;
            default:
                console.log('Invalid network');
                return;
        };
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        await provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        contract = new ethers.Contract(contractAddress, contractABI, provider);
        fetchAccounts();
    };

    const connectNetwork = async (selectedNetwork) => {
        if (selectedNetwork === '') {
            setNetwork('please select');
            return;
        }

        setNetwork(selectedNetwork);
        switch (selectedNetwork) {
            case networkLocalAnvil:
                await connectLocal();
                break;
            default:
                await connectWallet();
                break;
        }
        fetchLastPrice();
        fetchTotalStake();
        setShowProcessBets(shouldShowProcessBet());
    };

    const fetchLastPrice = async () => {
        try {
            const result = await contract.lastPrice();
            const price = ethers.utils.formatUnits(result.price.toString(), 'finney');
            const date = new Date(result.timestamp.toNumber() * 1000);
            const formattedDate = date.toISOString().replace('T', ' ').substring(0, 19); // YYYY-MM-DD HH:MM:SS

            setLastPrice(price);
            setLastPriceUpdatedAt(formattedDate);
        } catch (error) {
            console.error('Error fetching last price:', error);
        }
    }

    const fetchTotalStake = async () => {
        try {
            const betHigherAmount = await contract.totalStakeBetHigher();
            const betLowerAmount = await contract.totalStakeBetLower();

            setTotalBetHigherAmount(ethers.utils.formatUnits(betHigherAmount, 'finney'));
            setTotalBetLowerAmount(ethers.utils.formatUnits(betLowerAmount, 'finney'));
        } catch (error) {
            console.error('Error fetching total stake:', error);
        }
    }

    const placeBet = async (betDirection) => {
        const amountInFinney = ethers.utils.parseUnits(betAmount.toString() + '.01', 'finney');
        const options = { value: amountInFinney };
        var tx;
        var receipt;
        try {
            const contractWithSigner = contract.connect(signer);
            switch (betDirection) {
                case 'higher':
                    tx = await contractWithSigner.betHigher(options);
                    console.log('Transaction hash:', tx.hash);
                    receipt = await tx.wait();
                    console.log('Transaction confirmed in block:', receipt.blockNumber);
                    break;
                case 'lower':
                    tx = await contractWithSigner.betLower(options);
                    console.log('Transaction hash:', tx.hash);
                    receipt = await tx.wait();
                    console.log('Transaction confirmed in block:', receipt.blockNumber);
                    break;
                default:
                    console.log('Invalid bet direction');
            }
        } catch (error) {
            console.error('Error placing bet:', error);
        }
        fetchTotalStake();
        fetchLastPrice();
    }

    const getRandomInt = (min, max) => {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min; //The maximum is inclusive and the minimum is inclusive
    }

    const processBets = async () => {
        const overrides = { gasLimit: ethers.utils.hexlify(parseInt(gasLimit)) };
        if (network === networkLocalAnvil) {
            try {
                let newPrice = getRandomInt(800, 1200);
                const contractWithSigner = contract.connect(signer);
                const tx = await contractWithSigner.manualSettleBets(newPrice, overrides);
                console.log('Transaction hash:', tx.hash);
                const receipt = await tx.wait();
                console.log('Transaction confirmed in block:', receipt.blockNumber);
            } catch (error) {
                console.error('Error processing bets:', error);
            }
        } else {
            try {
                const contractWithSigner = contract.connect(signer);
                const tx = await contractWithSigner.processBets(overrides);
                const receipt = await tx.wait();
                console.log('Transaction confirmed in block:', receipt.blockNumber);
            } catch (error) {
                console.error('Error processing bets:', error);
            }
        }

        setShowProcessBets(shouldShowProcessBet());
    }

    function shouldShowProcessBet() {
        const dateString = lastPriceUpdatedAt;
        const currentDate = new Date();

        const dateParts = dateString.split(' ');
        const dateComponent = dateParts[0].split('-');
        const timeComponent = (dateParts[1] ? dateParts[1] : "00:00:00").split(':');

        const parsedDate = new Date(Date.UTC(
            parseInt(dateComponent[0], 10),      // Year
            parseInt(dateComponent[1], 10) - 1,  // Month is zero-based in JavaScript
            parseInt(dateComponent[2], 10),      // Day
            parseInt(timeComponent[0], 10),      // Hour
            parseInt(timeComponent[1], 10),      // Minute
            parseInt(timeComponent[2], 10)       // Second
        ));

        const year1 = currentDate.getUTCFullYear();
        const month1 = currentDate.getUTCMonth();
        const day1 = currentDate.getUTCDate();

        const year2 = parsedDate.getUTCFullYear();
        const month2 = parsedDate.getUTCMonth();
        const day2 = parsedDate.getUTCDate();

        // check if it's the same day
        // if not the same day, show the process bets button
        return !(year1 === year2 && month1 === month2 && day1 === day2);
    }

    useEffect(() => {
        setShowProcessBets(shouldShowProcessBet());
    }, []);

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
                <select value={network} onChange={(e) => connectNetwork(e.target.value)}>
                    <option value={''}>please select</option>
                    <option value={networkLocalAnvil}>Local anvil (testnet)</option>
                    <option value={networkArbitrumSepolia}>Arbitrum Sepolia (testnet)</option>
                    <option value={networkArbitrumOne}>Arbitrum One (mainnet)</option>
                    <option value={networkBnb}>BNB (mainnet)</option>
                </select>
            </div>
            <div className="config-section">
                <h4>Your account:</h4>
                <select
                    value={selectedAccount} onChange={(e) => setSelectedAccount(e.target.value)}
                    style={network === networkLocalAnvil ? {} : { display: 'none' }}>
                    {accounts.map((account, index) => (
                        <option key={index} value={account}>
                            {account}
                        </option>
                    ))}
                </select>
            </div>
            <div className="config-section">
                <h4>Your bet:</h4>
                <input
                    className='bet-amount-input'
                    type="text"
                    value={betAmount}
                    onChange={(event) => { setBetAmount(event.target.value); }}
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
                <button className="process-bet-button" onClick={processBets}>Process Bets</button>
                <p>No one has triggered the process today.<br></br>You'll get all the process fees if you click "Process Bets".</p>
            </div>
        </div>
    );
}

export default NvdaToday;
