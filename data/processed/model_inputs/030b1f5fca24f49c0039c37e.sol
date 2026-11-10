contract DepositContract {
	address masterAddress;

	modifier onlyMaster() {
		require(msg.sender == masterAddress);
		_;
	}

	function DepositContract(){
		masterAddress = msg.sender;
	}

	function sweep(address token, address dedeStorageAddress, uint256 mininumValue) onlyMaster returns (uint256) {
		bool success;
		uint256 sendingValue;
		if(token == address(0)){         
			sendingValue = this.balance;
			if(mininumValue > sendingValue){
				return 0;
			}
			success = dedeStorageAddress.send(this.balance);
			return (success ? sendingValue : 0);
		}
		else{         
			sendingValue = ERC20Interface(token).balanceOf(this);
			if(mininumValue > sendingValue){
				return 0;
			}
			success = ERC20Interface(token).transfer(dedeStorageAddress, sendingValue);
			return (success ? sendingValue : 0);
		}
	}

	function () payable {}
}