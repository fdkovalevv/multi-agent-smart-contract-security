contract ShiftSale {

    Crowdsale public crowdSale;
    Token public token;

    address public crowdSaleAddress;
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public fee;
      
                 
       
    uint constant public MAX_OWNER_COUNT = 10;

    event FundTransfer(uint amount);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);

                                                                                                                     
                                                            
                                                    
                                                               
                                                                         
    function ShiftSale(
        address _crowdSale,
        address _token,
        address[] _owners,
        uint _fee
    ) public {
        crowdSaleAddress = _crowdSale;
        crowdSale = Crowdsale(_crowdSale);
        token = Token(_token);
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        fee = _fee;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }
    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }
    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }
    modifier validAmount() {
        require((msg.value - fee) > 0);
        _;
    }

       
                        
      
                                                                                                                 
       
    function()
    payable
    public
    validAmount
    {
        if(crowdSale.shiftSalePurchase.value(msg.value - fee)()){
            FundTransfer(msg.value - fee);
        }
    }

                                    
                                        
    function getOwners()
    public
    constant
    returns (address[])
    {
        return owners;
    }
                                                                             
                                       
                                                         
    function transfer(address _to, uint256 _value)
    ownerExists(msg.sender)
    public {
        token.transfer(_to, _value);
    }
                                                                                                            
    function withdrawal()
    ownerExists(msg.sender)
    public {
        crowdSale.safeWithdrawal();
    }
                                                                                                     
                                       
                                      
    function refund(address _to, uint256 _value)
    ownerExists(msg.sender)
    public {
        _to.transfer(_value);
    }
                                                                                                       
                                                  
                                               
    function refundMany(address[] _to, uint256[] _value)
    ownerExists(msg.sender)
    public {
        require(_to.length == _value.length);
        for (uint i = 0; i < _to.length; i++) {
            _to[i].transfer(_value[i]);
        }
    }
                                                                                    
                                          
    function setFee(uint _fee)
    ownerExists(msg.sender)
    public {
        fee = _fee;
    }

                                                                                          
    function empty()
    ownerExists(msg.sender)
    public {
        msg.sender.transfer(this.balance);
    }

}