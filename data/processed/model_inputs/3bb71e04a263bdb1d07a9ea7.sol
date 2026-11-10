contract Seglos{

    address Admin;
    CoinbasePriceTicker public PriceContract;
    bool public Open;
    uint public Fee;                                                  
    uint public liquidityPool;                                                  
    uint public tradeId;                                                  
    uint public tradingLimit;

    struct Trade {                              
      address trader;
      uint eth;
      uint time;
      uint exit;
    }

    mapping ( address => uint[] ) private trader;                                        
    mapping ( uint => Trade ) private trades;                                      

    event createTradeEvent(address user, uint tradeId);
    event exitTradeEvent(address user, uint tradeId);

    function Seglos() {
      Admin = msg.sender;
      liquidityPool = 0;
      tradeId = 0;
      Open = true;
      tradingLimit = 1;
      PriceContract = CoinbasePriceTicker("0x1A3f9356356b9423BFb465316e889EBBEBEde1ED");
    }

    function createTrade() payable {
                                                                        

      uint fee = msg.value * Fee / 100000;
      uint eth = msg.value - fee;

      if (!Open)
        throw;                                     

      if (eth < tradingLimit)
        throw;                                                     

      if (liquidityPool < eth)
        throw;                                                      

      liquidityPool = liquidityPool - eth + fee;

      tradeId++;

      trades[tradeId] = Trade(msg.sender, eth*2, getCurrentTimestamp(), 0);

      trader[msg.sender].push(tradeId);

      createTradeEvent(msg.sender, tradeId);
    }

    function exitTrade(uint _trade) {
                                                     

      Trade trade = trades[_trade];
      bool expired = false;
      bool marginCall = false;

      if (trade.exit != 0)
        throw;

      if (now >= trade.time + 1 weeks)
        expired = true;

      if (getCurrentPrice() <= getPrice(trade.time)/2)
        marginCall = true;

                                                                                  
      if ((msg.sender != trade.trader && msg.sender != Admin) && !(expired || marginCall))                        
        throw;

      trade.exit = getCurrentTimestamp();

      if (marginCall){

        liquidityPool = liquidityPool + trade.eth;

      }else {

        uint fundEth = trade.eth * getPrice(trade.time) / (2 * getCurrentPrice());

        liquidityPool = liquidityPool + fundEth;

        uint traderEth = trade.eth - fundEth;

        bool sent = trade.trader.send(traderEth);

        if(!sent)
          throw;

      }

      exitTradeEvent(trade.trader, _trade);
    }

    function getTradersList() constant returns (uint[]) {
                                                               
      return trader[msg.sender];
    }

    function getTrade(uint _trade) constant returns (uint eth, uint time, uint exit) {
                                                                   
      Trade trade = trades[_trade];
      return (trade.eth, trade.time, trade.exit );
    }

    function getCurrentPrice() constant returns (uint currentPrice) {
                                                                          
      return PriceContract.getCurrentPrice();
    }

    function getPrice(uint _time) constant returns (uint price) {
                                                                                       
      return PriceContract.getPrice(_time);
    }

    function getCurrentTimestamp() constant returns (uint currentTimestamp){
                                                                                            
      return PriceContract.getCurrentTimestamp();
    }

    function Door(bool _door){
                                                                                           
      if ( msg.sender != Admin)
          throw;
      Open = _door;
    }

    function setFee(uint _fee) {
                                                              
      if ( msg.sender != Admin)
          throw;
      Fee = _fee;
    }

    function setTradingLimit(uint _limit) {
                                                              
      if ( msg.sender != Admin)
          throw;
      tradingLimit = _limit;
    }

    function depositLiquidity() payable {
      if ( msg.sender != Admin)
          throw;
      liquidityPool = liquidityPool + msg.value;
    }

    function withdrawLiquidity(uint _eth) {

      if ( msg.sender != Admin)
          throw;

      if (liquidityPool < _eth)
          throw;

      liquidityPool = liquidityPool - _eth;

      if(!msg.sender.send(_eth))
        throw;
    }
}