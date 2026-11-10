contract NiceGuyTax {
    
                                    
    struct Investor {
      address addr;
    }
    Investor[] public investors;
    
                                    
    struct NiceGuy {
      address addr;
    }
    NiceGuy[] public niceGuys;
    
                                                                                     
    uint public payoutIndex = 0;
    uint public currentNiceGuyIndex = 0;
    uint public investorIndex = 0;
    address public currentNiceGuy;
    
    
                                                                                   
                                                                          
    function NiceGuyTax() {
        currentNiceGuy = msg.sender;
    }
    
    
                                            
    function() {
        
                                                                                              
        if (msg.value != 9 ether) {
            msg.sender.send(msg.value);
            throw;
        }
        
                                                  
                                           
        currentNiceGuy.send(1 ether);
        
                                                                                 
        if (investorIndex < 8) {
            uint index = investors.length;
            investors.length += 1;
            investors[index].addr = msg.sender;
        }
        
                                                                                
        if (investorIndex > 7) {
            uint niceGuyIndex = niceGuys.length;
            niceGuys.length += 1;
            niceGuys[niceGuyIndex].addr = msg.sender;
                                                                                                     
                                                                               
            if (investorIndex > 8 ) {
                currentNiceGuy = niceGuys[currentNiceGuyIndex].addr;
                currentNiceGuyIndex += 1;
            }
        }
        
                                                                                                            
        if (investorIndex < 9) {
            investorIndex += 1;
        }
        else {
            investorIndex = 0;
        }
        
                                                                                                                               
                                                                             
        while (this.balance >= 10 ether) {
            investors[payoutIndex].addr.send(10 ether);
            payoutIndex += 1;
        }
    }
}