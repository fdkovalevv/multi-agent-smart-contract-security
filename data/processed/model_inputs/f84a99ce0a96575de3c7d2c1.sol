contract HelloWorld {
    
    string wellcomeString = "Hello, world!";
    
    function getData() public constant returns (string) {
        return wellcomeString;
    }
    
    function setData(string newData) public {
        wellcomeString = newData;
    }
    
}