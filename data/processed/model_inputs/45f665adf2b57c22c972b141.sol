contract BadMarketPlace {
	                                                                                                                                                                                                                                                                                                                                            
    function deposit() external payable {
        require(msg.value > 0);
    }
}