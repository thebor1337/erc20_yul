// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC20.sol";

contract MyTokenFactory {
    
    address public tokenAddress;
    bytes public bytecode;
    // bytes public bytecode = hex"610df360010180380380826000396000516000556100206020516002610043565b61002d6040516003610043565b606051600455610ce861010b600039610ce86000f35b8151600f8111600081146100605761005b84846100b3565b61006b565b61006a8484610071565b5b50505050565b81517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff006020840151808216905060028302821916811790508084555050505050565b81516001600282020182558160005260206000206020820460208106156100db576001810190505b6020850160005b82811015610101578151818501556020820191506001810190506100e2565b5050505050505056fe61000b600b3415610781565b61001361043a565b638da5cb5b81146100bd576306fdde0381146100d2576395d89b4181146100e75763313ce56781146100fc576370a082318114610111576318160ddd81146101305763a9059cbb8114610145576323b872dd811461016e5763095ea7b381146101a15763dd62ed3e81146101cb576340c10f1981146101f4576339509351811461021d5763a457c2d78114610247576342966c688114610271576379cc6790811461029157600080fd5b6100cd6100c86105ac565b6104b3565b6102b6565b6100e26100dd610591565b6104cc565b6102b6565b6100f76100f261059a565b6104cc565b6102b6565b61010c6101076105a3565b6104bf565b6102b6565b61012b6101266101216000610469565b6105cc565b61049d565b6102b6565b61014061013b6105bc565b61049d565b6102b6565b6101616101526001610446565b61015c6000610469565b61034a565b6101696104a7565b6102b6565b61019461017b6002610446565b6101856001610469565b61018f6000610469565b610359565b61019c6104a7565b6102b6565b6101be6101ae6001610446565b6101b86000610469565b336103a5565b6101c66104a7565b6102b6565b6101ef6101ea6101db6001610469565b6101e56000610469565b6105df565b61049d565b6102b6565b6102106102016001610446565b61020b6000610469565b6102bc565b6102186104a7565b6102b6565b61023a61022a6001610446565b6102346000610469565b336103d6565b6102426104a7565b6102b6565b6102646102546001610446565b61025e6000610469565b33610408565b61026c6104a7565b6102b6565b61028461027e6000610446565b336102f3565b61028c6104a7565b6102b6565b6102ad61029e6001610446565b6102a86000610469565b61030c565b6102b56104a7565b5b50610ce7565b6102ce600a6102c9610bd3565b610781565b6102d9600482610794565b6102e38282610639565b6102ef828260006104dc565b5050565b6102fe600582610794565b6103088282610330565b5050565b610317600582610794565b6103228233836106a8565b61032c8282610330565b5050565b61033a828261065d565b610346826000836104dc565b5050565b610355828233610374565b5050565b6103648333836106a8565b61036f838383610374565b505050565b61037f600182610794565b61038a600283610794565b61039583838361067c565b6103a08383836104dc565b505050565b6103b0600782610794565b6103bb600883610794565b6103c6838383610697565b6103d183838361050f565b505050565b6103e1600782610794565b6103ec600883610794565b6103f783838361072f565b61040281848461050f565b50505050565b610413600782610794565b61041e600883610794565b6104298383836106fc565b61043481848461050f565b50505050565b6000803560e01c905090565b6000602082026004016020810136101561045f57600080fd5b8035915050919050565b600061047482610446565b905073ffffffffffffffffffffffffffffffffffffffff1981161561049857600080fd5b919050565b8060005260206000f35b6104b1600161049d565b565b6104bc8161049d565b50565b6104c9815461049d565b50565b6104d7600082610be4565b806000f35b7fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef61050984848484610542565b50505050565b7f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92561053c84848484610542565b50505050565b8360005282828260206000a350505050565b600090565b60006001905090565b600081611000019050919050565b600061057b82610562565b8060005283602052604060002091505092915050565b60006002905090565b60006003905090565b60006004905090565b60006105b6610554565b54905090565b60006105c6610559565b54905090565b60006105d782610562565b549050919050565b60006105eb8383610570565b54905092915050565b6105fd81610562565b610608838254610763565b8155505050565b61061881610562565b805461062d856106288387610755565b610781565b83810382555050505050565b61064382826105f4565b61064b610559565b610656838254610763565b8155505050565b6106696006838361060f565b610671610559565b828154038155505050565b6106886003848361060f565b61069283836105f4565b505050565b826106a28383610570565b55505050565b6106b28282610570565b80547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff81146106f5576106ef60096106ea8388610755565b610781565b84810382555b5050505050565b60006107088383610570565b805461071e60006107198389610755565b610781565b858103925082825550509392505050565b600061073b8383610570565b80546107478682610763565b925082825550509392505050565b600082821115905092915050565b60008282019050828110828210171561077b57600080fd5b92915050565b806107905761078f826107a2565b5b5050565b61079e8282610781565b5050565b6040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602481016000836000811461083b576001811461089457600281146108ed5760038114610946576004811461099f57600581146109d25760068114610a2b5760078114610a845760088114610add5760098114610b3657600a8114610b6957600b8114610b9c57600080fd5b60409150602583527f45524332303a2064656372656173656420616c6c6f77616e63652062656c6f7760208401527f207a65726f0000000000000000000000000000000000000000000000000000006040840152610bcb565b60409150602583527f45524332303a207472616e736665722066726f6d20746865207a65726f20616460208401527f64726573730000000000000000000000000000000000000000000000000000006040840152610bcb565b60409150602383527f45524332303a207472616e7366657220746f20746865207a65726f206164647260208401527f65737300000000000000000000000000000000000000000000000000000000006040840152610bcb565b60409150602683527f45524332303a207472616e7366657220616d6f756e742065786365656473206260208401527f616c616e636500000000000000000000000000000000000000000000000000006040840152610bcb565b60209150601f83527f45524332303a206d696e7420746f20746865207a65726f2061646472657373006020840152610bcb565b60409150602183527f45524332303a206275726e2066726f6d20746865207a65726f2061646472657360208401527f73000000000000000000000000000000000000000000000000000000000000006040840152610bcb565b60409150602283527f45524332303a206275726e20616d6f756e7420657863656564732062616c616e60208401527f63650000000000000000000000000000000000000000000000000000000000006040840152610bcb565b60409150602483527f45524332303a20617070726f76652066726f6d20746865207a65726f2061646460208401527f72657373000000000000000000000000000000000000000000000000000000006040840152610bcb565b60409150602283527f45524332303a20617070726f766520746f20746865207a65726f20616464726560208401527f73730000000000000000000000000000000000000000000000000000000000006040840152610bcb565b60209150601d83527f45524332303a20696e73756666696369656e7420616c6c6f77616e63650000006020840152610bcb565b60209150601983527f4d544b3a206d696e74206173206e6f7420616e206f776e6572000000000000006020840152610bcb565b60209150601983527f4d544b3a204554482066756e647320726573747269637465640000000000000060208401525b508060440183fd5b600033610bde6105ac565b14905090565b600081547fff00000000000000000000000000000000000000000000000000000000000000811660008114610c2457610c1d8286610c3a565b9250610c32565b610c2f828686610c84565b92505b505092915050565b60007fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0060028482191604848216602085528160208601528060408601526060935050505092915050565b600060026001850304826000526020600020602082046020830615610caa576001810190505b602086528260208701526040935060005b81811015610cdc578083015485880152602085019450600181019050610cbb565b505050509392505050565b00";

    constructor(bytes memory _bytecode) {
        setBytecode(_bytecode);
    }

    function setBytecode(bytes memory _bytecode) public {
        bytecode = _bytecode;
    }

    // owner, name, symbol, decimals
    function args(address, string calldata, string calldata, uint256) external pure returns(bytes memory) {
        assembly {
            let size := sub(calldatasize(), 4)
            calldatacopy(0x40, 4, size)
            mstore(0x00, 0x20)
            mstore(0x20, size)
            return(0, add(0x40, size))
        }
    }

    function concatBytecodeArgs(
        address, 
        string calldata, 
        string calldata, 
        uint256
    ) external view returns(bytes memory) {
        bytes memory _bytecode = bytecode;
        assembly {
            let bytecodeSize := mload(_bytecode)
            let ptr := mload(0x40)
            let diff := sub(sub(ptr, 0xa0), bytecodeSize)
            let shiftedPtr := sub(ptr, diff)
            let cdSize := sub(calldatasize(), 4)
            calldatacopy(shiftedPtr, 4, cdSize)

            let totalSize := add(bytecodeSize, cdSize)
            mstore(0x60, 0x20)
            mstore(0x80, totalSize)
            return(0x60, add(0x40, add(diff, totalSize)))
        }
    }

    function createToken() external {
        bytes memory _bytecode = bytecode;
        assembly {
           let addr := create(0, add(_bytecode, 0x20), mload(_bytecode))
           if iszero(addr) {
               revert(0, 0)
           }
           sstore(tokenAddress.slot, addr)
       }
    }

    function createToken2(address, string calldata, string calldata, uint256) external {
        bytes memory _bytecode = bytecode;
        assembly {
            let bytecodeSize := mload(_bytecode)
            let ptr := mload(0x40)
            let diff := sub(sub(ptr, 0xa0), bytecodeSize)
            let shiftedPtr := sub(ptr, diff)

            let cdSize := sub(calldatasize(), 4)
            calldatacopy(shiftedPtr, 4, cdSize)
            
            let addr := create(0, add(_bytecode, 0x20), add(mload(_bytecode), cdSize))
            if iszero(addr) {
                revert(0, 0)
            }
            
            sstore(tokenAddress.slot, addr)
        }
    }
}