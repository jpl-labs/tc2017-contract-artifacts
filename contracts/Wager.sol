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

    // Permission modifier to restrict functionality to the address which deploys this contract
    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }

    // Empty constructor so we can seed the contract with funds at deploy-time
    function Wager() payable {

    }

    // Primary game-state end round trigger (typically called from our Node.js oracle service)
    function endRound(bytes artist, bytes songData) onlyBy(owner) {
        require(!rounds[roundNumber].isRoundCashed);

        rounds[roundNumber].songData = songData;

        if (rounds[roundNumber].bets[artist].length == 0) {
            advanceRoundMetadata();

            rounds[roundNumber].pot += rounds[roundNumber - 1].pot;

            RoundOver(rounds[roundNumber].bets[artist], string(songData), 0, (roundNumber - 1), rounds[roundNumber].pot);
            return;
        }   

        var payout = rounds[roundNumber].pot/rounds[roundNumber].bets[artist].length;

        for (uint128 i = 0; i < rounds[roundNumber].bets[artist].length; i++) {
            rounds[roundNumber].bets[artist][i].transfer(payout);
        }

        advanceRoundMetadata();
        RoundOver(rounds[roundNumber].bets[artist], string(songData), payout, (roundNumber-1), rounds[roundNumber].pot);
    }

    // Bet placement mechanism utilized by client
    function bet(bytes artist, uint numberOfRounds) payable {
        var betVal = msg.value/numberOfRounds;
        require(numberOfRounds <= 50 && numberOfRounds >= 1 && betVal == 1 ether);

        for (uint i = 0; i < numberOfRounds; i++) {
          rounds[roundNumber + i].pot += betVal;
          rounds[roundNumber + i].bets[artist].push(msg.sender);
          rounds[roundNumber + i].betCount++;
        }
        BetPlaced(msg.sender, string(artist), roundNumber, rounds[roundNumber].pot);
    }

    // Exposes the previous round's song data
    function getLastSong() constant returns(bytes data) {
        return rounds[roundNumber - 1].songData;
    }

    // Advances the round, marks it cashed, and handles house wager amount increase/application to round pot
    function advanceRoundMetadata() private {
        rounds[roundNumber].isRoundCashed = true;
        roundNumber++;

        if ((roundNumber % 10) == 0) {
            houseWager += 1 ether;
        }

        rounds[roundNumber].pot += houseWager;
    }
}
