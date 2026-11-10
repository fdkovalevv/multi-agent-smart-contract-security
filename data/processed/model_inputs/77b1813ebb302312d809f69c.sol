contract TokenTraderFactory {

    event TradeListing(bytes32 bookid, address owner, address addr);
    event NewBook(bytes32 bookid, address asset, uint256 units);

    mapping( address => bool ) public verify;
    mapping( bytes32 => bool ) pairExits;

    function createTradeContract(       
        address _asset, 
        uint256 _buyPrice, 
        uint256 _sellPrice, 
        uint256 _units,
        bool    _sellsTokens,
        bool    _buysTokens
        ) returns (address) 
    {
        if(_buyPrice > _sellPrice) throw;                              
        if(_units == 0) throw;                                      

        address trader = new TokenTrader (
                     _asset, 
                     _buyPrice, 
                     _sellPrice, 
                     _units,
                     _sellsTokens,
                     _buysTokens);

        var bookid = sha3(_asset,_units);

        verify[trader] = true;                                               

        TokenTrader(trader).transferOwnership(msg.sender);                                                

        if(pairExits[bookid] == false) {
            pairExits[bookid] = true;
            NewBook(bookid, _asset, _units);
        }

        TradeListing(bookid,msg.sender,trader);
    }

    function () {
        throw;                                                           
    }
}