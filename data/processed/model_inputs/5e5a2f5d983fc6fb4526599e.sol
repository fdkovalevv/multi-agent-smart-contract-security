contract viewMessagePayable{
    string message;
    string message2;
    address public owner;
    uint amount;

    constructor() public {
        message = "This is the initial Message";
        message2 = "This is the second Initial message";
        owner = msg.sender;
        amount = 0;
    }
    
    
    function setNewMessage(string newMsg) public payable
    {
        
                                                                                                                            
        message = newMsg;
        amount += msg.value;
        
        
    }
    
    function setNewMessage2(string meg) public payable {
        message2 = meg;
        amount += msg.value;
    }
    
    function getMessage() constant public returns (string)
    {
        return message;
    }
    
    
}