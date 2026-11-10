contract Ownable {

         
                                      
        
     address public owner;
    
        
                                                                                
       
     function Ownable() public {
         owner = msg.sender;
     }
    
       
                                                                  
      
     modifier onlyOwner(){
         require(msg.sender == owner);
         _;                                 
     }
    
       
                                                                                   
      
    function transferOwnership(address _newOwner) public onlyOwner {
    
                                          
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }
    }

contract ERC20 {
    
       
                                
      
    function totalSupply() public constant returns (uint256 _totalSupply);
    
       
                                                                    
      
    function balanceOf(address _owner) public constant returns (uint256 balance);
    
       
                                           
      
    function transfer(address _to, uint256 _amount) public returns (bool success);
    
       
                                                              
      
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
    
       
                                                                                      
                                                                                        
                                                          
      
    function approve(address _spender, uint256 _amount) public returns (bool success);
    
       
                                                                                
      
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    
       
                                            
      
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    
       
                                                                              
      
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}

contract CTNToken is ERC20, Ownable {

using QuickMafs for uint256;

string public constant SYMBOL = "CTN";
string public constant NAME = "Crypto Trust Network";
uint8 public constant DECIMALS = 18;

   
                        
  
uint256 totalTokens;

   
                                            
   
uint256 initialSupply;

   
                           
  
mapping(address => uint256) balances;

   
                                                     
  
mapping(address => mapping (address => uint256)) allowed;

   
                           
    
 bool tradable;
 
   
                                        
  
address public vault;

   
                           
  
bool public mintingFinished = false;

   
                                        
   
event Mint(address indexed _to, uint256 _value);

   
                                             
  
event MintFinished();

   
                           
    
event TradableTokens(); 


   
                                              
    
modifier isTradable(){
    require(tradable);
    _;
}

   
                                      
   
modifier canMint() {
    require(!mintingFinished);
    _;
}


   
                                                                                        
  
function CTNToken() public {
    initialSupply = 4500000 * 1 ether;
    totalTokens = initialSupply;
    tradable = false;
    vault = 0x6e794AAA2db51fC246b1979FB9A9849f53919D1E; 
    balances[vault] = balances[vault].add(initialSupply);                                  
}

   
                                       
  
function totalSupply() public constant returns (uint256 totalAmount) {
      totalAmount = totalTokens;
}

   
                                       
  
function baseSupply() public constant returns (uint256 initialAmount) {
      initialAmount = initialSupply;
}

   
                                   
   
function balanceOf(address _address) public constant returns (uint256 balance) {
    return balances[_address];
}


function transfer(address _to, uint256 _amount) public isTradable returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(msg.sender, _to, _amount);
    return true;
}
     
                                                            
                                                                                       
                                                                                          
                                                                                
                                                                                    
                                         
    
  function transferFrom(
      address _from,
      address _to,
      uint256 _amount
 ) public isTradable returns (bool success) 
 {
    var _allowance = allowed[_from][msg.sender];

        
                                                                                       
      
    balances[_to] = balances[_to].add(_amount);
    balances[_from] = balances[_from].sub(_amount);
    allowed[_from][msg.sender] = _allowance.sub(_amount);
    Transfer(_from, _to, _amount);
    return true;  
 }

   
                                                                                                                                        
                                                                                                                         
  
function approve(address _spender, uint256 _amount) public returns (bool) {
       
                                                                                                                           
                                                                                       
      
    require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
}


   
                                                                
   
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
     return allowed[_owner][_spender];
}

   
                                                         
   
function makeTradable() public onlyOwner {
    tradable = true;
    TradableTokens();
}

   
                      
  
function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
    totalTokens = totalTokens.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
}

   
                                              
  
function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
}

}