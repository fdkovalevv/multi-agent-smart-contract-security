contract TokenController {
                                                                             
                                                                      
                                                                 
    function proxyPayment(address _owner) payable returns(bool);

                                                                           
                                       
                                               
                                                  
                                                 
                                                                       
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

                                                                      
                                       
                                                        
                                                           
                                                         
                                                                       
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);
}

contract Owned {
                                                                           
                
    modifier onlyOwner { if (msg.sender != owner) throw; _; }

    address public owner;

                                                                        
    function Owned() { owner = msg.sender;}

                                                                                
                                                                                
                                                                
    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
}

contract Campaign is TokenController, Owned {

    uint public startFundingTime;                             
    uint public endFundingTime;                               
    uint public maximumFunding;                  
    uint public totalCollected;                  
    MiniMeToken public tokenContract;                                     
    address public vaultAddress;                                                

                                                                      
              
                                                                            
                                                                            
                         
                                                                               
                    
                                                                           
                                                                 
                                                                      
                                                                             

    function Campaign(
        uint _startFundingTime,
        uint _endFundingTime,
        uint _maximumFunding,
        address _vaultAddress,
        address _tokenAddress

    ) {
        if ((_endFundingTime < now) ||                                         
            (_endFundingTime <= _startFundingTime) ||
            (_maximumFunding > 10000 ether) ||                              
            (_vaultAddress == 0))                                              
            {
            throw;
            }
        startFundingTime = _startFundingTime;
        endFundingTime = _endFundingTime;
        maximumFunding = _maximumFunding;
        tokenContract = MiniMeToken(_tokenAddress);                              
        vaultAddress = _vaultAddress;
    }

                                                                               
                                                                          
                                                                              
                                                                              

    function ()  payable {
        doPayment(msg.sender);
    }

                 
                            
                 

                                                                                
                                                           
                                                                     

    function proxyPayment(address _owner) payable returns(bool) {
        doPayment(_owner);
        return true;
    }

                                                                           
                                                                           
                                           
                                              
                                             
                                                                   
    function onTransfer(address _from, address _to, uint _amount) returns(bool) {
        return true;
    }

                                                                            
                                                                           
                                                    
                                                       
                                                     
                                                                   
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool)
    {
        return true;
    }


                                                                             
                                                                              
                                                            
                                                                     

    function doPayment(address _owner) internal {

                                                                    
        if ((now<startFundingTime) ||
            (now>endFundingTime) ||
            (tokenContract.controller() == 0) ||                         
            (msg.value == 0) ||
            (totalCollected + msg.value > maximumFunding))
        {
            throw;
        }

                                           
        totalCollected += msg.value;

                             
        if (!vaultAddress.send(msg.value)) {
            throw;
        }

                                                                              
                           
        if (!tokenContract.generateTokens(_owner, msg.value)) {
            throw;
        }

        return;
    }

                                                                        
                                                                                
                                       
                                                                                    

    function finalizeFunding() {
        if (now < endFundingTime) throw;
        tokenContract.changeController(0);
    }


                                                               
                                                                                
             
    function setVault(address _newVaultAddress) onlyOwner {
        vaultAddress = _newVaultAddress;
    }

}