pragma solidity ^0.8.13;

import "forge-std/console.sol";

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DreamOracle {
   address public operator;
   mapping(address=>uint256) prices;


   constructor() {
       operator = msg.sender;
   }


   function getPrice(address token) external view returns (uint256) {
       require(prices[token] != 0, "the price cannot be zero");
       return prices[token];
   }


   function setPrice(address token, uint256 price) external {
       require(msg.sender == operator, "only operator can set the price");
       prices[token] = price;
   }
}

contract LPT is ERC20("LPT", "LPT") {
    address _admin;
    constructor() {
        _admin = msg.sender;
    }

    modifier onlyAdmin {
        require(_admin == msg.sender, "only Admin");

        _;
    }

    function mint(address account, uint256 amount) onlyAdmin external {
        _mint(account, amount);
    }
}





contract Dex {
    address _tokenX;
    address _tokenY;

    LPT lpt = new LPT();
    DreamOracle oracle = new DreamOracle();

    uint public amountOfX;
    uint public amountOfY;

    constructor(address tokenX, address tokenY) {
        _tokenX = tokenX;
        _tokenY = tokenY;

        oracle.setPrice(_tokenX, 1 ether);
        oracle.setPrice(_tokenY, 1 ether);
    }

    function addLiquidity(
        uint256 tokenXAmount,
        uint256 tokenYAmount,
        uint256 minimumLPTokenAmount
    ) external returns (uint256 LPTokenAmount) {
        require((oracle.getPrice(_tokenX) * tokenXAmount) == (oracle.getPrice(_tokenY) * tokenYAmount));

        uint xBalance = IERC20(_tokenX).balanceOf(address(this));
        uint yBalance = IERC20(_tokenY).balanceOf(address(this));

        IERC20(_tokenX).transferFrom(msg.sender, address(this), tokenXAmount);
        IERC20(_tokenY).transferFrom(msg.sender, address(this), tokenYAmount);

        LPTokenAmount = portion * 1 ether;
        lpt.mint(msg.sender, LPTokenAmount);
    }

    function swap(
        uint256 tokenXAmount,
        uint256 tokenYAmount,
        uint256 tokenMinimumOutputAmount
    ) external returns (uint256 outputAmount) {

    }

    function removeLiquidity(
        uint256 LPTokenAmount,
        uint256 minimumTokenXAmount,
        uint256 minimumTokenYAmount
    ) external returns (uint rx, uint ry) {}

    function transfer(
        address to,
        uint256 lpAmount
    ) external returns (bool) {}
}
