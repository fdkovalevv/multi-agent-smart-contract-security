contract Ownable {
  address public owner;


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) external onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

     
                                               
                                          
                                               
    
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

     
                                                   
                                                          
                                                                           
    
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


     
                                                     
                                                                        
                                                                 
                                                               
     
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

                                                                                                          
                                      

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

     
                                                                                                    
                                                            
                                                    
     
  function approve(address _spender, uint256 _value) public returns (bool) {

                                                                           
                                                                        
                                                                
                                                                         
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

     
                                                                                    
                                                            
                                                                    
                                                                                    
     
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract Manageable is Ownable {

               

  mapping (address => bool) managerEnabled;                                       
  mapping (address => mapping (string => bool)) managerPermissions;                                              


              

  event ManagerEnabledEvent(address indexed manager);
  event ManagerDisabledEvent(address indexed manager);
  event ManagerPermissionGrantedEvent(address indexed manager, string permission);
  event ManagerPermissionRevokedEvent(address indexed manager, string permission);


                          

     
                                     
                                        
     
  function enableManager(address _manager) external onlyOwner onlyValidAddress(_manager) {
    require(managerEnabled[_manager] == false);

    managerEnabled[_manager] = true;
    ManagerEnabledEvent(_manager);
  }

     
                                             
                                             
     
  function disableManager(address _manager) external onlyOwner onlyValidAddress(_manager) {
    require(managerEnabled[_manager] == true);

    managerEnabled[_manager] = false;
    ManagerDisabledEvent(_manager);
  }

     
                                                         
                                                    
                                                           
     
  function grantManagerPermission(
    address _manager, string _permissionName
  )
    external
    onlyOwner
    onlyValidAddress(_manager)
    onlyValidPermissionName(_permissionName)
  {
    require(managerPermissions[_manager][_permissionName] == false);

    managerPermissions[_manager][_permissionName] = true;
    ManagerPermissionGrantedEvent(_manager, _permissionName);
  }

     
                                                      
                                                    
                                                           
     
  function revokeManagerPermission(
    address _manager, string _permissionName
  )
    external
    onlyOwner
    onlyValidAddress(_manager)
    onlyValidPermissionName(_permissionName)
  {
    require(managerPermissions[_manager][_permissionName] == true);

    managerPermissions[_manager][_permissionName] = false;
    ManagerPermissionRevokedEvent(_manager, _permissionName);
  }


               

     
                                          
                                              
                                       
     
  function isManagerEnabled(address _manager) public constant onlyValidAddress(_manager) returns (bool) {
    return managerEnabled[_manager];
  }

     
                                                    
                                                     
                                                   
                                                               
     
  function isPermissionGranted(
    address _manager, string _permissionName
  )
    public
    constant
    onlyValidAddress(_manager)
    onlyValidPermissionName(_permissionName)
    returns (bool)
  {
    return managerPermissions[_manager][_permissionName];
  }

     
                                                                        
                                                     
                                                   
                                                                              
     
  function isManagerAllowed(
    address _manager, string _permissionName
  )
    public
    constant
    onlyValidAddress(_manager)
    onlyValidPermissionName(_permissionName)
    returns (bool)
  {
    return (managerEnabled[_manager] && managerPermissions[_manager][_permissionName]);
  }


               

     
                                           
     
  modifier onlyValidAddress(address _manager) {
    require(_manager != address(0x0));
    _;
  }

     
                                                      
     
  modifier onlyValidPermissionName(string _permissionName) {
    require(bytes(_permissionName).length != 0);
    _;
  }


               

     
                                              
     
  modifier onlyAllowedManager(string _permissionName) {
    require(isManagerAllowed(msg.sender, _permissionName) == true);
    _;
  }
}

contract Pausable is Manageable {

     
           
     

  event PauseEvent();
  event UnpauseEvent();


     
            
     

  bool paused = true;


     
                                                                    
     
  modifier whenContractNotPaused() {
    require(paused == false);
    _;
  }

     
                                                                        
     
  modifier whenContractPaused {
    require(paused == true);
    _;
  }

     
                                                                
     
  function pauseContract() external onlyAllowedManager('pause_contract') whenContractNotPaused {
    paused = true;
    PauseEvent();
  }

     
                                                                   
     
  function unpauseContract() external onlyAllowedManager('unpause_contract') whenContractPaused {
    paused = false;
    UnpauseEvent();
  }

     
                                                   
     
  function getPaused() external constant returns (bool) {
    return paused;
  }
}

contract NamedToken {
  string public name;
  string public symbol;
  uint8 public decimals;

  function NamedToken(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }

     
                                                         
                                                                                                                             
                                     
     
  function getNameHash() external constant returns (bytes32 result){
    return keccak256(name);
  }

     
                                                           
                                                                                                                               
                                       
     
  function getSymbolHash() external constant returns (bytes32 result){
    return keccak256(symbol);
  }
}

contract AngelToken is StandardToken, NamedToken, Pausable {

              

  event MintEvent(address indexed account, uint value);
  event BurnEvent(address indexed account, uint value);
  event SpendingBlockedEvent(address indexed account);
  event SpendingUnblockedEvent(address indexed account);


               

  address public centralBankAddress = 0x0;
  mapping (address => uint) spendingBlocksNumber;


                   

  function AngelToken() public NamedToken('Angel Token', 'ANGL', 18) {
    centralBankAddress = msg.sender;
  }


               

  function transfer(address _to, uint _value) public returns (bool) {
    if (_to != centralBankAddress) {
      require(!paused);
    }
    require(spendingBlocksNumber[msg.sender] == 0);

    bool result = super.transfer(_to, _value);
    if (result == true && _to == centralBankAddress) {
      AngelCentralBank(centralBankAddress).angelBurn(msg.sender, _value);
    }
    return result;
  }

  function approve(address _spender, uint _value) public whenContractNotPaused returns (bool){
    return super.approve(_spender, _value);
  }

  function transferFrom(address _from, address _to, uint _value) public whenContractNotPaused returns (bool){
    require(spendingBlocksNumber[_from] == 0);

    bool result = super.transferFrom(_from, _to, _value);
    if (result == true && _to == centralBankAddress) {
      AngelCentralBank(centralBankAddress).angelBurn(_from, _value);
    }
    return result;
  }


  function mint(address _account, uint _value) external onlyAllowedManager('mint_tokens') {
    balances[_account] = balances[_account].add(_value);
    totalSupply = totalSupply.add(_value);
    MintEvent(_account, _value);
    Transfer(address(0x0), _account, _value);                               
  }

  function burn(uint _value) external onlyAllowedManager('burn_tokens') {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    BurnEvent(msg.sender, _value);
  }

  function blockSpending(address _account) external onlyAllowedManager('block_spending') {
    spendingBlocksNumber[_account] = spendingBlocksNumber[_account].add(1);
    SpendingBlockedEvent(_account);
  }

  function unblockSpending(address _account) external onlyAllowedManager('unblock_spending') {
    spendingBlocksNumber[_account] = spendingBlocksNumber[_account].sub(1);
    SpendingUnblockedEvent(_account);
  }
}