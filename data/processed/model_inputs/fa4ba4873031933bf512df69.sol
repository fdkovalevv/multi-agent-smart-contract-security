contract AtomicSwap {
  struct Swap {
    uint expiration;
    address initiator;
    address participant;
    uint256 value;
    bool isToken;
    address token;
    bool exists;
  }

                                                     
  mapping(address => mapping(bytes20 => Swap)) public swaps;

  function initiate(uint _expiration, bytes20 _hash, address _participant, address _token, bool _isToken, uint256 _value) payable public {
    Swap storage s = swaps[_participant][_hash];
                                                           
                                                          
    require (s.exists == false);
                                                        
    require (now < _expiration);

    if (_isToken) {
                                                                                          
      ERC20 token = ERC20(_token);
      require(token.allowance(msg.sender, this) == _value);
      token.transferFrom(msg.sender, this, _value);
    }
                          
    swaps[_participant][_hash] = Swap(_expiration, msg.sender, _participant, _isToken ? _value : msg.value, _isToken, _token, true);
  }

  function redeem(bytes32 _secret) public {
                                                                                     
                       
    bytes20 hash = ripemd160(_secret);
    Swap storage s = swaps[msg.sender][hash];
    
                                                      
    require(s.exists);
                                                
    require(now < s.expiration);
    
                        
    s.exists = false;
    if (s.isToken) {
      ERC20 token = ERC20(s.token);
      token.transfer(msg.sender, s.value);
    } else {
      msg.sender.transfer(s.value);
    }
  }

  function refund(bytes20 _hash, address _participant) public {
    Swap storage s = swaps[_participant][_hash];
                                                
    require(now > s.expiration);
                                                            
    require(msg.sender == s.initiator);
                                                      
    require(s.exists);

    s.exists = false;
    if (s.isToken) {
      ERC20 token = ERC20(s.token);
      token.transfer(msg.sender, s.value);
    } else {
      msg.sender.transfer(s.value);
    }
  }
}