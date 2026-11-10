contract DestructionContract{
    
    address public curator;
    address public dev;

    IToken tokenContract;

	
    function DestructionContract(){
        dev = msg.sender;
    }
    
    function destroy(uint _amount, string _details) returns (uint error){
        if (msg.sender != curator){ return 1; }
        
        return tokenContract.destroyOldCoins(msg.sender, _amount, _details);
    }

    function setDestructionCurator(address _curatorAdress) returns (uint error){
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