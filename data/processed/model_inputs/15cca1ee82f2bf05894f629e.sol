contract CreatorEnabled {
     address public creator = 0x0;

     modifier onlyCreator() { require(msg.sender==creator); _; }

     function changeCreator(address _to) public onlyCreator {
          creator = _to;
     }
}

contract GoldmintMigration is CreatorEnabled {
          
     IMNTP public mntpToken;
     Gold public goldToken;

     enum State {
          Init,
          MigrationStarted,
          MigrationPaused,
          MigrationFinished
     }

     State public state = State.Init;
     
                                                                        
     uint public mntpToMigrateTotal = 0;
     uint public migrationRewardTotal = 0;
     uint64 public migrationStartedTime = 0;
     uint64 public migrationFinishedTime = 0;

     struct Migration {
          address ethAddress;
          string gmAddress;
          uint tokensCount;
          bool migrated;
          uint64 date;
          string comment;
     }

     mapping (uint=>Migration) public mntpMigrations;
     mapping (address=>uint) public mntpMigrationIndexes;
     uint public mntpMigrationsCount = 0;

     mapping (uint=>Migration) public goldMigrations;
     mapping (address=>uint) public goldMigrationIndexes;
     uint public goldMigrationsCount = 0;

     event MntpMigrateWanted(address _ethAddress, string _gmAddress, uint256 _value);
     event MntpMigrated(address _ethAddress, string _gmAddress, uint256 _value);

     event GoldMigrateWanted(address _ethAddress, string _gmAddress, uint256 _value);
     event GoldMigrated(address _ethAddress, string _gmAddress, uint256 _value);

                 
     function getMntpMigration(uint index) public constant returns(address,string,uint,bool,uint64,string){
          Migration memory mig = mntpMigrations[index];
          return (mig.ethAddress, mig.gmAddress, mig.tokensCount, mig.migrated, mig.date, mig.comment);
     }

     function getGoldMigration(uint index) public constant returns(address,string,uint,bool,uint64,string){
          Migration memory mig = goldMigrations[index];
          return (mig.ethAddress, mig.gmAddress, mig.tokensCount, mig.migrated, mig.date, mig.comment);
     }

             
                   
     function GoldmintMigration(address _mntpContractAddress, address _goldContractAddress) public {
          creator = msg.sender;

          require(_mntpContractAddress != 0);
          require(_goldContractAddress != 0);

          mntpMigrationIndexes[address(0x0)] = 0;
          goldMigrationIndexes[address(0x0)] = 0;

          mntpToken = IMNTP(_mntpContractAddress);
          goldToken = Gold(_goldContractAddress);
     }

     function lockMntpTransfers(bool _lock) public onlyCreator {
          mntpToken.lockTransfer(_lock);
     }

     function lockGoldTransfers(bool _lock) public onlyCreator {
          goldToken.lockTransfer(_lock);
     }

                                                                     
                             
     function startMigration() public onlyCreator {
          require((State.Init == state) || (State.MigrationPaused == state));

          if (State.Init == state) {
                                 
               goldToken.startMigration();
               
                                               
               migrationRewardTotal = goldToken.balanceOf(this);
               migrationStartedTime = uint64(now);
               mntpToMigrateTotal = mntpToken.totalSupply();
          }

          state = State.MigrationStarted;
     }

     function pauseMigration() public onlyCreator {
          require((state == State.MigrationStarted) || (state == State.MigrationFinished));

          state = State.MigrationPaused;
     }

                                                                                    
                                              
     function finishMigration() public onlyCreator {
          require((State.MigrationStarted == state) || (State.MigrationPaused == state));

          if (State.MigrationStarted == state) {
               goldToken.finishMigration();
               migrationFinishedTime = uint64(now);
          }

          state = State.MigrationFinished;
     }

     function destroyMe() public onlyCreator {
          selfdestruct(msg.sender);          
     }

       
                                                             
                              
                                                                                                   
       
                                                                   
                                                                                                      
     function migrateMntp(string _gmAddress) public {
          require((state==State.MigrationStarted) || (state==State.MigrationFinished));

                                         
          uint myBalance = mntpToken.balanceOf(msg.sender);
          require(0!=myBalance);

          uint myRewardMax = calculateMyRewardMax(msg.sender);        
          uint myReward = calculateMyReward(myRewardMax);

                                           
          goldToken.transferRewardWithoutFee(msg.sender, myReward);

                             
                                                  
             
                                        
                                                            
                             
          mntpToken.burnTokens(msg.sender,myBalance);

                        
          Migration memory mig;
          mig.ethAddress = msg.sender;
          mig.gmAddress = _gmAddress;
          mig.tokensCount = myBalance;
          mig.migrated = false;
          mig.date = uint64(now);
          mig.comment = '';

          mntpMigrations[mntpMigrationsCount + 1] = mig;
          mntpMigrationIndexes[msg.sender] = mntpMigrationsCount + 1;
          mntpMigrationsCount++;

                          
          MntpMigrateWanted(msg.sender, _gmAddress, myBalance);
     }

     function isMntpMigrated(address _who) public constant returns(bool) {
          uint index = mntpMigrationIndexes[_who];

          Migration memory mig = mntpMigrations[index];
          return mig.migrated;
     }

     function setMntpMigrated(address _who, bool _isMigrated, string _comment) public onlyCreator { 
          uint index = mntpMigrationIndexes[_who];
          require(index > 0);

          mntpMigrations[index].migrated = _isMigrated; 
          mntpMigrations[index].comment = _comment; 

                          
          if (_isMigrated) {
               MntpMigrated(  mntpMigrations[index].ethAddress, 
                              mntpMigrations[index].gmAddress, 
                              mntpMigrations[index].tokensCount);
          }
     }

       
     function migrateGold(string _gmAddress) public {
          require((state==State.MigrationStarted) || (state==State.MigrationFinished));

                            
          uint myBalance = goldToken.balanceOf(msg.sender);
          require(0!=myBalance);

                             
                                                  
             
          goldToken.burnTokens(msg.sender,myBalance);

                        
          Migration memory mig;
          mig.ethAddress = msg.sender;
          mig.gmAddress = _gmAddress;
          mig.tokensCount = myBalance;
          mig.migrated = false;
          mig.date = uint64(now);
          mig.comment = '';

          goldMigrations[goldMigrationsCount + 1] = mig;
          goldMigrationIndexes[msg.sender] = goldMigrationsCount + 1;
          goldMigrationsCount++;

                          
          GoldMigrateWanted(msg.sender, _gmAddress, myBalance);
     }

     function isGoldMigrated(address _who) public constant returns(bool) {
          uint index = goldMigrationIndexes[_who];

          Migration memory mig = goldMigrations[index];
          return mig.migrated;
     }

     function setGoldMigrated(address _who, bool _isMigrated, string _comment) public onlyCreator { 
          uint index = goldMigrationIndexes[_who];
          require(index > 0);

          goldMigrations[index].migrated = _isMigrated; 
          goldMigrations[index].comment = _comment; 

                          
          if (_isMigrated) {
               GoldMigrated(  goldMigrations[index].ethAddress, 
                              goldMigrations[index].gmAddress, 
                              goldMigrations[index].tokensCount);
          }
     }

                                                                             
                                            
     function calculateMyRewardMax(address _of) public constant returns(uint){
          if (0 == mntpToMigrateTotal) {
               return 0;
          }

          uint myCurrentMntpBalance = mntpToken.balanceOf(_of);
          if (0 == myCurrentMntpBalance) {
               return 0;
          }

          return (migrationRewardTotal * myCurrentMntpBalance) / mntpToMigrateTotal;
     }

                                              
        
                                                                      
       
                                                                                       
                                                                                           
                                                                             
     function calculateMyRewardDecreased(uint _day, uint _myRewardMax) public constant returns(uint){
          if (_day >= 365) {
               return 0;
          }

          uint x = ((100 * 1000000000 * _day) / 365);
          return (_myRewardMax * ((100 * 1000000000) - x)) / (100 * 1000000000);
     }
     
     function calculateMyReward(uint _myRewardMax) public constant returns(uint){
                              
          uint day = (uint64(now) - migrationStartedTime) / uint64(1 days);  
          return calculateMyRewardDecreased(day, _myRewardMax);
     }

         
                                                      
     function() external payable {
          revert();
     }
}