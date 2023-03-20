// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/Dex.sol";

contract CustomERC20 is ERC20 {
    constructor(string memory tokenName) ERC20(tokenName, tokenName) {
        _mint(msg.sender, type(uint).max);
    }
}

contract DexTest is Test {
    Dex public dex;
    ERC20 tokenX;
    ERC20 tokenY;

    function setUp() public {
        tokenX = new CustomERC20("XXX");
        tokenY = new CustomERC20("YYY");

        dex = new Dex(address(tokenX), address(tokenY));

        tokenX.approve(address(dex), type(uint).max);
        tokenY.approve(address(dex), type(uint).max);
    }

    // add나 remove 순서 상관없이 철저하게 지분률 대로 동작해야한다는걸 추가 검증해보기위한 추가 테스트
    function testAddLiquidity8() external {
        tokenX.transfer(address(dex), 1000 ether);
        uint lp = dex.addLiquidity(3000 ether, 4000 ether, 0);
        emit log_named_uint("LP", lp);

        tokenX.transfer(address(dex), 1000 ether);
        uint lp2 = dex.addLiquidity(5000 ether, 4000 ether, 0);
        emit log_named_uint("LP", lp);


        address other_eoa = vm.addr(1);
        tokenX.transfer(other_eoa, 10000 ether);
        tokenY.transfer(other_eoa, 10000 ether);
        vm.startPrank(other_eoa);

        tokenX.approve(address(dex), type(uint).max);
        tokenY.approve(address(dex), type(uint).max);

        uint lp3 = dex.addLiquidity(5000 ether, 4000 ether, 0);
        emit log_named_uint("LP3", lp3);

        vm.stopPrank();

        (uint rx, uint ry) = dex.removeLiquidity(lp, 0, 0);
        assertEq(rx, 5000 ether, "rx failed");
        assertEq(ry, 4000 ether, "ry failed");
    }
}
