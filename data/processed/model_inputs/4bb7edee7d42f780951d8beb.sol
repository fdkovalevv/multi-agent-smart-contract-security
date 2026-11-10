contract Permissions {

	address ownerAddress;
	address storageAddress;
	address callerAddress;

	function Permissions() public {
		ownerAddress = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == ownerAddress);
		_;
	}

	modifier onlyCaller() {
		require(msg.sender == callerAddress);
		_;
	}

	function getOwner() view external returns (address) {
		return ownerAddress;
	}

	function getStorageAddress() view external returns (address) {
		return storageAddress;
	}

	function getCaller() view external returns (address) {
		return callerAddress;
	}

	function transferOwnership(address newOwner) external onlyOwner {
		if (newOwner != address(0)) {
				ownerAddress = newOwner;
		}
	}
	function newStorage(address _new) external onlyOwner {
		if (_new != address(0)) {
				storageAddress = _new;
		}
	}
	function newCaller(address _new) external onlyOwner {
		if (_new != address(0)) {
				callerAddress = _new;
		}
	}
}

contract CreaturesInterface is Permissions {

	mapping (uint8 => uint256) public creatureCosts;

	function CreaturesInterface() public {
		creatureCosts[0] = .10 ether;
		creatureCosts[1] = .25 ether;
		creatureCosts[2] = .12 ether;
		creatureCosts[3] = .50 ether;
		creatureCosts[4] = .10 ether;
		creatureCosts[5] = 2.0 ether;
		creatureCosts[6] = 2.0 ether;
		creatureCosts[7] = 1.0 ether;
		creatureCosts[8] = .01 ether;
		creatureCosts[9] = .025 ether;
	}

	function addCreature(uint16 _species, uint8 _subSpecies, uint8 _eyeColor) external payable {
		require(_species == 0);                                      
		require(creatureCosts[_subSpecies] > 0);
		require(msg.value >= creatureCosts[_subSpecies]);
		Creatures creatureStorage = Creatures(storageAddress);
		creatureStorage.add(msg.sender, _species, _subSpecies, _eyeColor);
	}
    function withdrawBalance() external onlyOwner {
        ownerAddress.transfer(this.balance);
    }
}