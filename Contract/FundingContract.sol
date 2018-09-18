pragma solidity ^0.4.17;

//合约部属合约
contract FundingFactroy{
    //储存所有已经部署成功的合约地址
    address[] public fundings;

    function deploy(string _projectName,uint _supportMoney,uint _goalMoney)public{
        address funding = new Funding( _projectName, _supportMoney, _goalMoney,msg.sender);
        fundings.push(funding);
    }
}


contract Funding{
    bool flag = false;

   //众筹发起人地址(众筹发起人)
   address public manager;
   //项目名称
   string public projectName ;
   //众筹参与人需要付的钱
    uint public supportMoney ;
    //默认众筹结束的时间,为众筹发起后的一个月
    uint public endTime;
     //目标募集的资金(endTime后,达不到目标则众筹失败)
     uint public goalMoney;
     //众筹参与人的数组
     address[] public players;
     //哪些人已经投了票
     mapping(address =>bool)playersmap;
     //付款请求申请的数组(由众筹发起人申请)
     Request[] public requets;

      //付款请求的结构体
      struct Request{
          string description; //为什么要付款
          uint money; //要花多少钱
          address shopAdderss;//把钱打到指定账户
          bool complete; //当前的请求是否完成

         mapping(address =>bool) votedmap;//哪些人已经投了票
        uint votedCount; //投票总数
      }

      ////众筹参与人员批准某一笔付款支出
      function approveRequest(uint index) public{
          Request storage request = requets[index];
          //检查是否已经参与了众筹
          require(playersmap[msg.sender]);
          //检查是否已经投过票
           require(!requets[index].votedmap[msg.sender]);
          request. votedCount ++;
          requets[index].votedmap[msg.sender] = true;
      }
    //众筹发起人付款申请
    function createRequest(string _description,uint _money,address _shopAdderss)public onlyManagerCanCall{
       Request memory  request = Request({
         description : _description,
         money : _money,
         shopAdderss : _shopAdderss,
         complete : false,
         votedCount:0
       });
       requets.push(request);
    }
    function Funding(string _projectName,uint _supportMoney,uint _goalMoney,address _address)public{
       manager = _address;
        projectName = _projectName;
        supportMoney =_supportMoney;
        goalMoney = _goalMoney;
        endTime = now + 4 weeks;
    }
    //众筹参与人(需要付钱)
    function support() public payable{
        require(msg.value == supportMoney);
        players.push(msg.sender);
    }
    //获取参与人数量
    function getPlayersCount()public view returns(uint){
        return players.length;
    }
    //参与人地址
    function getPlayers()public view returns(address[]) {
        return players;
    }
    //获取众筹到的金额
    function getBalance()public view returns(uint){
        return this.balance;
    }
    //判断众筹是否成功 ：1.时间是大于endTime，2.筹集到的钱要大于(goalMoney)目标筹集的钱
    function checkStatus()public returns(bool){
        require(!flag);
        require (now >endTime);
        require (this.balance >goalMoney);
        return flag = true;
    }
    modifier onlyManagerCanCall(){
         //众筹发起人才有发起申请付款的功能
        require(msg.sender == manager);
        _;
    }

}