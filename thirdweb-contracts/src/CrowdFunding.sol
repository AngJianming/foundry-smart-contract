//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Crowdfunding{
    //state variable:
    string public name;// name of the campaign
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;
    bool public paused;


enum CampaignState {Active, Successful, Failed}
CampaignState public state;

struct Tier{
    string name;
    uint256 amount;
    uint256 backers;
}

struct Backer {
uint256 totalContribution; //store a number that is called the total contribution
mapping(uint256 =>bool) fundedTiers; //key to value pairing, map a value (uint256) (which is the index tier)
//why it knows it's the index tier, is becuz when u fund, you pass this index as an argument d. This establishes the expectation that any uint256 key in the fundedTiers mapping corresponds to a valid tier index.
//like hey, did this backer fund the tier, true or false.
}


Tier[] public tiers;
mapping(address=>Backer) public backers;

modifier notPaused(){
    require(!paused, "Contract is paused.");
    _;
}

modifier campaignOpen(){
    require(state == CampaignState.Active, "The campaign is not active.");
    _;
}

modifier onlyOwner(){
    require(msg.sender == owner, "Not the owner");
    _;
}

constructor (
    //parameters;
    address _owner,
    string memory _name, // the other one is storage
    string memory _description,
    uint256 _goal,
    uint256 _durationInDays
    

){
    //logic 
     owner= _owner;
    name = _name;
    description= _description;
    goal=_goal;
    deadline= block.timestamp +(_durationInDays *1 days);
   
    state=CampaignState.Active;
}

// constructor(string memory _name, string memory _description, uint256 _goal, uint256 _deadline)
// 	public {
// 	name = _name;
// 	description = _description;
// 	goal = _goal;
// 	deadline = _deadline;
// } but need to calc deadline so need to have parameters and logic.

function checkAndUpdateCampaign() internal {
    if(state ==CampaignState.Active){
    if(block.timestamp >=deadline){
    state = address(this).balance >= goal ?CampaignState.Successful : CampaignState.Failed;
    //so like If the goal is reached after the deadline then update the state to successful, if not, failed.
    } else { //if deadline not yet reach
    state = address(this).balance >= goal ?CampaignState.Successful : CampaignState.Active;
    //so if reach goal jiu successful, or else the campaign still remain active.
    }
    }

}

//write update 
function fund(uint256 _tierIndex) public payable campaignOpen notPaused {
    // require(msg.value>0, "Must fund amount more than 0."); //CTRL +K+C 
    require(block.timestamp<deadline, "Campaign has ended.");

    require(_tierIndex<tiers.length, "Invalid tier.");
    require(msg.value ==tiers[_tierIndex].amount, "Incorrect amount");

    tiers[_tierIndex].backers++;

    //newly added
    backers[msg.sender].totalContribution += msg.value;
    backers[msg.sender].fundedTiers[_tierIndex]=true;

    checkAndUpdateCampaign();

    // payable(msg.sender).transfer(msg.value);
}

function addTier( string memory _name, uint256 _amount)  public onlyOwner{
            require(_amount>0, "Amount must be greater than zero.");
            tiers.push(Tier(_name, _amount, 0)); //0 is the amount of backers

        }

function removeTier(uint256 _index ) public onlyOwner{
require(_index <tiers.length, "Tier does not exist");
tiers[_index] = tiers[tiers.length -1]; //tiers at that index will be replaced with the tier after it,

tiers.pop(); 
}

//write update 
function withdraw() public{
    require(msg.sender == owner, "You are not the owner");
    require(address(this).balance >=goal, "The goal has not been reached.");
    checkAndUpdateCampaign();
    require(state==CampaignState.Successful, "campaign not successful yet.");
    uint256 balance = address(this).balance;
    require (balance >0, "No balance to withdraw");

    payable(owner).transfer(balance);

}

//read
function getContractBalance() public view returns(uint256){
    return address(this).balance;
}

function refund() public{

checkAndUpdateCampaign();
//comment it first or else cant run
require(state ==CampaignState.Failed,"Refunds not avaialble.");
 
//create a variable named amount for the refund amount
uint256 amount =backers[msg.sender].totalContribution;
require(amount >0, "nothing to be refund as no contribution.");
 
//so if u got it back,
backers[msg.sender].totalContribution=0;
//so now transger back the money
payable(msg.sender).transfer(amount);
}
 

//take user u want to check
   function hasFundedTier(address _backer, uint256 _tierIndex) public view returns (bool) {
        return backers[_backer].fundedTiers[_tierIndex];
        //just check if this backer has funded the tier index
    }
 
//return the array of tiers
function getTiers() public view returns (Tier[] memory){
return tiers;
}
 
//change the state of the contract whether is it pasued, or unpaused
function togglePause() public onlyOwner{
paused = !paused; //this paused is the boolean variable that trackers the paused state of the contract (which is declared )
// declared at bool public paused.
 
 
}
 
//returns the campaign status
function getCampaignStatus() public view returns (CampaignState) {
        if (state == CampaignState.Active && block.timestamp > deadline) {
            return address(this).balance >= goal ? CampaignState.Successful : CampaignState.Failed;
        }
        return state;
    }

 
//when crreator input days to add
function extendDeadLine(uint256 _daysToAdd) public onlyOwner campaignOpen {
deadline += _daysToAdd *1 days;
}
}
