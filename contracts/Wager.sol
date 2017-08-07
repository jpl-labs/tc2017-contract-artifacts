pragma solidity ^0.4.2;

contract Wager {
    event BetPlaced(address from, string artist, uint roundNum, uint totalPot);
    event RoundOver(address[] winners, string songData, uint payout, uint roundNumber, uint totalPot);

    address public owner = msg.sender;
    uint public roundNumber;
    mapping(uint => Round) rounds;
    uint public houseWager = 20 ether;

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

    function Wager() payable {

    }

    function endRound(bytes artist, bytes songData) onlyBy(owner) {
        if(rounds[roundNumber].isRoundCashed) {
            return;
        }

        rounds[roundNumber].songData = songData;

        if(rounds[roundNumber].bets[artist].length == 0) {
            rounds[roundNumber].isRoundCashed = true;
            roundNumber++;
            if((roundNumber % 10) == 0) {
                houseWager += 1 ether;
            }
            rounds[roundNumber].pot += rounds[roundNumber - 1].pot;
            rounds[roundNumber].pot += houseWager;
            RoundOver(rounds[roundNumber].bets[artist], string(songData), 0, (roundNumber - 1), rounds[roundNumber].pot);
            return;
        }   

        var payout = rounds[roundNumber].pot/rounds[roundNumber].bets[artist].length;

        for(uint128 i = 0; i < rounds[roundNumber].bets[artist].length; i++) {
            rounds[roundNumber].bets[artist][i].transfer(payout);
        }

        rounds[roundNumber].isRoundCashed = true;
        roundNumber++;
        if((roundNumber % 10) == 0) {
            houseWager += 1 ether;
        }
        rounds[roundNumber].pot += houseWager;
        RoundOver(rounds[roundNumber].bets[artist], string(songData), payout, (roundNumber - 1), rounds[roundNumber].pot);
    }

    function bet(bytes artist) payable {
        if(msg.value != 1 ether) {
            msg.sender.transfer(msg.value);
            return;
        }

        rounds[roundNumber].pot += msg.value;
        rounds[roundNumber].bets[artist].push(msg.sender);
        rounds[roundNumber].betCount++;
        BetPlaced(msg.sender, string(artist), roundNumber, rounds[roundNumber].pot);
    }

    function betFuture(bytes artist, uint numberOfRounds) payable {
        var betVal = msg.value/numberOfRounds;

        if(numberOfRounds > 50 || betVal != 1 ether) {
            msg.sender.transfer(msg.value);
            return;
        }

        for(uint i = 0; i < numberOfRounds; i++) {
          rounds[roundNumber + i].pot += betVal;
          rounds[roundNumber + i].bets[artist].push(msg.sender);
          rounds[roundNumber + i].betCount++;
        }
        BetPlaced(msg.sender, string(artist), roundNumber, rounds[roundNumber].pot);
    }

    function getLastSong() constant returns(bytes data) {
        return rounds[roundNumber - 1].songData;
    }
}
