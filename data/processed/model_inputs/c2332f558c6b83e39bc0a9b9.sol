contract viewMessage{
    string message;
    constructor() public {
        message = "This is the initial Message";
    }
    
    
    function setNewMessage(string newMsg) public payable
    {
                                                                                                                            
        message = newMsg;
        
    }
    
    function getMessage() constant public returns (string)
    {
        return message;
    }
    
    
}