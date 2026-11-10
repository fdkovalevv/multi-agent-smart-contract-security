contract Doubly {
    
    address public owner;
    address[] public participants;
    uint public payoutIndex = 0;
    uint public payoutCount = 0;
    uint public fees;
    
                                                            
                                                          
              
    modifier onlyowner {  
        require(msg.sender == owner);
        _;
    }
    
    function Doubly(){
        owner = msg.sender;
        participants.push(owner);
        participants.push(owner);
        payoutCount = payoutCount + 2;
    }
    
                        
    function () payable {
        enter();
    }
    
                             
    function collectFees() onlyowner {
        if (fees == 0) return;

        owner.transfer(fees);
        fees = 0;
    }

                       
    function setOwner(address newOwner) onlyowner {
        owner = newOwner;
    }
    
                            
    function enter() payable returns(string){

                                    
        if(msg.value < 0.2 ether){
            msg.sender.transfer(msg.value);
            return "Low value!";
        }
        
                                              
                                    
        participants.push(msg.sender);
        participants.push(msg.sender);
        payoutCount = payoutCount + 2;

                             
                                       
                              
        participants[payoutIndex].transfer(0.19 ether);
        msg.sender.transfer(msg.value - 0.2 ether);
        fees += 0.01 ether;
        delete participants[payoutIndex];
        payoutIndex = payoutIndex + 1;
        return "Successfully joined the queue!";

    }
}