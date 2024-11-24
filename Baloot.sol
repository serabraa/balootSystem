// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Ballot {

    struct Voter 
    {
    uint weight;
    bool voted;
    uint vote; 
    }


    struct Proposal {
        uint voteCount;
}
    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;       //array of proposals
    enum Phase {Init, Regs, Vote, Done}

    Phase public state = Phase.Init;


    modifier validPhase(Phase reqPhase){        //modifier is for making and enforcing rules.
        require(state == reqPhase);
        _;
    }
    modifier onlyChair(){
        require(msg.sender == chairperson);
        _;
    }


    constructor (uint numProposals) {//runs while deployment process
    chairperson = msg.sender;
    voters[chairperson].weight = 2; 
    for (uint prop = 0; prop < numProposals; prop ++)
        proposals.push(Proposal(0));
    state = Phase.Regs; // if initialized => registered
    }

    function changeState(Phase x) onlyChair public {
        require(x > state);
        state =x;
    }

    function register(address voter) public validPhase(Phase.Regs) onlyChair {
        require(! voters[voter].voted); //if true means voters have not voted yet
        voters[voter].weight = 1;
        // voters[voter].voted = false;
    }

    function vote(uint toProposal) public validPhase(Phase.Vote){
        Voter memory sender = voters[msg.sender];
        require(!sender.voted); //requires that sender has not voted yet
        require(toProposal< proposals.length); //also requires that the sender votes in a range of proposals,(f.e from 1 to 4)
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;

    }

    function regWinner() public validPhase(Phase.Done) view returns (uint winningProposal){
        uint winningVoteCount = 0;
        for (uint prop = 0; prop<proposals.length; prop++)
            if (proposals[prop].voteCount > winningVoteCount){
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
            assert(winningVoteCount>2);
    }


}