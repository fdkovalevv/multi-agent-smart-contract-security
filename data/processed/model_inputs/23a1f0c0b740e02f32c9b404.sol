contract Intermediary{
                                  
    Investment investmentContract;
                    
    address public owner;
   
       
                                                                
         
    function Intermediary(){
        investmentContract = Investment(0xabcdd0dbc5ba15804f5de963bd60491e48c3ef0b);
        owner = msg.sender;
    }
    
       
                     
         
    function() payable{
    }
    
       
                                                                                                               
                                           
         
    function returnValue(uint value){
        if(this.balance>=value){
          if(investmentContract.investorIndex()<investmentContract.getNumInvestors())
            investmentContract.returnInvestment.value(value)();
          else 
            owner.send(msg.value);
        }
    }
  
       
                                                                                                             
                                           
         
    function returnEverything(){
        if(investmentContract.investorIndex()<investmentContract.getNumInvestors())
          investmentContract.returnInvestment.value(this.balance)();
        else 
          owner.send(this.balance);
    }
    
       
                              
         
    function changeOwner(address newOwner){
        if(msg.sender==owner) 
            owner=newOwner;
    }
    
}