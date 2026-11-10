contract System {
	using SafeMath for uint256;
	
	address owner;
	
	                 

	                                                     
	modifier onlyOwner() {
		if (msg.sender != owner) {
			error('System: onlyOwner function called by user that is not owner');
		} else {
			_;
		}
	}

	                 
	
	                                                                         
	function error(string _error) internal {
		revert(_error);
		                                                           
		                      
		         
	}

	                                                                                         
	function whoAmI() public constant returns (address) {
		return msg.sender;
	}
	
	                                                          
	function timestamp() public constant returns (uint256) {
		return block.timestamp;
	}
	
	                                                   
	function contractBalance() public constant returns (uint256) {
		return address(this).balance;
	}
	
	                                            
	constructor() public {
		                                                                                                              
		owner = msg.sender;
		
		                                        
		if(owner == 0x0) error('System constructor: Owner address is 0x0');                                            
	}
	
	              

	                              
	event Error(string _error);

	                             
	event DebugUint256(uint256 _data);

}

contract HardcodedWallets {
	            

	address public walletFounder1;                                      
	address public walletFounder2;                     
	address public walletFounder3;                     
	address public walletCommunityReserve;	                      
	address public walletCompanyReserve;	                      
	address public walletTeamAdvisors;		                      
	address public walletBountyProgram;		                      


	                 

	   
                                                                    
    
	constructor() public {
		                                      
		walletFounder1             = 0x5E69332F57Ac45F5fCA43B6b007E8A7b138c2938;                           
		walletFounder2             = 0x852f9a94a29d68CB95Bf39065BED6121ABf87607;                     
		walletFounder3             = 0x0a339965e52dF2c6253989F5E9173f1F11842D83;                     

		                                                                    
		walletCommunityReserve = 0xB79116a062939534042d932fe5DF035E68576547;
		walletCompanyReserve = 0xA6845689FE819f2f73a6b9C6B0D30aD6b4a006d8;
		walletTeamAdvisors = 0x0227038b2560dF1abf3F8C906016Af0040bc894a;
		walletBountyProgram = 0xdd401Df9a049F6788cA78b944c64D21760757D73;

	}
}

contract Escrow is System, HardcodedWallets {
	using SafeMath for uint256;

	            
	mapping (address => uint256) public deposited;
	uint256 nextStage;

	                                     
	address public addressSCICO;

	                                        
	address public addressSCTokens;
	Tokens public SCTokens;


	                 

	   
                                         
    
	constructor() public {
		                                           
		uint256 totalSupply = 1350000000 ether;


		deposited[this] = totalSupply.mul(50).div(100);
		deposited[walletCommunityReserve] = totalSupply.mul(20).div(100);
		deposited[walletCompanyReserve] = totalSupply.mul(14).div(100);
		deposited[walletTeamAdvisors] = totalSupply.mul(15).div(100);
		deposited[walletBountyProgram] = totalSupply.mul(1).div(100);
	}

	function deposit(uint256 _amount) public returns (bool) {
		                         
		if (msg.sender != addressSCICO) {
			error('Escrow: not allowed to deposit');
			return false;
		}
		deposited[this] = deposited[this].add(_amount);
		return true;
	}

	   
                                                   
    
	function withdraw(address _address, uint256 _amount) public onlyOwner returns (bool) {
		if (deposited[_address]<_amount) {
			error('Escrow: not enough balance');
			return false;
		}
		deposited[_address] = deposited[_address].sub(_amount);
		return SCTokens.transfer(_address, _amount);
	}

	   
                                                   
    
	function fundICO(uint256 _amount, uint8 _stage) public returns (bool) {
		if(nextStage !=_stage) {
			error('Escrow: ICO stage already funded');
			return false;
		}

		if (msg.sender != addressSCICO || tx.origin != owner) {
			error('Escrow: not allowed to fund the ICO');
			return false;
		}
		if (deposited[this]<_amount) {
			error('Escrow: not enough balance');
			return false;
		}
		bool success = SCTokens.transfer(addressSCICO, _amount);
		if(success) {
			deposited[this] = deposited[this].sub(_amount);
			nextStage++;
			emit FundICO(addressSCICO, _amount);
		}
		return success;
	}

	   
                                                                                                       
    
	function setMyICOContract(address _SCICO) public onlyOwner {
		addressSCICO = _SCICO;
	}

	   
                                   
    
	function setTokensContract(address _addressSCTokens) public onlyOwner {
		addressSCTokens = _addressSCTokens;
		SCTokens = Tokens(_addressSCTokens);
	}

	   
                                            
    
	function balanceOf(address _address) public constant returns (uint256 balance) {
		return deposited[_address];
	}


	              

	                                                                   
	event FundICO(address indexed _addressICO, uint256 _amount);


}