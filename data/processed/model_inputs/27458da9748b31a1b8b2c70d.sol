contract NamiExchange {
    using SafeMath for uint;
    
    function NamiExchange(address _namiAddress) public {
        NamiAddr = _namiAddress;
    }

    event UpdateBid(address owner, uint price, uint balance);
    event UpdateAsk(address owner, uint price, uint volume);

    
    mapping(address => OrderBid) public bid;
    mapping(address => OrderAsk) public ask;
    string public name = "NacExchange";
    
                             
    address NamiAddr;
    
                              
    uint public price = 1;
    uint public etherBalance=0;
    uint public nacBalance=0;
                                 
    struct OrderBid {
        uint price;
        uint eth;
    }
    
    struct OrderAsk {
        uint price;
        uint volume;
    }
    
        
                         
    function() payable public {
        require(msg.value > 0);
        if (bid[msg.sender].price > 0) {
            bid[msg.sender].eth = (bid[msg.sender].eth).add(msg.value);
            etherBalance = etherBalance.add(msg.value);
            UpdateBid(msg.sender, bid[msg.sender].price, bid[msg.sender].eth);
        } else {
                     
            msg.sender.transfer(msg.value);
        }
               
                                                                       
                                    
    }

                         
    function tokenFallback(address _from, uint _value, bytes _data) public returns (bool success) {
        require(_value > 0 && _data.length == 0);
        if (ask[_from].price > 0) {
            ask[_from].volume = (ask[_from].volume).add(_value);
            nacBalance = nacBalance.add(_value);
            UpdateAsk(_from, ask[_from].price, ask[_from].volume);
            return true;
        } else {
                    
            ERC23 asset = ERC23(NamiAddr);
            asset.transfer(_from, _value);
            return false;
        }
    }
    
    modifier onlyNami {
        require(msg.sender == NamiAddr);
        _;
    }
    
    
                     
                                                                                          
    
    function placeBuyOrder(uint _price) payable public {
        require(_price > 0);
        if (msg.value > 0) {
            etherBalance += msg.value;
            bid[msg.sender].eth = (bid[msg.sender].eth).add(msg.value);
            UpdateBid(msg.sender, _price, bid[msg.sender].eth);
        }
        bid[msg.sender].price = _price;
    }
    
    function tokenFallbackBuyer(address _from, uint _value, address _buyer) onlyNami public returns (bool success) {
        ERC23 asset = ERC23(NamiAddr);
        uint currentEth = bid[_buyer].eth;
        if ((_value.div(bid[_buyer].price)) > currentEth) {
            if (_from.send(currentEth) && asset.transfer(_buyer, currentEth.mul(bid[_buyer].price)) && asset.transfer(_from, _value - (currentEth.mul(bid[_buyer].price) ) ) ) {
                bid[_buyer].eth = 0;
                etherBalance = etherBalance.sub(currentEth);
                UpdateBid(_buyer, bid[_buyer].price, bid[_buyer].eth);
                return true;
            } else {
                               
                asset.transfer(_from, _value);
                return false;
            }
        } else {
            uint eth = _value.div(bid[_buyer].price);
            if (_from.send(eth) && asset.transfer(_buyer, _value)) {
                bid[_buyer].eth = (bid[_buyer].eth).sub(eth);
                etherBalance = etherBalance.sub(eth);
                UpdateBid(_buyer, bid[_buyer].price, bid[_buyer].eth);
                return true;
            } else {
                               
                asset.transfer(_from, _value);
                return false;
            }
        }
    }
    
    function closeBidOrder() public {
        require(bid[msg.sender].eth > 0 && bid[msg.sender].price > 0);
        msg.sender.transfer(bid[msg.sender].eth);
        etherBalance = etherBalance.sub(bid[msg.sender].eth);
        bid[msg.sender].eth = 0;
        UpdateBid(msg.sender, bid[msg.sender].price, bid[msg.sender].eth);
    }
    

                    
                                                                                          
                                              
    
    function tokenFallbackExchange(address _from, uint _value, uint _price) onlyNami public returns (bool success) {
        require(_price > 0);
        if (_value > 0) {
            nacBalance = nacBalance.add(_value);
            ask[_from].volume = (ask[_from].volume).add(_value);
            ask[_from].price = _price;
            UpdateAsk(_from, _price, ask[_from].volume);
            return true;
        } else {
            ask[_from].price = _price;
            return false;
        }
    }
    
    function closeAskOrder() public {
        require(ask[msg.sender].volume > 0 && ask[msg.sender].price > 0);
        ERC23 asset = ERC23(NamiAddr);
        if (asset.transfer(msg.sender, ask[msg.sender].volume)) {
            nacBalance = nacBalance.sub(ask[msg.sender].volume);
            ask[msg.sender].volume = 0;
            UpdateAsk(msg.sender, ask[msg.sender].price, 0);
        }
    }
    
    function buyNac(address _seller) payable public returns (bool success) {
        require(msg.value > 0 && ask[_seller].volume > 0 && ask[_seller].price > 0);
        ERC23 asset = ERC23(NamiAddr);
        uint maxEth = (ask[_seller].volume).div(ask[_seller].price);
        if (msg.value > maxEth) {
            if (_seller.send(maxEth) && msg.sender.send(msg.value.sub(maxEth)) && asset.transfer(msg.sender, ask[_seller].volume)) {
                nacBalance = nacBalance.sub(ask[_seller].volume);
                ask[_seller].volume = 0;
                UpdateAsk(_seller, ask[_seller].price, 0);
                return true;
            } else {
                        
                return false;
            }
        } else {
            if (_seller.send(msg.value) && asset.transfer(msg.sender, (msg.value).mul(ask[_seller].price))) {
                uint nac = (msg.value).mul(ask[_seller].price);
                nacBalance = nacBalance.sub(nac);
                ask[_seller].volume = (ask[_seller].volume).sub(nac);
                UpdateAsk(_seller, ask[_seller].price, ask[_seller].volume);
                return true;
            } else {
                        
                return false;
            }
        }
    }
}