contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

     
                                                                    
     
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

     
                                                                        
     
  modifier whenPaused {
    require (paused) ;
    _;
  }

     
                                                              
     
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

     
                                                                 
     
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

}

contract StandardToken is ERC20, SafeMath {

     
                                                 
     
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4);
     _;
  }

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32)  returns (bool success){
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

                                                                                                              
                                      

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

contract HelloGoldToken is ERC20, SafeMath, Pausable, StandardToken {

  string public name;
  string public symbol;
  uint8  public decimals;

  GBT  goldtoken;
  

  function setGBT(address gbt_) onlyOwner {
    goldtoken = GBT(gbt_);
  }

  function GBTAddress() constant returns (address) {
    return address(goldtoken);
  }

  function HelloGoldToken(address _reserve) {
    name = "HelloGold Token";
    symbol = "HGT";
    decimals = 8;
 
    totalSupply = 1 * 10 ** 9 * 10 ** uint256(decimals);
    balances[_reserve] = totalSupply;
  }


  function parentChange(address _to) internal {
    require(address(goldtoken) != 0x0);
    goldtoken.parentChange(_to,balances[_to]);
  }
  function parentFees(address _to) internal {
    require(address(goldtoken) != 0x0);
    goldtoken.parentFees(_to);
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
    parentFees(_from);
    parentFees(_to);
    success = super.transferFrom(_from,_to,_value);
    parentChange(_from);
    parentChange(_to);
    return;
  }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    parentFees(msg.sender);
    parentFees(_to);
    success = super.transfer(_to,_value);
    parentChange(msg.sender);
    parentChange(_to);
    return;
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
  }
}