contract BankOfEthereum {

    address owner;

    mapping (address => Trader) traders;
    
    event OutputString(string output);

	              
    function BankOfEthereum() {
        owner = msg.sender;
    }
    
                                               
    struct Trader {
        address addr;
        string name;
        uint256 balance;
        string greeting;
    }
    
                                                                                   
    function getBalance() constant returns (uint256) {
        return traders[msg.sender].balance;
    }
    
                                                                                                  
    function sendMoneyTo(address destination, uint256 value) returns (bool) {
        if (traders[msg.sender].balance >= value){
            traders[msg.sender].balance -= value;
            traders[destination].balance += value;
            OutputString("Transferred money successfully.");
            return true;
        }
        else {
            OutputString("Didn't transfer money.");
            return false;
        }
    }

                                                                                    
    function increaseBalance() payable returns (bool) {
        traders[msg.sender].balance =+ msg.value;
        OutputString("Increased balance successfully.");
        return true;
    }

    function increaseBalanceAndSendMoneyTo(address dest, uint256 val) payable{
        bool increased = false;
        bool sent = false;
        increased = increaseBalance();
                                                                                                          
                                  

        sent = sendMoneyTo(dest, val);
                                                                                     
                                                       

        if(increased && sent){
        	OutputString("Increased balance and tranferred money.");
        }
        else{
            OutputString("This did not work.");
                                                 
            throw;
        }
    }

    function withdraw() {
                                                                                                                     
        var share = traders[msg.sender].balance;
        traders[msg.sender].balance = 0;
        if (!msg.sender.send(share)) {
            throw;
        }
        OutputString("You withdrew all your money.");
    }

                                                                                                                   
                                                                                                                           
   
      
                        
                                                          
                  
         
                                        
     
      
   
                                 
    function killMe() public {
        if (msg.sender == owner) {
                                                                             
            selfdestruct(owner);
            OutputString("Contract is killed.");
        }            
        else {
            OutputString("Nice try. The contract is still up and alive!");
        }  
    }
    
                                                                                    
    modifier onlyOwner {
        if (msg.sender == owner) {
                                                       
            _;
        }
        else {
            throw;
        }
    }
    
                                        
    function killMe2() public onlyOwner {
        OutputString("Contract is killed 2.");
        selfdestruct(msg.sender);
    }
}