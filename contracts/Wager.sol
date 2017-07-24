pragma solidity ^0.4.2;

contract Wager {
    event BetPlaced(address from, string artist, uint roundNum, uint totalPot);
    event RoundOver(address[] winners, string songData, uint payout, uint contractBalance, uint totalPot);

    address public owner = msg.sender;
    uint public roundNumber;
    mapping(uint => Round) rounds;

    struct Round {
        mapping(bytes => address[]) bets;
        uint betCount;
        bool isRoundCashed;
        uint pot;
        bytes songData;
    }

    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }

    function endRound(bytes artist, bytes songData) onlyBy(owner) {
        var thisRound = rounds[roundNumber];

        if(thisRound.isRoundCashed) {
            return;
        }

        if(thisRound.bets[artist].length == 0) {
            roundNumber++;
            rounds[roundNumber].pot = thisRound.pot;
            RoundOver(thisRound.bets[artist], string(songData), 0, this.balance, thisRound.pot);
            return;
        }

        var payout = thisRound.pot/thisRound.bets[artist].length;

        for(uint128 i = 0; i < thisRound.bets[artist].length; i++) {
            thisRound.bets[artist][i].transfer(payout);
        }

        thisRound.isRoundCashed = true;
        thisRound.songData = songData;
        roundNumber++;
        RoundOver(thisRound.bets[artist], string(songData), payout, this.balance, thisRound.pot);
    }

    function bet(bytes artist) payable {
        var thisRound = rounds[roundNumber];

        if(msg.value != 1 ether) {
            return;
        }

        thisRound.pot += msg.value;
        thisRound.bets[artist].push(msg.sender);
        thisRound.betCount++;
        BetPlaced(msg.sender, string(artist), roundNumber, thisRound.pot);
    }

    function betFuture(bytes artist, uint numberOfRounds) payable {
        if(msg.value/numberOfRounds != 1) {
            return;
        }
        for(uint i = 0; i < numberOfRounds; i++) {
          var thisRound = rounds[roundNumber + i];

          thisRound.pot += msg.value;
          thisRound.bets[artist].push(msg.sender);
          thisRound.betCount++;
          BetPlaced(msg.sender, string(artist), roundNumber + i, thisRound.pot);
        }
    }

    function getLastSong() constant returns(bytes data) {
        return rounds[roundNumber-1].songData;
    }
}
