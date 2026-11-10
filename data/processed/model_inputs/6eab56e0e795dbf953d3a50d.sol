contract MicroDAO
{
	string public directorNode;
	address public director;
	string public directorName;
	string public directorJurisdication;
	bool public initialFunding;	
	uint256 public sharesRaised;
	uint public lockInDays;	
	string public name ="MicroDAO";
	string public symbol ="E/";
	uint256 public fundingGoal;
	uint256 public balanceFinney;
	uint256 public directorLockUntil;
	uint256 public directorLockDays;
	uint256 public directorTransferShareRequired;
	mapping (address => uint256) public balanceOf;		
	mapping (address => uint256) public fundsExpire;
	mapping (address => uint256) public blockedtransfer;
	
	
	address[] public funders;
	SpendingRequest[]  public allowances;
	struct booking {
		uint256 time;
		uint256 funding;
		uint256 spending;
		address counterpart;
		string text;
	}
	booking[] public bookings;
	
	event Transfer(address indexed from, address indexed to, uint256 value);
	
	function MicroDAO() {
		initialFunding=true;
		director=msg.sender;	
		directorLockUntil=now+(86400*30);		
	}
	function setDirectorNode(string node) {
		if(msg.sender!=director) throw;
		directorNode=node;
		directorLockUntil=now+(86400*directorLockDays);
	} 
	
	function blockTransfer(address a,uint256 until) {
		bool found=false;
		for(var i=0;((i<allowances.length)&&(found==false));i++) {
			if(allowances[i]==msg.sender) found=true;
		}
		if(found) {
			if(blockedtransfer[a]>until) {
				blockedtransfer[a]=until;
			}
		}
	}
	
	function setDirectorLock(uint256 number_of_days,uint256 requiredShares) {
		if(msg.sender!=director) throw; 
		if(requiredShares>sharesRaised) throw;
		if(number_of_days>365) number_of_days=365;
		
		
		directorLockDays=number_of_days;
		directorTransferShareRequired=requiredShares;
	}
	
	function transferDirector(address director) {
		                            
		if(msg.sender==director) {
			director=director;
			directorName="";
			directorJurisdication="";
			initialFunding=true;
		} else if((now>directorLockUntil)&&(balanceOf[msg.sender]>directorTransferShareRequired)) {
			director=msg.sender;
			directorName="";
			directorJurisdication="";
			initialFunding=true;
		}
	}
	function setdirectorName(string name) {
		if(msg.sender!=director) throw;
		if(!initialFunding) throw;
		directorName=name;
	}
	
	function setFundingGoal(uint256 goal) {
		if(msg.sender!=director) throw;
		fundingGoal=goal;
	}
	
	function setInitialLockinDays(uint number_of_days) {
		if(msg.sender!=director) throw;
		lockInDays=number_of_days;
	}
	
	
	function setJurisdication(string juri) {
		if(msg.sender!=director) throw;
		if(!initialFunding) throw;
		directorJurisdication=juri;
	}
	
	function addSpendingRequest(address spendingRequest) {
		if(msg.sender!=director) throw;	
		SpendingRequest s = SpendingRequest(spendingRequest);		
		if(s.executed()) throw;
		if(s.vote_until()<now) throw; 
		allowances.push(s);		
	}
	
	function executeSpendingRequests() {
		for(var i=0;i<allowances.length;i++) {
			SpendingRequest s =SpendingRequest(allowances[i]);
			if(!s.executed()) {
				if((s.vote_until()<now)&&(s.request_until()>now)) {
					s.execute();
					directorLockUntil=now+(86400*directorLockDays);
					if(s.result_amount()>0) {
						if(s.result_payto()!=0) {
							s.result_payto().send(s.result_amount()*1 ether);
							bookings.push(booking(now,0,s.result_amount()*1 ether,s.result_payto(),"Executed SpendingRequest"));
						}
					}
				}
			}
		}
	}
	
	function myFundsExpireIn(uint256 number_of_days) {
		var exp=now+(86400*number_of_days);
		if(exp>fundsExpire[msg.sender]) fundsExpire[msg.sender]=exp; else throw;
	}
		
	function closeFunding() {
		if(msg.sender!=director) throw;
		initialFunding=false;		
		checkExpiredfunds();		
	}
	
	function checkExpiredfunds() {
		if(!initialFunding) return;
		for(var i=0;i<funders.length;i++) {
			if((fundsExpire[funders[i]]>0)&&((fundsExpire[funders[i]]<now))) {
				var amount=balanceOf[funders[i]]*1 finney;				
				Transfer(funders[i],this,balanceOf[funders[i]]);
				sharesRaised-=balanceOf[funders[i]];
				balanceOf[funders[i]]=0;
				funders[i].send(amount);				
			}
		}
	}
	
	function transfer(address _to, uint256 _value) {
		if(blockedtransfer[msg.sender]>now) throw;
		if (balanceOf[msg.sender] < _value) throw;                                            
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;                       
        balanceOf[msg.sender] -= _value;                                                
        balanceOf[_to] += _value;                                                            
		if(balanceOf[_to]==0) {
			funders.push(_to);
		}
        Transfer(msg.sender, _to, _value);                                                                           
    }
	
	function() {	
		 var funding_type="Incomming";			
			var finneys=msg.value/1 finney;
			if(initialFunding) {
				
				if(balanceOf[msg.sender]==0) {
					funders.push(msg.sender);
				}		
				if(msg.value<100 finney) throw;
				
				fundsExpire[msg.sender]=now+(lockInDays*86400);
				balanceOf[msg.sender]+=finneys;
				Transfer(this,msg.sender,finneys);
				sharesRaised+=finneys;
				funding_type="Initial Funding";
			}
			bookings.push(booking(now,msg.value,0,msg.sender,funding_type));
			balanceFinney=this.balance/1 finney;
	}
}