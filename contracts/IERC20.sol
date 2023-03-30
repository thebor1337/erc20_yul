// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {

    // 0x8da5cb5b
    /// @dev In testing purposes to simplify mint process
    function owner() external view returns(address);

    // 0x06fdde03
    function name() external view returns(string memory);
    // 0x95d89b41
    function symbol() external view returns(string memory);
    // 0x313ce567
    function decimals() external view returns(uint8);

    // 0x18160ddd
    function totalSupply() external view returns(uint256);
    // 0x70a08231
    function balanceOf(address _owner) external view returns(uint256 balance);  
    // 0xdd62ed3e
    function allowance(address _owner, address _spender) external view returns(uint256 remaining);

    // 0xa9059cbb
    function transfer(address _to, uint256 _value) external returns(bool success);
    // 0x23b872dd
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool success);
    
    // 0x095ea7b3
    function approve(address _spender, uint256 _value) external returns(bool success);
    // 0x39509351
    function increaseAllowance(address _spender, uint256 _value) external returns(bool success);
    // 0xa457c2d7
    function decreaseAllowance(address _spender, uint256 _value) external returns(bool success);
    
    // 0x40c10f19
    function mint(address _owner, uint256 _value) external returns(bool success);
    // 0x42966c68
    function burn(uint256 _value) external returns(bool success);
    // 0x79cc6790
    function burnFrom(address _owner, uint256 _value) external returns(bool success);

    // ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    // 8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}