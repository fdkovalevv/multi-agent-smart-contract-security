contract CryptoTicketsICO {
    using SafeMath for uint;

    uint public constant Tokens_For_Sale = 525000000*1e18;                                            

                                                                
    uint public Rate_Eth = 298;                    
    uint public Token_Price = 25 * Rate_Eth;               
    uint public SoldNoBonuses = 0;                              


    event LogStartICO();
    event LogPauseICO();
    event LogFinishICO(address bountyFund, address advisorsFund, address itdFund, address storageFund);
    event LogBuyForInvestor(address investor, uint tktValue, string txHash);
    event LogReplaceToken(address investor, uint tktValue);

    TKT public tkt = new TKT(this);
    Presale public presale;

    address public Company;
    address public BountyFund;
    address public AdvisorsFund;
    address public ItdFund;
    address public StorageFund;

    address public Manager;                             
    address public Controller_Address1;                                                              
    address public Controller_Address2;                                                               
    address public Controller_Address3;                                                              
    modifier managerOnly { require(msg.sender == Manager); _; }
    modifier controllersOnly { require((msg.sender == Controller_Address1) || (msg.sender == Controller_Address2) || (msg.sender == Controller_Address3)); _; }

    uint startTime = 0;
    uint bountyPart = 2;                                    
    uint advisorsPart = 35;                                       
    uint itdPart = 15;                                 
    uint storagePart = 3;                                    
    uint icoAndPOfPart = 765;                                                       
    enum StatusICO { Created, Started, Paused, Finished }
    StatusICO statusICO = StatusICO.Created;


    function CryptoTicketsICO(address _presale, address _Company, address _BountyFund, address _AdvisorsFund, address _ItdFund, address _StorageFund, address _Manager, address _Controller_Address1, address _Controller_Address2, address _Controller_Address3){
       presale = Presale(_presale);
       Company = _Company;
       BountyFund = _BountyFund;
       AdvisorsFund = _AdvisorsFund;
       ItdFund = _ItdFund;
       StorageFund = _StorageFund;
       Manager = _Manager;
       Controller_Address1 = _Controller_Address1;
       Controller_Address2 = _Controller_Address2;
       Controller_Address3 = _Controller_Address3;
    }

                                                       


    function setRate(uint _RateEth) external managerOnly {
       Rate_Eth = _RateEth;
       Token_Price = 25*Rate_Eth;
    }


                      

    function startIco() external managerOnly {
       require(statusICO == StatusICO.Created || statusICO == StatusICO.Paused);
       if(statusICO == StatusICO.Created)
       {
         startTime = now;
       }
       LogStartICO();
       statusICO = StatusICO.Started;
    }

    function pauseIco() external managerOnly {
       require(statusICO == StatusICO.Started);
       statusICO = StatusICO.Paused;
       LogPauseICO();
    }


    function finishIco() external managerOnly {                               

       require(statusICO == StatusICO.Started);

       uint alreadyMinted = tkt.totalSupply();                          
       uint totalAmount = alreadyMinted * 1000 / icoAndPOfPart;


       tkt.mint(BountyFund, bountyPart * totalAmount / 100);                 
       tkt.mint(AdvisorsFund, advisorsPart * totalAmount / 1000);                     
       tkt.mint(ItdFund, itdPart * totalAmount / 100);                            
       tkt.mint(StorageFund, storagePart * totalAmount / 100);                  

       tkt.defrost();

       statusICO = StatusICO.Finished;
       LogFinishICO(BountyFund, AdvisorsFund, ItdFund, StorageFund);
    }

                                                                      
    function() external payable {

       buy(msg.sender, msg.value * Token_Price);
    }

                                                                    

    function buyForInvestor(address _investor, uint _tktValue, string _txHash) external controllersOnly {
       buy(_investor, _tktValue);
       LogBuyForInvestor(_investor, _tktValue, _txHash);
    }

                                                  

    function replaceToken(address _investor) managerOnly{
         require(statusICO != StatusICO.Finished);
         uint pctTokens = presale.balanceOf(_investor);
         require(pctTokens > 0);
         presale.burnTokens(_investor);
         tkt.mint(_investor, pctTokens);

         LogReplaceToken(_investor, pctTokens);
    }
                                      

    function buy(address _investor, uint _tktValue) internal {
       require(statusICO == StatusICO.Started);
       require(_tktValue > 0);


       uint bonus = getBonus(_tktValue);

       uint _total = _tktValue.add(bonus);

       require(SoldNoBonuses + _tktValue <= Tokens_For_Sale);
       tkt.mint(_investor, _total);

       SoldNoBonuses = SoldNoBonuses.add(_tktValue);
    }

                                 
    function getBonus(uint _value) public constant returns (uint) {
       uint bonus = 0;
       uint time = now;
       if(time >= startTime && time <= startTime + 48 hours)
       {

            bonus = _value * 20/100;
        }

       if(time > startTime + 48 hours && time <= startTime + 96 hours)
       {
            bonus = _value * 10/100;
       }

       if(time > startTime + 96 hours && time <= startTime + 168 hours)
       {

            bonus = _value * 5/100;
        }

       return bonus;
    }

                                              

                  
                                                                             
    function withdrawEther(uint256 _value) external managerOnly {
       require(statusICO == StatusICO.Finished);
       Company.transfer(_value);
    }

}