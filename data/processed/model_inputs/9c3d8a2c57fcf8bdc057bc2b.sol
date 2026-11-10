contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract TokenTrader is owned {

    address public asset;                          
    uint256 public sellPrice;                                                 
    uint256 public units;                              

    bool public sellsTokens;                          

    event ActivatedEvent(bool sells);
    event UpdateEvent();

    function TokenTrader (
        address _asset, 
        uint256 _sellPrice, 
        uint256 _units,
        bool    _sellsTokens
        )
    {
          asset         = _asset; 
          sellPrice    = _sellPrice;
          units         = _units; 
          sellsTokens   = _sellsTokens;

          ActivatedEvent(sellsTokens);
    }

                              
    function activate (
        bool    _sellsTokens
        ) onlyOwner
    {
          sellsTokens   = _sellsTokens;

          ActivatedEvent(sellsTokens);
    }

                                        
    function withdrawAsset(uint256 _value) onlyOwner returns (bool ok)
    {
        return ERC20(asset).transfer(owner,_value);
        UpdateEvent();
    }

                                             
                                                          
    function withdrawToken(address _token, uint256 _value) onlyOwner returns (bool ok)
    {
        return ERC20(_token).transfer(owner,_value);
        UpdateEvent();
    }

                                
    function withdraw(uint256 _value) onlyOwner returns (bool ok)
    {
        if(this.balance >= _value) {
            return owner.send(_value);
        }
        UpdateEvent();
    }

                              
    function buy() payable {
        if(sellsTokens || msg.sender == owner) 
        {
            uint order   = msg.value / sellPrice; 
            uint can_sell = ERC20(asset).balanceOf(address(this)) / units;

            if(order > can_sell)
            {
                uint256 change = msg.value - (can_sell * sellPrice);
                order = can_sell;
                if(!msg.sender.send(change)) throw;
            }

            if(order > 0) {
                if(!ERC20(asset).transfer(msg.sender,order * units)) throw;
            }
            UpdateEvent();
        }
        else if(!msg.sender.send(msg.value)) throw;                                                     
    }

                                                
    function () payable {
        buy();
    }
}