contract TokenController {
                                                                             
                                                                      
                                                                 
    function proxyPayment(address _owner) payable returns(bool);

                                                                           
                                       
                                               
                                                  
                                                 
                                                                       
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

                                                                      
                                       
                                                        
                                                           
                                                         
                                                                       
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);
}

contract SWTConverter is TokenController {

    MiniMeToken public tokenContract;                   
    ERC20 public arcToken;                                      

    function SWTConverter(
        address _tokenAddress,                                         
        address _arctokenaddress                                         
    ) {
        tokenContract = MiniMeToken(_tokenAddress);                               
        arcToken = ERC20(_arctokenaddress);
    }

                 
                            
                 


 function proxyPayment(address _owner) payable returns(bool) {
        return false;
    }

                                                                               
                                                                           
                                           
                                              
                                             
                                                                   
    function onTransfer(address _from, address _to, uint _amount) returns(bool) {
        return true;
    }

                                                                                
                                                                           
                                                    
                                                       
                                                     
                                                                   
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool)
    {
        return true;
    }


                                                                                        
                                                      
 function convert(uint _amount){

                                                                                    
                                                                                                  
        if (!arcToken.transferFrom(msg.sender, 0x0, _amount)) {
            throw;
        }

                              
        if (!tokenContract.generateTokens(msg.sender, _amount)) {
            throw;
        }
    }


}