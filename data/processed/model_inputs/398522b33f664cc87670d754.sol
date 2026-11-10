contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }

     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

     
                                            
    
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

     
                                               
                                          
                                               
    
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

                                                              
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

     
                                                   
                                                          
                                                                           
    
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


     
                                                     
                                                                        
                                                                 
                                                                 
     
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

     
                                                                                                     
    
                                                                                                         
                                                                                                      
                                                                                                         
                                                                      
                                                            
                                                    
     
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

     
                                                                                    
                                                            
                                                                    
                                                                                       
     
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

     
                                                                           
    
                                                                       
                                                                                  
                                    
                               
                                                            
                                                                          
     
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

     
                                                                           
    
                                                                       
                                                                                  
                                    
                               
                                                            
                                                                               
     
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

     
                                 
                                                                
                                                 
                                                                      
     
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

     
                                              
                                                  
     
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract CappedToken is MintableToken {

  uint256 public cap;

  function CappedToken(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

     
                                 
                                                                
                                                 
                                                                      
     
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
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

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract InsightsNetwork2Base is DetailedERC20("Insights Network", "INSTAR", 18), PausableToken, CappedToken{

    uint256 constant ATTOTOKEN_FACTOR = 10**18;

    address public predecessor;
    address public successor;

    uint constant MAX_PURCHASES = 64;
    mapping (address => uint256[]) public lockedBalances;
    mapping (address => uint256[]) public unlockTimes;
    mapping (address => bool) public imported;

    event Import(address indexed account, uint256 amount, uint256 unlockTime);    

    function InsightsNetwork2Base() public CappedToken(300*1000000*ATTOTOKEN_FACTOR) {
        paused = true;
        mintingFinished = true;
    }

    function activate(address _predecessor) public onlyOwner {
        require(predecessor == 0);
        require(_predecessor != 0);
        require(predecessorDeactivated(_predecessor));
        predecessor = _predecessor;
        unpause();
        mintingFinished = false;
    }

    function lockedBalanceOf(address account) public view returns (uint256 balance) {
        uint256 amount;
        for (uint256 index = 0; index < lockedBalances[account].length; index++)
            if (unlockTimes[account][index] > now)
                amount += lockedBalances[account][index];
        return amount;
    }

    function mintUnlockTime(address account, uint256 amount, uint256 unlockTime) public onlyOwner canMint returns (bool) {
        require(unlockTime > now);
        require(lockedBalances[account].length < MAX_PURCHASES);
        lockedBalances[account].push(amount);
        unlockTimes[account].push(unlockTime);
        return super.mint(account, amount);
    }

    function mintLockPeriod(address account, uint256 amount, uint256 lockPeriod) public onlyOwner canMint returns (bool) {
        return mintUnlockTime(account, amount, now + lockPeriod);
    }

    function mint(address account, uint256 amount) public onlyOwner canMint returns (bool) {
        return mintLockPeriod(account, amount, 1 years);
    }

    function importBalanceOf(address account) public onlyOwner canMint returns (bool);

    function importBalancesOf(address[] accounts) public onlyOwner canMint returns (bool) {
        require(accounts.length <= 1024);
        for (uint index = 0; index < accounts.length; index++)
            require(importBalanceOf(accounts[index]));
        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender] - lockedBalanceOf(msg.sender));
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= balances[from] - lockedBalanceOf(from));
        return super.transferFrom(from, to, value);
    }

    function selfDestruct(address _successor) public onlyOwner whenPaused {
        require(mintingFinished);
        successor = _successor;
        selfdestruct(owner);
    }

    function predecessorDeactivated(address _predecessor) internal onlyOwner returns (bool);

}

contract InsightsNetwork3 is InsightsNetwork2Base {

    function importBalanceOf(address account) public onlyOwner canMint returns (bool) {
        require(!imported[account]);
        InsightsNetwork2Base source = InsightsNetwork2Base(predecessor);
        uint256 amount = source.balanceOf(account);
        require(amount > 0);
        imported[account] = true;
        for (uint index = 0; amount > 0; index++) {
            uint256 mintAmount = source.lockedBalances(account, index);
            uint256 unlockTime = source.unlockTimes(account, index);
            Import(account, mintAmount, unlockTime);
            assert(mintUnlockTime(account, mintAmount, unlockTime));
            amount -= mintAmount;
        }
        return true;
    }

    function predecessorDeactivated(address _predecessor) internal onlyOwner returns (bool) {
        return InsightsNetwork2Base(_predecessor).paused() && InsightsNetwork2Base(_predecessor).mintingFinished();
    }

}