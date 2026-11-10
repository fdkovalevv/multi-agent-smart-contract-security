contract Looper {

function maximumNumberOfLoops(uint _costSansLoops, uint _loopCost) public constant returns (uint loopLimit) {
    uint gasLimit = getGasLimit();
    uint gasForLoops = gasLimit - _costSansLoops;
    return loopLimit = getLoopLimit(gasForLoops, _loopCost);
}

function canDoLoop(uint _costSansLoops, uint _loopCost, uint _numberOfLoops) public constant returns (bool) {
    uint loopLimit = maximumNumberOfLoops(_costSansLoops, _loopCost);
    if(_numberOfLoops < loopLimit) return true;
    return false;
}

function getGasLimit() internal constant returns (uint) {
    uint gasLimit;

    assembly {
        gasLimit := gaslimit
    }
    return gasLimit;
}

function getLoopLimit(uint _gasForLoops, uint _loopCost) internal constant returns (uint) {
    uint loopLimit = _gasForLoops / _loopCost;
    return loopLimit;
}

}