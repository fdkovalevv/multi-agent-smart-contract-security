contract FunkyGasPattern {
	string public field;

	function SetField(string value) {
		                                                    
		if (msg.gas < 100000) {
			throw;
		}
		field = value;
	}
}