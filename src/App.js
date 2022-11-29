import './App.css';
import { useState, useEffect } from "react";
import { Magic } from "magic-sdk";
import { ConnectExtension } from "@magic-ext/connect";
import Web3 from "web3";
import {abi} from "./contract/abi"

const magic = new Magic("pk_live_73AAE8A5F81B1CF3", {
  network: "goerli",
  locale: "en_US",
  extensions: [new ConnectExtension()]
});
const web3 = new Web3(magic.rpcProvider);
const contractAddress ='0x4F2200E53F90fDFd1E2ebcD05A221596bc545897'

const animalMapping = ['monkey', 'penguin', 'dog', 'turtle']

function App() {
  const [account, setAccount] = useState(null);
  const [isUpdating, setIsUpdating] = useState(false);
  const [citizens, setCitizens] = useState([]);
  const [owned, setOwned] = useState([]);

  useEffect(() => {
    console.log('Mounted')
    getCitizens();
  },[]);

  const getCitizens = async () => {
    console.log('About to fetch latest citizens')
    const contract = new web3.eth.Contract(abi, contractAddress);
    contract.methods.getAllTokens().call().then(setCitizens)
    console.log('updated')
  }

  const getOwnedCitizens = async (account) => {
    console.log('About to fetch users citizens')
    const contract = new web3.eth.Contract(abi, contractAddress);
    console.log(account)
    let receupt = await contract.methods.getAllOwnedTokenIDs().call({ from: account }).then(setOwned);
    console.log('updated')
  }

  const mint = async () => {
    console.log('calling mint contract')
    setIsUpdating(true)
    const contract = new web3.eth.Contract(abi, contractAddress);
    const receipt = await contract.methods.mint().send({ from: account });
    console.log(receipt)
    setIsUpdating(false)
    getCitizens();
    getOwnedCitizens(account);
  };

  const feed = async (tokenId) => {
    console.log('calling feed contract')
    setIsUpdating(true)
    const contract = new web3.eth.Contract(abi, contractAddress);
    const receipt = await contract.methods.feed(tokenId).send({ from: account });
    console.log(receipt)
    setIsUpdating(false)
    getCitizens();
  };

  const clean = async (tokenId) => {
    console.log('calling clean contract')
    setIsUpdating(true)
    const contract = new web3.eth.Contract(abi, contractAddress);
    const receipt = await contract.methods.clean(tokenId).send({ from: account });
    console.log(receipt)
    setIsUpdating(false)
    getCitizens();
  };
 
  const login = async () => {
    web3.eth
      .getAccounts()
      .then((accounts) => {
        console.log(accounts)
        setAccount(accounts?.[0]);
        getOwnedCitizens(accounts?.[0]);
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
      <div>
      {!account && (
        <button onClick={login} className="wallet-button">
          Sign In
        </button>
      )}

      <div className="headline">
        NFTZen
      </div>
      {account && (
        <>
          <div><button onClick={showWallet} className="wallet-button">
            Show Wallet
          </button></div>
          {!isUpdating || citizens.length<=4 ? ( 
          <div><button onClick={mint} className="citizen-button">
            Mint
          </button></div>) : (<div>Loading...</div>)}
          <div className="citizens-container">{renderCitizens(citizens, owned, feed, clean)}</div>
          <div><a className="button-row" href={"https://goerli.etherscan.io/address/"+contractAddress}>See contract</a></div>
          <div><button onClick={disconnect} className="wallet-button">
            Disconnect
          </button></div>
        </>
      )}
      </div>
    </div>
  );
}

function renderCitizens(citizens, owned, feed, clean){
  if(citizens.length===0){
    return ''
  }
  let mappedCitizens = citizens.map((citizen, i) => {
    let canClean = getHealth(parseInt(citizen[1]), parseInt(citizen[2])) < 0 ? true: false;
    let isOwner = owned.includes(citizen[0]);
    return <div className="citizen-container">
          <div>
            <div><b>ID: </b>{citizen[0]}</div>
            <div><b>Animal: </b>{animalMapping[citizen[3]]}</div>
            <div><b>Status: </b>{renderStatus(parseInt(citizen[1]),parseInt(citizen[2]))}</div>
            <div><i>Feed by: </i>{utcToDate(parseInt(citizen[1])+parseInt(citizen[2]))}</div>
            {isOwner ? '*you own this NFT' : ''}
          </div>
          {isOwner ? <button className="citizen-button" onClick={(e)=>feed(citizen[0])}>feed</button > : ''}
          {canClean ? <button className="citizen-button" onClick={(e)=>clean(citizen[0])}>remove</button> : ''}
        </div>;
  });

  return mappedCitizens;
}

function getHealth(lastFedTime, maxTime){
  let elapsedTime = getElapsedTime(lastFedTime);
  let health = Math.floor( (maxTime - elapsedTime)/3600)
  return health;
}

function renderStatus(lastFedTime, maxTime){
  let health = getHealth(lastFedTime, maxTime)

  if(health>20){
    return '=)'
  }else if(health<=20 && health >12){
    return '=|'
  }else if(health<=12 && health >0){
    return '=('
  }else{
    return 'RIP'
  }
}

function getElapsedTime(lastFedTime){
  let lastFed = new Date(0);
  lastFed.setUTCSeconds(lastFedTime);
  let currentDateTime = new Date();
  let elapsedTime = Math.floor((currentDateTime.getTime()-lastFed.getTime())/1000);
  return elapsedTime;
}

function utcToDate(elapsedTime){
  var d = new Date(0);
  d.setUTCSeconds(elapsedTime)
  return d.toLocaleString()
}

  //use this if you want a live ticker
  // useEffect(() => {    
  //   const intervalId = setInterval(() => {
  //     let latestFood = getFood(timestamp, maxFood, foodConsumedPerSecond)
  //     setFood(latestFood)
  //   }, 1000);
  //   return () => clearInterval(intervalId);
  // }, [food, timestamp]);

export default App;
