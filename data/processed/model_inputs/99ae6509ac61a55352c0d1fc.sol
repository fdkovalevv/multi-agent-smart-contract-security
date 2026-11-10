contract Owned {
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function Owned() {
        owner = msg.sender;
    }
    
    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
}

contract ERC20Token {
                                                          
                                                             
                     
                               
                                                                     
                                                                            
                                                                      
                             
      
                              
    uint256 public totalSupply;

                                                                          
                           
    function balanceOf(address _owner) constant returns (uint256 balance);

                                                              
                                               
                                                           
                                                          
    function transfer(address _to, uint256 _value) returns (bool success);

                                                                                                    
                                              
                                               
                                                           
                                                          
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

                                                                         
                                                                              
                                                                      
                                                          
    function approve(address _spender, uint256 _value) returns (bool success);

                                                              
                                                                              
                                                           
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract MCTContractToken is ERC20Token, Owned{

                                       
    string  public standard = "Mammoth Casino Contract Token";
    string  public name = "Mammoth Casino Token";
    string  public symbol = "MCT";
    uint8   public decimals = 0;
    address public icoContractAddress;
    uint256 public tokenFrozenUntilTime;
    uint256 public blackListFreezeTime;
    struct frozen {
        bool accountFreeze;
        uint256 freezeUntilTime;
    }
    
                                
    uint256 public totalSupply;
    uint256 public totalRemainSupply;
    uint256 public foundingTeamSupply;
    uint256 public gameDeveloperSupply;
    uint256 public communitySupply;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    mapping (address => frozen) blackListFreezeTokenAccounts;
                
    event mintToken(address indexed _to, uint256 _value);
    event burnToken(address indexed _from, uint256 _value);
    event frozenToken(uint256 _frozenUntilBlock, string _reason);
    
                                                             
    function MCTContractToken(uint256 _totalSupply, address _icoAddress) {
        owner = msg.sender;
        totalSupply = _totalSupply;
        totalRemainSupply = totalSupply;
        foundingTeamSupply = totalSupply * 2 / 10;
        gameDeveloperSupply = totalSupply * 1 / 10;
        communitySupply = totalSupply * 1 / 10;
        icoContractAddress = _icoAddress;
        blackListFreezeTime = 12 hours;
    }

                                               
    function mctTotalSupply() returns (uint256) {   
        return totalSupply - totalRemainSupply;
    }

                                    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

                                                     
    function transfer(address _to, uint256 _value) returns (bool success) {
        require (now > tokenFrozenUntilTime);                               
        require (now > blackListFreezeTokenAccounts[msg.sender].freezeUntilTime);                                                    
        require (now > blackListFreezeTokenAccounts[_to].freezeUntilTime);                                                           
        require (balances[msg.sender] > _value);                                                      
        require (balances[_to] + _value > balances[_to]);                               
        balances[msg.sender] -= _value;                                              
        balances[_to] += _value;                                                    
        Transfer(msg.sender, _to, _value);                                         
        return true;
    }

                                                               
    function approve(address _spender, uint256 _value) returns (bool success) {
        require (now > tokenFrozenUntilTime);                                                  
        allowances[msg.sender][_spender] = _value;                                   
        Approval(msg.sender, _spender, _value);                                             
        return true;
    }

                                                                            
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {            
        tokenRecipient spender = tokenRecipient(_spender);                                                                 
        approve(_spender, _value);                                                                                     
        spender.receiveApproval(msg.sender, _value, this, _extraData);                                               
        return true;     
    }     

                                              
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {      
        require (now > tokenFrozenUntilTime);                               
        require (now > blackListFreezeTokenAccounts[_to].freezeUntilTime);                                                                 
        require (balances[_from] > _value);                                                                    
        require (balances[_to] + _value > balances[_to]);                                   
        require (_value > allowances[_from][msg.sender]);                                              
        balances[_from] -= _value;                                                       
        balances[_to] += _value;                                                             
        allowances[_from][msg.sender] -= _value;                                                         
        Transfer(_from, _to, _value);                                              
        return true;     
    }         

                                                        
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {         
        return allowances[_owner][_spender];
    }         

                               
    function mintTokens(address _to, uint256 _amount) {         
        require (msg.sender == icoContractAddress);                                                        
        require (now > blackListFreezeTokenAccounts[_to].freezeUntilTime);                                                                                   
        require (balances[_to] + _amount > balances[_to]);                            
        require (totalRemainSupply > _amount);
        totalRemainSupply -= _amount;                                                 
        balances[_to] += _amount;                                                            
        mintToken(_to, _amount);                                                           
        Transfer(0x0, _to, _amount);                                                            
    }     
  
                                            
    function burnTokens(address _addr, uint256 _amount) onlyOwner {
        require (balances[msg.sender] < _amount);                                                         
        totalRemainSupply += _amount;                                                
        balances[_addr] -= _amount;                                                               
        burnToken(_addr, _amount);                                                 
        Transfer(_addr, 0x0, _amount);                                                  
    }
    
                                            
    function burnLeftTokens() onlyOwner {
        require (totalRemainSupply > 0);
        totalRemainSupply = 0;
    }
    
                                                        
    function freezeTransfersUntil(uint256 _frozenUntilTime, string _freezeReason) onlyOwner {      
        tokenFrozenUntilTime = _frozenUntilTime;
        frozenToken(_frozenUntilTime, _freezeReason);
    }
    
                                                         
    function freezeAccounts(address _freezeAddress, bool _freeze) onlyOwner {
        blackListFreezeTokenAccounts[_freezeAddress].accountFreeze = _freeze;
        blackListFreezeTokenAccounts[_freezeAddress].freezeUntilTime = now + blackListFreezeTime;
    }
    
                           
    function mintUnICOLeftToken(address _foundingTeamAddr, address _gameDeveloperAddr, address _communityAddr) onlyOwner {
        balances[_foundingTeamAddr] += foundingTeamSupply;                                                
        balances[_gameDeveloperAddr] += gameDeveloperSupply;                                               
        balances[_communityAddr] += communitySupply;                                                   
        totalRemainSupply -= (foundingTeamSupply + gameDeveloperSupply + communitySupply);
        mintToken(_foundingTeamAddr, foundingTeamSupply);                                       
        mintToken(_gameDeveloperAddr, gameDeveloperSupply);                               
        mintToken(_communityAddr, communitySupply);                                       
    }
    
}