contract TokenReceiver {
    function onTokenTransfer(address _from, uint256 _value, bytes _data) public;
}

contract Ownable {
  address public owner;


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


     
                                                                                    
     
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

     
                                                                                
     
  modifier whenPaused() {
    require(paused);
    _;
  }

     
                                                              
     
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

     
                                                                 
     
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract AbstractSale is TokenReceiver, Pausable {
    using SafeMath for uint256;

    event BonusChange(uint256 bonus);
    event RateChange(address token, uint256 rate);
    event Purchase(address indexed buyer, address token, uint256 value, uint256 amount);
    event Withdraw(address token, address to, uint256 value);
    event Burn(address token, uint256 value, bytes data);

    mapping (address => uint256) rates;
    uint256 public bonus;

    function onTokenTransfer(address _from, uint256 _value, bytes _data) whenNotPaused public {
        onReceive(msg.sender, _from, _value, _data);
    }

    function() payable whenNotPaused public {
        receiveWithData("");
    }

    function receiveWithData(bytes _data) payable whenNotPaused public {
        onReceive(address(0), msg.sender, msg.value, _data);
    }

    function onReceive(address _token, address _from, uint256 _value, bytes _data) internal {
        uint256 tokens = getAmount(_token, _value);
        require(tokens > 0);
        address buyer;
        if (_data.length == 20) {
            buyer = address(toBytes20(_data, 0));
        } else {
            require(_data.length == 0);
            buyer = _from;
        }
        Purchase(buyer, _token, _value, tokens);
        doPurchase(buyer, tokens);
    }

    function doPurchase(address buyer, uint256 amount) internal;

    function toBytes20(bytes b, uint256 _start) pure internal returns (bytes20 result) {
        require(_start + 20 <= b.length);
        assembly {
            let from := add(_start, add(b, 0x20))
            result := mload(from)
        }
    }

    function getAmount(address _token, uint256 _value) constant public returns (uint256) {
        uint256 rate = getRate(_token);
        require(rate > 0);
        uint256 beforeBonus = _value.mul(rate);
        return beforeBonus.add(beforeBonus.mul(bonus).div(100)).div(10**18);
    }

    function getRate(address _token) constant public returns (uint256) {
        return rates[_token];
    }

    function setRate(address _token, uint256 _rate) onlyOwner public {
        rates[_token] = _rate;
        RateChange(_token, _rate);
    }

    function setBonus(uint256 _bonus) onlyOwner public {
        bonus = _bonus;
        BonusChange(_bonus);
    }

    function withdraw(address _token, address _to, uint256 _amount) onlyOwner public {
        require(_to != address(0));
        verifyCanWithdraw(_token, _to, _amount);
        if (_token == address(0)) {
            _to.transfer(_amount);
        } else {
            ERC20(_token).transfer(_to, _amount);
        }
        Withdraw(_token, _to, _amount);
    }

    function burnWithData(address _token, uint256 _amount, bytes _data) onlyOwner public {
        ExternalToken(_token).burn(_amount, _data);
        Burn(_token, _amount, _data);
    }

    function verifyCanWithdraw(address _token, address _to, uint256 _amount) internal {

    }
}

contract Sale is AbstractSale {
    ERC20 public token;

    function Sale(address _token) public {
        token = ERC20(_token);
    }

    function doPurchase(address buyer, uint256 amount) internal {
        token.transfer(buyer, amount);
    }

       
                                                                         
       
    function verifyCanWithdraw(address _token, address _to, uint256 _amount) internal {
        require(_token != address(token));
    }
}

contract GoldeaSale is Sale {
    address public btcToken;
    uint256 public constant end = 1522540800;
    uint256 public constant total = 200000000000000;

    function GoldeaSale(address _token, address _btcToken) Sale(_token) public {
        btcToken = _btcToken;
    }

    function changeParameters(uint256 _ethRate, uint256 _btcRate, uint256 _bonus) onlyOwner public {
        setRate(address(0), _ethRate);
        setRate(btcToken, _btcRate);
        setBonus(_bonus);
    }

    function setBtcToken(address _btcToken) onlyOwner public {
        btcToken = _btcToken;
    }

    function doPurchase(address buyer, uint256 amount) internal {
        require(now < end);
        super.doPurchase(buyer, amount);
    }

    function burn() onlyOwner public {
        require(now >= end);
        BurnableToken(token).burn(token.balanceOf(this));
    }
}