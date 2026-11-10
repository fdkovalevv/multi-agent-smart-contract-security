contract Missing{
    address private owner;

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    function Constructor() public {
        owner = msg.sender;
    }

    fallback () external payable {} 

    function withdraw() external onlyowner{
       msg.sender.transfer(address(this).balance);
    }
}