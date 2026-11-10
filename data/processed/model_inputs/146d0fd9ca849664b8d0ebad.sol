contract Ownable {
  address public owner;


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    require (!halted);
    _;
  }

  modifier onlyInEmergency {
    require (halted);
    _;
  }

                                                             
  function halt() external onlyOwner {
    halted = true;
  }

                                                                     
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}

contract DogezerICOPrivateCrowdSale is Haltable{
    using SafeMath for uint;
    string public name = "Dogezer Private Sale ITO";

    address public beneficiary;
    uint public startTime;
    uint public duration;
    uint public tokensContractBalance;
    uint public price; 
    uint public discountPrice; 
    DGZToken public tokenReward;

    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public whiteList;

    event FundTransfer(address backer, uint amount, bool isContribution);
    
    bool public crowdsaleClosed = false;
    uint public tokenOwnerNumber = 0;
    uint public constant tokenOwnerNumberMax = 120;
    uint public constant minPurchase = 25.0 * 1 ether;
    uint public constant discountValue = 100.0 * 1 ether;

                                             
    function DogezerICOPrivateCrowdSale(
        address addressOfTokenUsedAsReward,
		address addressOfBeneficiary
    ) public
    {
        beneficiary = addressOfBeneficiary;
        startTime = 1516021200;
        duration = 744 hours;
		tokensContractBalance =  500000000000000;
        price = 5000000;
        discountPrice = 4500000;
        tokenReward = DGZToken(addressOfTokenUsedAsReward);
    }

    modifier onlyAfterStart() {
        require (now >= startTime);
        _;
    }

    modifier onlyBeforeEnd() {
        require (now <= startTime + duration);
        _;
    }

                                                                                                                    
    function () payable stopInEmergency onlyAfterStart onlyBeforeEnd public
    {
        require (msg.value >= minPurchase);
        require (crowdsaleClosed == false);
        require (tokensContractBalance > 0);
        require (whiteList[msg.sender] == true);
		
		uint currentPrice = price;
		
        if (balanceOf[msg.sender] == 0)
        {
            require (tokenOwnerNumber < tokenOwnerNumberMax);
            tokenOwnerNumber++;
        }

        if (msg.value >= discountValue)
        {
            currentPrice = discountPrice;
        }		
		
		uint amountSendTokens = msg.value / currentPrice;
		
		if (amountSendTokens > tokensContractBalance)
		{
			uint refund = msg.value - (tokensContractBalance * currentPrice);
			amountSendTokens = tokensContractBalance;
			msg.sender.transfer(refund);
			FundTransfer(msg.sender, refund, true);
			balanceOf[msg.sender] += (msg.value - refund);
		}
		else 
		{
			balanceOf[msg.sender] += msg.value;
		}
		
		tokenReward.transfer(msg.sender, amountSendTokens);
		FundTransfer(msg.sender, amountSendTokens, true);
		
		tokensContractBalance -= amountSendTokens;

    }

    function joinWhiteList (address _address) public onlyOwner
    {
        if (_address != address(0)) 
        {
            whiteList[_address] = true;
        }
    }
	
    function finalizeSale () public onlyOwner
    {
       require (crowdsaleClosed == false);
       crowdsaleClosed = true;
    }

    function reopenSale () public onlyOwner
    {
       crowdsaleClosed = false;
    }

    function setPrice (uint _price) public onlyOwner
    {
        if (_price != 0)
        {
            price = _price;
        }
    }

    function setDiscount (uint _discountPrice) public onlyOwner
    {
        if (_discountPrice != 0)
        {
            discountPrice = _discountPrice;
        }
    }
	
    function fundWithdrawal (uint _amount) public onlyOwner
    {
        beneficiary.transfer(_amount);
    }
   
    function tokenWithdrawal (uint _amount) public onlyOwner
    {
        tokenReward.transfer(beneficiary, _amount);
		tokensContractBalance -= _amount;
    }
	
    function changeBeneficiary(address _newBeneficiary) public onlyOwner 
	{
        if (_newBeneficiary != address(0)) {
            beneficiary = _newBeneficiary;
        }
	}	
}