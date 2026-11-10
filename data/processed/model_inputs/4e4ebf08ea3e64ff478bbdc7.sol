contract owned {
    function owned() public { owner = msg.sender; }
    address public owner;

                                                             
                                                 
                                                             
                                                    
                                                            
                                                          
              
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract AutoWallet is owned {
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    
    function () external payable {
                                                                                           
                                                                 
        owner.transfer(msg.value);
                                                                         
        EtherReceived(msg.sender, msg.value);
    }
    
    function sweep() external returns (bool success) {
                                                                                                              
                                                                           
        require(this.balance > 0);
        return owner.send(this.balance);
    }
    
    function transferToken(address _tokenContractAddress, address _to, uint256 _amount) external onlyOwner returns (bool success) {
                                                                                                        
        ERC20 token = ERC20(_tokenContractAddress);
        return token.transfer(_to, _amount);
    }
    
    function sweepToken(address _tokenContractAddress) external returns (bool success) {
                                                                                                                           
        ERC20 token = ERC20(_tokenContractAddress);
        uint bal = token.balanceOf(this);
        require(bal > 0);
        return token.transfer(owner, bal);
    }
    
    function transferTokenFrom(address _tokenContractAddress, address _from, address _to, uint256 _amount) external onlyOwner returns (bool success) {
        ERC20 token = ERC20(_tokenContractAddress);
        return token.transferFrom(_from, _to, _amount);
    }
    
    function approveTokenTransfer(address _tokenContractAddress, address _spender, uint256 _amount) external onlyOwner returns (bool success) {
        ERC20 token = ERC20(_tokenContractAddress);
        return token.approve(_spender, _amount);
    }
    
    function transferNonFungibleToken(address _tokenContractAddress, address _to, uint256 _tokenId) external onlyOwner {
                                
        ERC721 token = ERC721(_tokenContractAddress);
        token.transfer(_to, _tokenId);
    }
    
    function transferNonFungibleTokenFrom(address _tokenContractAddress, address _from, address _to, uint256 _tokenId) external onlyOwner {
        ERC721 token = ERC721(_tokenContractAddress);
        token.transferFrom(_from, _to, _tokenId);
    }
    
    function transferNonFungibleTokenMulti(address _tokenContractAddress, address _to, uint256[] _tokenIds) external onlyOwner {
        ERC721 token = ERC721(_tokenContractAddress);
        for (uint i = 0; i < _tokenIds.length; i++) {
            token.transfer(_to, _tokenIds[i]);
        }
    }
    
    event EtherReceived(address _sender, uint256 _value);
}