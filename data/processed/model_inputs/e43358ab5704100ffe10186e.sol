contract ProxyElectricCharger 
{
    address public Owner = msg.sender;
    address public Manager;
    uint public ChargersCount;
    uint[] public ChargersIds;
    mapping (uint=>Charger) Chargers;
  
    struct Charger{
            IElectricCharger Charger;
           bool State;
    }
   IElectricAccounts public Accounts;
   function setAccountsBase(address accountsBase){
       if (msg.sender != Owner && msg.sender != Manager) return ;
       Accounts = IElectricAccounts(accountsBase);
   }
      function setManager(address manager) external{
             if (msg.sender != Owner) return ;
             Manager = manager;
        }
   function createOrder (uint chargerId,uint orderId,address userAddress,uint startTime,uint endTime , uint electricity,uint payedSum) external {
            if (msg.sender != Owner && msg.sender != Manager) return ;
           if(!Accounts.isUserActive(userAddress)) return;
           if(Chargers[chargerId].Charger != IElectricCharger(address(0x0)) && Chargers[chargerId].State){
                    Accounts.freezeMoney(userAddress,payedSum);
                    Chargers[chargerId].Charger.createOrder(orderId,userAddress,startTime,endTime,electricity,payedSum);
           }
       }
   function confirmOrder (uint chargerId,uint orderId,address userAddress ,uint actualElectricity) external returns (bool success) {
              if (msg.sender != Owner && msg.sender != Manager) return ;
           if(Chargers[chargerId].Charger != IElectricCharger(address(0x0)) && Chargers[chargerId].State){
                var (result,unfreezeSum) =  Chargers[chargerId].Charger.confirmOrder(chargerId,orderId,actualElectricity);
                if(result){
                     Accounts.unfreezeOddMoney(userAddress,unfreezeSum);
                }
                return(result);
           }
    }
   
   
    function addNewCharger(uint id, address chargerAddress){
         if (msg.sender != Owner && msg.sender != Manager) return ;
         Chargers[id].Charger = IElectricCharger(chargerAddress);
         Chargers[id].State = true;
         ChargersIds.push(id);
         ChargersCount++;
    }
    function setStatusOfCharger(uint id,bool state){
              if (msg.sender != Owner && msg.sender != Manager) return ;
              Chargers[id].State = state;
    }
    function isChargerExist(address chargerAddress , uint chargerId) external returns (bool isExist){
         if(IElectricCharger(chargerAddress) != Chargers[chargerId].Charger) 
                    return false;
        return true;
    }
      function getChargers() external constant returns(  address[] addresses ,bool[] statuses) {
                address []  memory _addresses = new address[](ChargersCount);
                bool []  memory _statuses = new bool[](ChargersCount);
                for (var i = 0; i < ChargersCount; i++) {
                   _addresses[i]=Chargers[ChargersIds[i]].Charger;
                   _statuses[i]=Chargers[ChargersIds[i]].State;
                }
                return (_addresses,_statuses);
          }
   
 
}