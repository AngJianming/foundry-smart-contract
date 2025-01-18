//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import {Crowdfunding} from "./Crowdfunding.sol";
 
contract CrowdfundingFactory {

address public owner; // we only want the owner to do somethings
bool public paused; //paused people from making campaigns
 
//when someone creates a campaign, it will create with this struct
struct Campaign{
address campaignAddress;
address owner;
string name; //name of the campaign.
uint256 creationTime;
}
 
Campaign[] public campaigns;
 
//map an address to all the campaigns they have
mapping(address => Campaign[]) public userCampaigns;
 
modifier onlyOwner(){
require(msg.sender ==owner, "Not owner.");
_;
}
 
modifier notPaused(){
require(!paused, "Factory is not paused");
_;
}
 
constructor(){
owner = msg.sender;
}
 
//the factory will deploy the crowdfunding contract after the user inputs the variables like name, description all
 
function createCampaign(
string memory _name,
string memory _description,
uint256 _goal,
uint256 _durationInDays
) external notPaused{
 
//deploy the crowdfunding contract
Crowdfunding newCampaign = new Crowdfunding(msg.sender, _name ,
_description,
_goal,
_durationInDays
);

//store this address
address campaignAddress = address(newCampaign);
 
//using the campaign struct, we will create campaign
 
Campaign memory campaign = Campaign({
campaignAddress: campaignAddress,
owner:msg.sender,
name: _name,
creationTime: block.timestamp
});
 
//add to our array of campaign
campaigns.push(campaign);
//map it to the msg sender
userCampaigns[msg.sender].push(campaign);
 
}
 
function getUserCampaigns(address _user)external view returns(Campaign[] memory){
return userCampaigns[_user];
}
 
function getAllCampaigns() external view returns(Campaign[] memory){
return campaigns;
}
 
function togglePause() public onlyOwner{
paused = !paused; //this paused is the boolean variable that trackers the paused state of the contract (which is declared )
// declared at bool public paused.
 
}
 
}