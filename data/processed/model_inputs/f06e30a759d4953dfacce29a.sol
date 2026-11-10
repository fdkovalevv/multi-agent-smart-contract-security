contract TimedCrowdsale {
                                                  
  function isSaleFinished() view public returns (bool) {
                                       
    return block.timestamp >= 1546300800;
  }
}