contract CreationContract{
    
    address public curator;
    address public dev;

    IToken tokenContract;

  

    function CreationContract(){
        dev = msg.sender;
    }

    function create(address _destination, uint _amount, string _details) returns (uint error){
        if (msg.sender != curator){ return 1; }

        return tokenContract.issueNewCoins(_destination, _amount, _details);
    }

    function setCreationCurator(address _curatorAdress) returns (uint error){
        if (msg.sender != dev){ return 1; }

        curator = _curatorAdress;
        return 0;
    }

    function setTokenContract(address _contractAddress) returns (uint error){
        if (msg.sender != curator){ return 1; }

        tokenContract = IToken(_contractAddress);
        return 0;
    }

    function killContract() returns (uint error) {
        if (msg.sender != dev) { return 1; }

        selfdestruct(dev);
        return 0;
    }

    function tokenAddress() constant returns (address tokenAddress){
        return address(tokenContract);
    } 

    function () {
        throw;
    }
}