// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Redpacket{
    //定义红包发放的主题
    address payable public yideng;
    // 红包的金额
    uint256 public totalAmount;
    // 红包的个数
    uint256 public count;
    // 剩余红包个数
    uint256 public remainingCount;
    // 剩余金额
    uint256 public remainingAmount;
    //是否是等额红包
    bool public isEqual;
    // 谁抢过红包
    mapping(address => bool) public isGrabbed;
    // 抢红包记录
    mapping(address => uint256) public grabbedAmount;
    // 红包是否已初始化
    bool public isInitialized;

    event RedPacketCreated(address indexed creator, uint256 totalAmount, uint256 count, bool isEqual);
    event RedPacketGrabbed(address indexed grabber, uint256 amount);
    event RedPacketFinished();

    // 空构造函数
    constructor() {
        // 合约部署时不做任何初始化
    }
    
    // 创建红包的函数（替代原来的构造函数逻辑）
    function createRedPacket(uint256 c, bool _isEqual) external payable {
        // 确保红包没有被初始化过
        require(!isInitialized, "red packet already initialized");
        // 判断下我钱包里是否还有钱
        require(msg.value > 0, "amount must > 0");
        require(c > 0, "count must > 0");
        
        // 付款给合约
        yideng = payable(msg.sender);
        count = c;
        remainingCount = c;
        isEqual = _isEqual;
        totalAmount = msg.value;
        remainingAmount = msg.value;
        isInitialized = true;
        
        emit RedPacketCreated(msg.sender, msg.value, c, _isEqual);
    }
    
    // 获取账户余额
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    // 抢红包
    function grabRedPacket() public {
        require(isInitialized, "red packet not initialized");
        require(remainingCount > 0, "no red packets left");
        require(remainingAmount > 0, "no amount left");
        require(!isGrabbed[msg.sender], "you have already grabbed!");

        uint256 amount;
        
        if(remainingCount == 1){
            // 最后一个红包，给剩余所有金额
            amount = remainingAmount;
        } else {
            if(isEqual){
                // 等额红包
                amount = totalAmount / count;
                // 处理最后一个红包的余数
                if(remainingCount == 1) {
                    amount = remainingAmount;
                }
            } else {
                // 随机红包 - 改进算法
                // 确保每个红包至少1 wei，剩余金额能够分配给剩余红包
                uint256 maxAmount = remainingAmount - (remainingCount - 1);
                require(maxAmount > 0, "insufficient remaining amount");
                
                // 生成1到maxAmount之间的随机数
                amount = (uint256(keccak256(abi.encodePacked(
                    block.timestamp, 
                    msg.sender, 
                    remainingCount,
                    block.difficulty
                ))) % maxAmount) + 1;
            }
        }
        
        require(amount <= remainingAmount, "amount exceeds remaining");
        require(amount > 0, "amount must > 0");
        
        // 更新状态
        isGrabbed[msg.sender] = true;
        grabbedAmount[msg.sender] = amount;
        remainingCount--;
        remainingAmount -= amount;
        
        // 转账
        payable(msg.sender).transfer(amount);
        
        emit RedPacketGrabbed(msg.sender, amount);
        
        if(remainingCount == 0) {
            emit RedPacketFinished();
        }
    }
    
    // 查询用户抢到的金额
    function getGrabbedAmount(address user) public view returns(uint256) {
        return grabbedAmount[user];
    }
    
    // 查询红包状态
    function getRedPacketInfo() public view returns(
        uint256 _totalAmount,
        uint256 _count, 
        uint256 _remainingCount,
        uint256 _remainingAmount,
        bool _isEqual,
        bool _isInitialized
    ) {
        return (totalAmount, count, remainingCount, remainingAmount, isEqual, isInitialized);
    }
    
    // 发起人可以回收剩余资金（可选功能）
    function withdraw() public {
        require(isInitialized, "red packet not initialized");
        require(msg.sender == yideng, "only creator can withdraw");
        require(remainingAmount > 0, "no remaining amount");
        
        uint256 amount = remainingAmount;
        remainingAmount = 0;
        yideng.transfer(amount);
    }
}