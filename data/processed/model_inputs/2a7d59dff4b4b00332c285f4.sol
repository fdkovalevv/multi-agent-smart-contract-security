contract Blockjack {
  
  event GameEnded(uint256 gameID, address player, uint gameResult, uint256 wager, uint256 payout, uint8 playerHand, uint8 houseHand);
  event GameNeedsTick(uint256 gameID, address player, uint256 actionBlock);

  using GameLib for GameLib.Game;

  GameLib.Game[] games;
  mapping (address => uint256) public currentGame;

                     
  uint256 public minBet = 10 finney;
  uint256 public maxBet = 500 finney;
  bool public allowsNewGames = true;
  uint256 public maxBlockActions = 10;

  mapping (uint256 => uint256) blockActions;

        
  address public DX;
  address public DEV;

  uint256 public initialBankroll;
  uint256 public currentBankroll;

  mapping (address => bool) public isOwner;

  modifier onlyOwner {
    if (!isOwner[msg.sender]) throw;
    _;
  }

  modifier only(address x) {
    if (msg.sender != x) throw;
    _;
  }

  modifier onlyPlayer(uint256 gameID) {
    if (msg.sender != games[gameID].player) throw;
    _;
  }

  modifier blockActionProtected {
    blockActions[block.number] += 1;
    if (blockActions[block.number] > maxBlockActions) throw;
    _;
  }

  function Blockjack(address _DX, address _DEV) {
    DX = _DX;
    DEV = _DEV;
    games.length += 1;
    games[0].init(0);                                     
    games[0].player = this;
    isOwner[DX] = true;
    isOwner[DEV] = true;
  }

  function () payable {
    startGame();
  }

  function startGame() blockActionProtected payable {
    if (!allowsNewGames) throw;
    if (msg.value < minBet) throw;
    if (msg.value > maxBet) throw;

                                      
    uint256 currentGameId = currentGame[msg.sender];
    if (games.length > currentGameId) {
      GameLib.Game openedGame = games[currentGameId];
      if (openedGame.player == msg.sender && !openedGame.closed) {                                      
	if (!openedGame.tick()) throw;
	if (!openedGame.closed) throw;                                        
	recordEndedGame(currentGameId);
      }
    }
    uint256 newGameID = games.length;

    games.length += 1;
    games[newGameID].init(newGameID);
    currentGame[msg.sender] = newGameID;
    tickRequiredLog(games[newGameID]);
  }

  function hit(uint256 gameID) onlyPlayer(gameID) blockActionProtected {
    GameLib.Game game = games[gameID];
    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.Hit);
    tickRequiredLog(game);
  }

  function doubleDown(uint256 gameID) onlyPlayer(gameID) blockActionProtected payable {
    GameLib.Game game = games[gameID];
    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.DoubleDown);
    tickRequiredLog(game);
  }

  function stand(uint256 gameID) onlyPlayer(gameID) blockActionProtected {
    GameLib.Game game = games[gameID];
    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.Stand);
    tickRequiredLog(game);
  }

  function gameTick(uint256 gameID) blockActionProtected {
    GameLib.Game openedGame = games[gameID];
    if (openedGame.closed) throw;
    if (!openedGame.tick()) throw;
    if (openedGame.closed) recordEndedGame(gameID);
  }

  function recordEndedGame(uint gameID) private {
    GameLib.Game openedGame = games[gameID];

                                                                          
    if(currentBankroll + openedGame.bet > openedGame.payout){
      currentBankroll = currentBankroll + openedGame.bet - openedGame.payout;
    }

    GameEnded(
	      openedGame.gameID,
	      openedGame.player,
	      uint(openedGame.result),
	      openedGame.bet,
	      openedGame.payout,
	      GameLib.countHand(openedGame.playerCards),
	      GameLib.countHand(openedGame.houseCards)
	      );
  }

  function tickRequiredLog(GameLib.Game storage game) private {
    GameNeedsTick(game.gameID, game.player, game.actionBlock);
  }

              

  function gameState(uint i) constant returns (uint8[], uint8[], uint8, uint8, uint256, uint256, uint8, uint8, bool, uint256) {
    GameLib.Game game = games[i];

    return (
	    game.houseCards,
	    game.playerCards,
	    GameLib.countHand(game.houseCards),
	    GameLib.countHand(game.playerCards),
	    game.bet,
	    game.payout,
	    uint8(game.state),
	    uint8(game.result),
	    game.closed,
	    game.actionBlock
	    );
  }


  function changeDev(address newDev) only(DEV) {
    isOwner[DEV] = false;
    DEV = newDev;
    isOwner[DEV] = true;
  }

  function changeDX(address newDX) only(DX) {
    isOwner[DX] = false;
    DX = newDX;
    isOwner[DX] = true;
  }

  function setSettings(uint256 _min, uint256 _max, uint256 _maxBlockActions) only(DX) {
    minBet = _min;
    maxBet = _max;
    maxBlockActions = _maxBlockActions;
  }

  function registerOwner(address _new_watcher) only(DX) {
    isOwner[_new_watcher] = true;
  }

  function removeOwner(address _old_watcher) only(DX) {
    isOwner[_old_watcher] = false;
  }

  function stopBlockjack() onlyOwner {
    allowsNewGames = false;
  }

  function startBlockjack() only(DX) {
    allowsNewGames = true;
  }

  function addBankroll() only(DX) payable {
    initialBankroll += msg.value;
    currentBankroll += msg.value;
  }

  function migrateBlockjack() only(DX) {
    stopBlockjack();
    shareProfits();
    suicide(DX);
  }

  uint256 DX_PROFITS = 90;
  uint256 DEV_PROFITS = 10;
  uint256 PROFITS_BASE = 100;
  
  function shareProfits() onlyOwner{
    if (currentBankroll <= initialBankroll) return;                        
    uint256 profit = currentBankroll - initialBankroll;
    uint256 notSent;
    if (!DX.send(profit * DX_PROFITS / PROFITS_BASE)) {
      notSent = profit * DX_PROFITS / PROFITS_BASE;
    }
    if (!DEV.send(profit * DEV_PROFITS / PROFITS_BASE)){
      notSent = profit * DEV_PROFITS / PROFITS_BASE;
    }
    currentBankroll -= profit - notSent;
  }


  
}