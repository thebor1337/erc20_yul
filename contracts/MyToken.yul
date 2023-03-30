object "MyToken" {
    code {
        // sstore(0, caller())

        let argsLocation := add(datasize("args"), dataoffset("args"))
        let argsSize := sub(codesize(), argsLocation)

        datacopy(0, argsLocation, argsSize)

        sstore(0, mload(0x00)) // set owner (manually, because use a factory to deploy)

        storeBytes(2, mload(0x20))
        storeBytes(3, mload(0x40))
        sstore(4, mload(0x60))

        // Deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))

        function storeBytes(slot, pos) {
            let size := mload(pos)
            switch gt(size, 0xf)
            case 0 {
                storeShortBytes(slot, pos)
            }
            default {
                storeLongBytes(slot, pos)
            }
        }

        function storeShortBytes(slotIdx, pos) {
            let size := mload(pos)
            let mask := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
            let _data := mload(add(pos, 0x20))
            _data := and(mask, _data)
            _data := or(_data, and(not(mask), mul(size, 2)))

            sstore(slotIdx, _data)
        }

        function storeLongBytes(slotIdx, pos) {

            let size := mload(pos) // in bytes

            sstore(slotIdx, add(mul(size, 2), 1))

            mstore(0x00, slotIdx)
            let strStorageLoc := keccak256(0x00, 0x20)

            let numSlots := div(size, 0x20)
            if mod(numSlots, 0x20) {
                numSlots := add(numSlots, 1)
            }

            let dataPos := add(pos, 0x20)
            for { let i := 0 } lt(i, numSlots) { i := add(i, 1) } {
                sstore(add(strStorageLoc, i), mload(dataPos))
                dataPos := add(dataPos, 0x20)
            }
        }
    }
    object "runtime" {
        code {
            // No ETH funds allowed
            require(iszero(callvalue()), 11)

            /* -------- Dispatcher ---------- */

            switch selector()
            case 0x8da5cb5b {
                returnAddress(owner())
            }
            case 0x06fdde03 /* "name()" */ {
                returnStorageBytes(namePos())
            }
            case 0x95d89b41 /* "symbol()" */ {
                returnStorageBytes(symbolPos())
            }
            case 0x313ce567 /* "decimals()" */ {
                returnStorageUint(decimalsPos())
            }
            case 0x70a08231 /* "balanceOf(address)" */ {
                returnUint(balanceOf(decodeAsAddress(0)))
            }
            case 0x18160ddd /* "totalSupply()" */ {
                returnUint(totalSupply())
            }
            case 0xa9059cbb /* "transfer(address,uint256)" */ {
                transfer(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            case 0x23b872dd /* "transferFrom(address,address,uint256)" */ {
                transferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2))
                returnTrue()
            }
            case 0x095ea7b3 /* "approve(address,uint256)" */ {
                approve(caller(), decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            case 0xdd62ed3e /* "allowance(address,address)" */ {
                returnUint(allowance(decodeAsAddress(0), decodeAsAddress(1)))
            }
            case 0x40c10f19 /* "mint(address,uint256)" */ {
                mint(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            case 0x39509351 /* "increaseAllowance(address,uint256)" */ {
                increaseAllowance(caller(), decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            case 0xa457c2d7 /* "decreaseAllowance(address,uint256)" */ {
                decreaseAllowance(caller(), decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            case 0x42966c68 /* "burn(uint256)" */ {
                burn(caller(), decodeAsUint(0))
                returnTrue()
            }
            case 0x79cc6790 /* "burnFrom(address,uint256)" */ {
                burnFrom(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            default {
                revert(0, 0)
            }

            function mint(account, value) {
                require(calledByOwner(), 10)
                requireNonZeroAddress(account, 4)
                _mint(account, value)
                emitTransfer(0x00, account, value)
            }

            function burn(account, value) {
                requireNonZeroAddress(account, 5)
                executeBurn(account, value)
            }

            function burnFrom(account, value) {
                requireNonZeroAddress(account, 5)
                _spendAllowance(account, caller(), value)
                executeBurn(account, value)
            }

            function executeBurn(account, value) {
                _burn(account, value)
                emitTransfer(account, 0x00, value)
            }

            function transfer(to, value) {
                executeTransfer(caller(), to, value)
            }

            function transferFrom(from, to, value) {
                _spendAllowance(from, caller(), value)
                executeTransfer(from, to, value)
            }

            function executeTransfer(from, to, value) {
                requireNonZeroAddress(from, 1)
                requireNonZeroAddress(to, 2)
                _transfer(from, to, value)
                emitTransfer(from, to, value)
            }

            function approve(account, spender, value) {
                requireNonZeroAddress(account, 7)
                requireNonZeroAddress(spender, 8)
                _setAllowance(account, spender, value)
                emitApproval(account, spender, value)
            }

            function increaseAllowance(account, spender, value) {
                requireNonZeroAddress(account, 7)
                requireNonZeroAddress(spender, 8)
                let total := _increaseAllowance(account, spender, value)
                emitApproval(account, spender, total)
            }

            function decreaseAllowance(account, spender, value) {
                requireNonZeroAddress(account, 7)
                requireNonZeroAddress(spender, 8)
                let total := _decreaseAllowance(account, spender, value)
                emitApproval(account, spender, total)
            }

            /* ---------- calldata decoding functions ----------- */
            function selector() -> s {
                s := shr(224, calldataload(0))
            }

            function decodeAsUint(offset) -> r {
                // Find position where to start decoding based on offset (offset = index of bytes32 slot)
                // skip first 4 bytes (it's selector)
                let pos := add(4, mul(offset, 0x20))
                // if call data is less than the required data at the desired position - calldata is invalid
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                // load 32 bytes of calldata starting from the desired position
                r := calldataload(pos)
            }

            function decodeAsAddress(offset) -> v {
                v := decodeAsUint(offset)
                // 0x0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4 // v, address in 32 bytes format
                // 0xffffffffffffffffffffffff0000000000000000000000000000000000000000 // mask, checks if there is non-zero bit in [0;12) position
                // 0x0000000000000000000000000000000000000000000000000000000000000000 // AND, if not zero - invalid address
                if and(v, not(0xffffffffffffffffffffffffffffffffffffffff)) {
                    revert(0, 0)
                }
            }

            /* ---------- calldata encoding functions ----------- */

            function returnUint(val) {
                mstore(0, val)
                return(0, 0x20)
            }

            function returnTrue() {
                returnUint(1)
            }

            function returnAddress(addr) {
                returnUint(addr)
            }

            function returnStorageUint(slot) {
                returnUint(sload(slot))
            }

            function returnStorageBytes(slot) {
                let b := copyBytes(slot, 0x00)
                return(0x00, b)
            }

            /* -------- events -------- */

            function emitTransfer(from, to, amount) {
                let signatureHash := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
                emitEvent(signatureHash, from, to, amount)
            }

            function emitApproval(from, spender, amount) {
                let signatureHash := 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
                emitEvent(signatureHash, from, spender, amount)
            }

            function emitEvent(signatureHash, indexed1, indexed2, nonIndexed) {
                mstore(0x00, nonIndexed)
                log3(0x00, 0x20, signatureHash, indexed1, indexed2)
            }

            /* -------- storage layout ---------- */
            
            function ownerPos() -> p { p := 0 }
            function totalSupplyPos() -> p { p := 1 }
            function accountToStoragePos(account) -> pos {
                pos := add(0x1000, account)
            }
            function accountAllowanceStoragePos(account, spender) -> pos {
                let accPos := accountToStoragePos(account)
                mstore(0x00, accPos)
                mstore(0x20, spender)
                pos := keccak256(0x00, 0x40)
            }
            function namePos() -> p { p := 2 }
            function symbolPos() -> p { p := 3 }
            function decimalsPos() -> p { p := 4 }

            /* -------- storage access ---------- */
            
            function owner() -> o {
                o := sload(ownerPos())
            }

            function totalSupply() -> t {
                t := sload(totalSupplyPos())
            }

            function balanceOf(account) -> bal {
                bal := sload(accountToStoragePos(account))
            }

            function allowance(account, spender) -> a {
                a := sload(accountAllowanceStoragePos(account, spender))
            }

            function _addToBalance(account, value) {
                let pos := accountToStoragePos(account)
                sstore(pos, safeAdd(sload(pos), value))
            }

            function _deductFromBalance(account, value, errorType) {
                let pos := accountToStoragePos(account)
                let b := sload(pos)
                require(lte(value, b), errorType)
                sstore(pos, sub(b, value))
            }

            function _mint(account, value) {
                _addToBalance(account, value)
                let pos := totalSupplyPos()
                sstore(pos, safeAdd(sload(pos), value))
            }

            function _burn(account, value) {
                _deductFromBalance(account, value, 6)
                let pos := totalSupplyPos()
                sstore(pos, sub(sload(pos), value))
            }

            function _transfer(from, to, value) {
                _deductFromBalance(from, value, 3)
                _addToBalance(to, value)
            }

            function _setAllowance(account, spender, value) {
                sstore(accountAllowanceStoragePos(account, spender), value)
            }

            function _spendAllowance(account, spender, value) {
                let allowancePos := accountAllowanceStoragePos(account, spender)
                let currentAllowance := sload(allowancePos)
                // don't spend uint(256).max allowance
                if iszero(eq(currentAllowance, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) {
                    require(lte(value, currentAllowance), 9)
                    sstore(allowancePos, sub(currentAllowance, value))
                }
            }

            function _decreaseAllowance(account, spender, value) -> r {
                let allowancePos := accountAllowanceStoragePos(account, spender)
                let currentAllowance := sload(allowancePos)
                require(lte(value, currentAllowance), 0)
                r := sub(currentAllowance, value)
                sstore(allowancePos, r)
            }

            function _increaseAllowance(account, spender, value) -> r {
                let allowancePos := accountAllowanceStoragePos(account, spender)
                let currentAllowance := sload(allowancePos)
                r := safeAdd(currentAllowance, value)
                sstore(allowancePos, r)
            }

            /* ---------- utility functions ---------- */

            // a <= b
            function lte(a, b) -> r {
                r := iszero(gt(a, b))
            }

            // a >= b
            function gte(a, b) -> r {
                r := iszero(lt(a, b))
            }

            function safeAdd(a, b) -> r {
                r := add(a, b)
                if or(lt(r, a), lt(r, b)) {
                    revert(0, 0)
                }
            }

            function require(condition, errorType) {
                if iszero(condition) {
                    revertError(errorType)
                }
            }

            function requireNonZeroAddress(addr, errorType) {
                require(addr, errorType)
            }


            function revertError(errorType) {
                let ptr := mload(0x40)
                mstore(ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(ptr, 0x04), 0x20)
                let startPos := add(ptr, 0x24)
                
                let size
                switch errorType
                // ERC20: decreased allowance below zero
                case 0 {
                    size := 0x40
                    mstore(startPos, 37)
                    mstore(add(startPos, 0x20), "ERC20: decreased allowance below")
                    mstore(add(startPos, 0x40), " zero")
                }
                // ERC20: transfer from the zero address
                case 1 {
                    size := 0x40
                    mstore(startPos, 37)
                    mstore(add(startPos, 0x20), "ERC20: transfer from the zero ad")
                    mstore(add(startPos, 0x40), "dress")
                }
                // ERC20: transfer to the zero address
                case 2 {
                    size := 0x40
                    mstore(startPos, 35)
                    mstore(add(startPos, 0x20), "ERC20: transfer to the zero addr")
                    mstore(add(startPos, 0x40), "ess")
                }
                // ERC20: transfer amount exceeds balance
                case 3 {
                    size := 0x40
                    mstore(startPos, 38)
                    mstore(add(startPos, 0x20), "ERC20: transfer amount exceeds b")
                    mstore(add(startPos, 0x40), "alance")
                }
                // ERC20: mint to the zero address
                case 4 {
                    size := 0x20
                    mstore(startPos, 31)
                    mstore(add(startPos, 0x20), "ERC20: mint to the zero address")
                }
                // ERC20: burn from the zero address
                case 5 {
                    size := 0x40
                    mstore(startPos, 33)
                    mstore(add(startPos, 0x20), "ERC20: burn from the zero addres")
                    mstore(add(startPos, 0x40), "s")
                }
                // ERC20: burn amount exceeds balance
                case 6 {
                    size := 0x40
                    mstore(startPos, 34)
                    mstore(add(startPos, 0x20), "ERC20: burn amount exceeds balan")
                    mstore(add(startPos, 0x40), "ce")
                }
                // ERC20: approve from the zero address
                case 7 {
                    size := 0x40
                    mstore(startPos, 36)
                    mstore(add(startPos, 0x20), "ERC20: approve from the zero add")
                    mstore(add(startPos, 0x40), "ress")
                }
                // ERC20: approve to the zero address
                case 8 {
                    size := 0x40
                    mstore(startPos, 34)
                    mstore(add(startPos, 0x20), "ERC20: approve to the zero addre")
                    mstore(add(startPos, 0x40), "ss")
                }
                // ERC20: insufficient allowance
                case 9 {
                    size := 0x20
                    mstore(startPos, 29)
                    mstore(add(startPos, 0x20), "ERC20: insufficient allowance")
                }
                // MTK: mint as not an owner
                case 10 {
                    size := 0x20
                    mstore(startPos, 25)
                    mstore(add(startPos, 0x20), "MTK: mint as not an owner")
                }
                // MTK: ETH funds restricted
                case 11 {
                    size := 0x20
                    mstore(startPos, 25)
                    mstore(add(startPos, 0x20), "MTK: ETH funds restricted")
                }
                default {
                    revert(0, 0)
                }

                revert(ptr, add(0x44, size))
            }

            function calledByOwner() -> res {
                res := eq(owner(), caller())
            }

            function copyBytes(slotIdx, startPos) -> b {
                let data := sload(slotIdx)
                switch and(data, 0xff00000000000000000000000000000000000000000000000000000000000000)
                case 0 {
                    b := copyLongBytes(slotIdx, startPos, data)
                }
                default {
                    b := copyShortBytes(startPos, data)
                }
            }

            function copyShortBytes(startPos, slotData) -> b {
                let mask := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                let length := div(and(not(mask), slotData), 2)
                let value := and(mask, slotData)

                mstore(startPos, 0x20)
                mstore(add(startPos, 0x20), length)
                mstore(add(startPos, 0x40), value)    

                b := 0x60
            }

            function copyLongBytes(slotIdx, startPos, slotData) -> b {
                let length := div(sub(slotData, 1), 2)
                mstore(0x00, slotIdx)

                let strLocation := keccak256(0x00, 0x20)
                let numSlots := div(length, 0x20)
                if mod(length, 0x20) { // non zero
                    numSlots := add(numSlots, 1)
                }

                mstore(startPos, 0x20)
                mstore(add(startPos, 0x20), length)

                b := 0x40
                for { let i := 0 } lt(i, numSlots) { i := add(i, 1) }
                {
                    mstore(add(startPos, b), sload(add(strLocation, i)))
                    b := add(b, 0x20)
                }
            }
        }
    }

    data "args" hex"00" // args separator (i don't know how to recognize where arguments located while unpacking code in constructor)
}