contract HelloWorld {
    uint public x = 3;
    
    event LogMessage(bytes32 log);         

    function () {                     
        LogMessage("Hello World!");
    }
}