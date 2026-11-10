contract pricegeth {

    struct Feed {
      uint    USDBTC;
      uint40    BTCETH;
      uint40    BTCETC;
      uint40    BTCDOGE;
                      
      uint40  timestamp;
      uint    blockNumber;
                                                                                                                       
    }

    mapping (uint => Feed) priceHistory;
    uint public lastBlock;                                                                            
                                                                                                               
    uint40 public firstBlock;

    address feedOwner;

                                                                                   
    function getPrices() constant returns (uint, uint, uint, uint, uint, uint) {
      return (priceHistory[lastBlock].USDBTC, priceHistory[lastBlock].BTCETH, priceHistory[lastBlock].BTCETC, priceHistory[lastBlock].BTCDOGE, priceHistory[lastBlock].blockNumber, priceHistory[lastBlock].timestamp);
    }
                                                                       
    function getPrices(uint blockNumber) constant returns (uint, uint, uint, uint, uint, uint) {
      return (priceHistory[blockNumber].USDBTC, priceHistory[blockNumber].BTCETH, priceHistory[blockNumber].BTCETC, priceHistory[blockNumber].BTCDOGE, priceHistory[blockNumber].blockNumber, priceHistory[blockNumber].timestamp);
    }

                                                              
    function USDBTC(uint blockNumber) constant returns (uint, uint, uint) {
      return (priceHistory[blockNumber].USDBTC, priceHistory[blockNumber].timestamp, priceHistory[blockNumber].blockNumber);
    }
    function BTCETH(uint blockNumber) constant returns (uint, uint, uint) {
      return (priceHistory[blockNumber].BTCETH, priceHistory[blockNumber].timestamp, priceHistory[blockNumber].blockNumber);
    }
    function BTCETC(uint blockNumber) constant returns (uint, uint, uint) {
      return (priceHistory[blockNumber].BTCETC, priceHistory[blockNumber].timestamp, priceHistory[blockNumber].blockNumber);
    }
    function BTCDOGE(uint blockNumber) constant returns (uint, uint, uint) {
      return (priceHistory[blockNumber].BTCDOGE, priceHistory[blockNumber].timestamp, priceHistory[blockNumber].blockNumber);
    }
    function timestamp(uint blockNumber) constant returns (uint40) {                     
        return priceHistory[blockNumber].timestamp;
    }

                 
    function pricegeth(){
      feedOwner = msg.sender;
      lastBlock = 0;                                                                      
    }

                                                                       
    modifier ifOwner() { if (msg.sender != feedOwner) throw; _ ;}

             
                                                                                                           
    event PriceUpdated(uint timestamp, uint blocknumber, uint USDBTC, uint BTCETH, uint BTCETC, uint BTCDOGE);

                                                                        
                          
                                                                        

    function setPrice(uint40 timestamp, uint40 blocknumber, uint USDBTC, uint40 BTCETH, uint40 BTCETC, uint40 BTCDOGE) ifOwner() {
      if (firstBlock == 0) firstBlock = blocknumber;
      lastBlock = blocknumber;                                                         
                                                                                              
      priceHistory[lastBlock].timestamp = timestamp;               
      priceHistory[lastBlock].blockNumber = blocknumber;                
                                             
      priceHistory[lastBlock].USDBTC = USDBTC;
      priceHistory[lastBlock].BTCETH = BTCETH;
      priceHistory[lastBlock].BTCETC = BTCETC;
      priceHistory[lastBlock].BTCDOGE = BTCDOGE;
      PriceUpdated(timestamp, blocknumber, USDBTC, BTCETH, BTCETC, BTCDOGE);
    }

    function queryTimestamp(uint40 timestamp) constant returns(uint, uint) {
                                                                                            
      Feed memory temp;
      temp = priceHistory[firstBlock];
      for (uint i = 0; i < lastBlock; i++) {
        if ((timestamp >= temp.timestamp) && (timestamp < priceHistory[firstBlock + i].timestamp))
        {
          break;
        }
        if ((timestamp > temp.timestamp) && (timestamp >= priceHistory[firstBlock + i].timestamp))
        {
          temp = priceHistory[firstBlock + i];
        }
      }
    return (temp.blockNumber, temp.timestamp);
    }

    function recoverFunds(uint amount) ifOwner() returns(bool) {
      return (feedOwner.send(amount));                                                                   
    }

                       
    function() { throw; }


}