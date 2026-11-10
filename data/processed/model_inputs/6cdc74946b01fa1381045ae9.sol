contract GeneralPurposeProfitSplitter {                                                              

    struct Contributor {                                                                                                                      
        address addr;                                                              
        uint index;                                                                                       
        uint contribution;                                                                                 
        uint profit;                                                                                                    
        uint total;                                                                             
        uint lastContribution;                                                                       
        uint lastProfit;                                                               
        uint lastProfitShare;                                                                                               
        uint lastPayout;                                                                              
        string error;                                                                       
    }
    
    Contributor[] public contributors;                                                                                                                
    uint contributorFound = 0;                                                                                             
    uint contributorTotal = 0;                                                                  
    uint contributorShare = 0;                                                                                        
    uint public contributorsIndex = 0;                                                                   
    
    uint public totalContributorsContribution = 0;                                                                     
    uint public totalContributorsProfit = 0;                                                                      
    uint totalContributorsTotal = 0;                                                                                  
    address public beta;                                                                                                                                          
    address public nextInputProfit;                                                                                                                                
    
    uint i = 0;                                                                                               
    uint correctProfit = 0;                                                                                                   
    
    function GeneralPurposeProfitSplitter() {                                                                                           
        beta = msg.sender;                                                                                                
    }                                                                                                                                                        

    
    function() {                                                                                                                                         
        if (msg.value < 1 finney) {                                                                        
            msg.sender.send(msg.value);                                                                                      
            throw;                                                                      
        }
        
        if (msg.value == 1 finney) {                                                                 
            nextInputProfit = msg.sender;                                                                                                   
            throw;                                                                                                                                               
        }
        
        if (nextInputProfit == msg.sender) {                                                                                                                                 
            nextInputProfit = 0;                                                                                                                                                                  
            correctProfit = msg.value + 1 finney;                                                                    
            insertProfitHere();                                                                
        }
        else {                                                                                                                                                                         
            for(i; i<contributors.length; i++) {                                                                                                                                      
                if (contributors[i].addr == msg.sender) {                                                                      
                    contributorFound = i;                                                             
                    i = contributors.length;                                                     
                }
            }
            i = 0;                                                                                         
            if (contributorFound > 0) {                                                                                                                                                     
                contributors[contributorFound].contribution += msg.value;                                                                     
                contributors[contributorFound].total = contributorTotal;                            
                contributors[contributorFound].lastContribution = msg.value;                            
                contributorTotal = contributors[contributorFound].contribution + contributors[contributorFound].profit;                                                  
            }
            else {                                                                                                                                                     
                contributors[contributorsIndex].addr = msg.sender;                                                                             
                contributors[contributorsIndex].index = contributorsIndex;                                               
                contributors[contributorsIndex].contribution = msg.value;                                                                               
                contributors[contributorsIndex].total = msg.value;                             
                contributors[contributorsIndex].lastContribution = msg.value;                            
                contributorsIndex += 1;                                                                                             
            }
            totalContributorsContribution += msg.value;                                                                                                                                         
        }
    }
    
    
    function insertProfitHere() {                                                                                                                                                  
        totalContributorsTotal = totalContributorsProfit + totalContributorsContribution;                                                    
        i = contributors.length;                                                                                       
        uint CorrectProfitCounter = correctProfit;                                                                                     
        uint addedProfit;                                                                                                  
        uint errorBelow = 0;                                                                                                                
            for(i; i >= 0; i--) {                                                                                                  
            contributorTotal = contributors[i].contribution + contributors[i].profit;                                                  
            contributorShare = contributorTotal / totalContributorsTotal;                                                    
            addedProfit = contributorShare / correctProfit;                                                                                                          
            CorrectProfitCounter -= addedProfit;                                                                                                                 
            if (CorrectProfitCounter > 0){                                                                                                      
                contributors[i].profit += addedProfit;                                                      
                totalContributorsProfit += addedProfit;                                                              
                contributors[i].lastProfit = addedProfit;                                                     
            }
            else {                                                                                                                      
                errorBelow = i;                                                 
                i = 0;                                                         
            }
        }
        if (errorBelow >= 0){                                                                                     
            for(errorBelow; errorBelow > 0; errorBelow--) {                                                                     
                contributors[errorBelow].error = "Please cash all out and recontribute to continue getting profit";                 
            }
        }
    }

    
    function cashOutProfit() {                                                           
        for(i; i<contributors.length; i++) {                                      
            if (contributors[i].addr == msg.sender) {                       
                contributorFound = i;                          
                i = contributors.length;                            
                msg.sender.send(contributors[contributorFound].profit);                                  
                totalContributorsProfit -= contributors[contributorFound].profit;                                                                                   
                contributors[contributorFound].profit = 0;                                                                                  
            }
            
        }
        i = 0;                                                                             
    }
    
    
    function cashAllOut() {                                                                             
        for(i; i<contributors.length; i++) {                                
            if (contributors[i].addr == msg.sender) {                  
                contributorFound = i;                     
                i = contributors.length;                                   
                contributorTotal = contributors[contributorFound].contribution + contributors[contributorFound].profit;                           
                msg.sender.send(contributorTotal);                                      
                totalContributorsContribution -= contributors[contributorFound].contribution;                             
                contributors[contributorFound].contribution = 0;                                       
                totalContributorsProfit -= contributors[contributorFound].profit;                                      
                contributors[contributorFound].profit = 0;                                     
            }
            
        }
        i = 0;                                                            
    }
    
    
                                                                                
                                                                                
                                                                                
    function giveAllBack() {                                         
        if (beta == msg.sender) {                                                                                             
            for(i; i<contributors.length; i++) {                 
                contributorTotal = contributors[i].contribution + contributors[i].profit;                                                          
                contributors[i].addr.send(contributorTotal);                          
                contributors[i].contribution = 0;                          
                totalContributorsContribution = 0;                   
                contributors[i].profit = 0;                                
                totalContributorsProfit = 0;                    
            }
            i = 0;                                                      
        }
    }
    

    function giveContributionsBackProfitBugged() {                                
        if (beta == msg.sender) {                                                                                                               
            for(i; i<contributors.length; i++) {                               
                contributorTotal = contributors[i].contribution;                                           
                contributors[i].contribution = 0;                    
                contributors[i].addr.send(contributorTotal);                                                            
            }
            i = 0;                                                                           
        }
    }


    function Fokitol() {                                                                                                                       
        if (beta == msg.sender) {                                     
            beta.send(this.balance);                                                                                                             
        }
    }
    
}