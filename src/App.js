import './App.css';
import { useState, useEffect } from "react";
import { Magic } from "magic-sdk";
import { ConnectExtension } from "@magic-ext/connect";
import Web3 from "web3";
import {abi} from "./abi"

const magic = new Magic("pk_live_73AAE8A5F81B1CF3", {
  network: "goerli",
  locale: "en_US",
  extensions: [new ConnectExtension()]
});
const web3 = new Web3(magic.rpcProvider);
const contractAddress ='0x63f8bCD03fBDD1cEB92B8469A91de8996306Dd74'


function App() {
  const [account, setAccount] = useState(null);
  const [isUpdating, setIsUpdating] = useState(false);
  const [timestamp, setTimestamp] = useState('loading...');
  const [food, setFood] = useState(null);
  const maxFood = 150;
  const foodConsumedPerSecond = 2;

  useEffect(() => {
    console.log('Mounted')
    getTimestamp();
  },[]);

  useEffect(() => {    
    const intervalId = setInterval(() => {
      let latestFood = getFood(timestamp, maxFood, foodConsumedPerSecond)
      setFood(latestFood)
    }, 1000);
    return () => clearInterval(intervalId);
  }, [food, timestamp]);

  const getTimestamp = async () => {
    console.log('About to fetch latest feed date')
    const contract = new web3.eth.Contract(abi, contractAddress);
    contract.methods.lastUpdated().call().then(setTimestamp)
    console.log('updated')
  }

  const updateTimestamp = async () => {
    console.log('calling feed contract')
    setIsUpdating(true)
    const contract = new web3.eth.Contract(abi, contractAddress);
    const receipt = await contract.methods.update().send({ from: account });
    console.log(receipt)
    setIsUpdating(false)
    getTimestamp();
  };
 
  const login = async () => {
    web3.eth
      .getAccounts()
      .then((accounts) => {
        console.log(accounts)
        setAccount(accounts?.[0]);
      })
      .catch((error) => {
        console.log(error);
      });
  };

  const showWallet = () => {
    magic.connect.showWallet().catch((e) => {
      console.log(e);
    });
  };

  const disconnect = async () => {
    await magic.connect.disconnect().catch((e) => {
      console.log(e);
    });
    setAccount(null);
  };

  return (
    <div className="App">
      <b>
        NFTZen
      </b>
      <div>
      {!account && (
        <button onClick={login} className="button-row">
          Sign In
        </button>
      )}

      {account && (
        <>
          <button onClick={showWallet} className="button-row">
            Show Wallet
          </button>
          {!isUpdating ? ( 
          <button onClick={updateTimestamp} className="button-row">
            Feed
          </button>) : (<div>Loading...</div>)}
          <div className="button-row">{utcToDate(timestamp)}</div>
          <div className="button-row">{'Max food: '+ maxFood}</div>
          <div className="button-row">{'Consumed food per second: '+ foodConsumedPerSecond}</div>
          {/* <div className="button-row">{'Elapsed time: '+ getElapsedTime(timestamp)}</div> */}
          <div className="button-row">{'Remaining food: ' +food}</div>
          <div className="button-row">{renderCharacter(getFood(timestamp,maxFood,foodConsumedPerSecond))}</div>
          <button onClick={disconnect} className="button-row">
            Disconnect
          </button>
        </>
      )}
      </div>
    </div>
  );
}

function renderCharacter(health){
  if(health>100){
    return ':)'
  }else if(health<=100 && health >50){
    return ':|'
  }else if(health<=50 && health >0){
    return ':('
  }else{
    return 'RIP'
  }
}

function getFood(timestamp, maxFood, foodConsumedPerSecond){
  let remainingHealth = maxFood - foodConsumedPerSecond*(getElapsedTime(timestamp));
  return remainingHealth > 0 ? remainingHealth : 0;
}

function getElapsedTime(timestamp){
  let lastFed = new Date(0);
  lastFed.setUTCSeconds(timestamp);
  let currentDateTime = new Date();
  let elapsedTime = Math.floor((currentDateTime.getTime()-lastFed.getTime())/1000);
  return elapsedTime;
}

function utcToDate(elapsedTime){
  var d = new Date(0);
  d.setUTCSeconds(elapsedTime)
  return 'Last fed: ' + d.toString()
}


export default App;
