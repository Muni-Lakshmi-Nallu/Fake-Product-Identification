import React, { useState, useEffect } from 'react';
import Web3 from 'web3';

let web3;
if (window.ethereum) {
  web3 = new Web3(window.ethereum);
  try {
    // Request account access if needed
    window.ethereum.enable();  // This will prompt MetaMask to allow connection
  } catch (error) {
    console.error('User denied account access', error);
  }
} else if (window.web3) {
  // Legacy MetaMask support
  web3 = new Web3(window.web3.currentProvider);
} else {
  console.log("MetaMask is not installed!");
}

function App() {
  const [account, setAccount] = useState(null);

  // Detect MetaMask account change
  useEffect(() => {
    if (web3) {
      window.ethereum.on('accountsChanged', (accounts) => {
        setAccount(accounts[0]);
      });
    }
  }, []);

  const connectMetaMask = async () => {
    if (web3) {
      const accounts = await web3.eth.requestAccounts();
      setAccount(accounts[0]);
    } else {
      alert("Please install MetaMask!");
    }
  };

  return (
    <div>
      <h1>Connect to MetaMask</h1>
      {!account ? (
        <button onClick={connectMetaMask}>Connect MetaMask</button>
      ) : (
        <div>Connected as: {account}</div>
      )}
    </div>
  );
}

export default App;
