contract message {
    string public message;
                            
    int public people = 0;
    function messageBoard(string initMessage) public {
        message = initMessage;
    }
    function editMessage(string _editMessage) public {
        message = _editMessage;
    }
    function showMessage() public view returns(string){
                            
        return message;
    }
    function pay() public payable {
        people++;
    }
}