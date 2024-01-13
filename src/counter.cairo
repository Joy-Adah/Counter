#[starknet::interface]
trait ICounter<T> {
    fn get_current_count(self: @T) -> u256;
    fn increment(ref self: T);
    fn decrement(ref self: T);
}

#[starknet::contract]
mod Counter {
    use super::{ICounter, ICounterDispatcher, ICounterDispatcherTrait};
    #[storage]
    struct Storage {
        // Counter variable
        counter: u256,
    }

    #[external(v0)]
    impl Counter of ICounter<ContractState> {
        fn get_current_count(self: @ContractState) -> u256 {
            return self.counter.read();
        }

        fn increment(ref self: ContractState) {
            // Store counter value + 1
            let counter = self.counter.read() + 1;
            self.counter.write(counter);
        }
        fn decrement(ref self: ContractState) {
            // Store counter value - 1
            let counter = self.counter.read() - 1;
            self.counter.write(counter);
        }
    }

    #[cfg(test)]
    mod test {
        use core::serde::Serde;
        use super::{ICounter, Counter, ICounterDispatcher, ICounterDispatcherTrait};
        use starknet::ContractAddress;
        use starknet::contract_address::contract_address_const;
        use core::array::ArrayTrait;
        use snforge_std::{declare, ContractClassTrait};
        use snforge_std::{start_prank, stop_prank, CheatTarget};
        use snforge_std::PrintTrait;
        use core::traits::{Into, TryInto};

        // helper function
        fn deploy_contract() -> ContractAddress {
            let counter_class = declare('Counter');
            let contract_address = counter_class.deploy(@ArrayTrait::new()).unwrap();
            contract_address
        }

        #[test]
        fn test_get_current_count() {
            let contract_address = deploy_contract();
            let dispatcher = ICounterDispatcher{ contract_address };

            assert(dispatcher.get_current_count() == 0, Errors::INVALID_COUNT);
        }

        #[test]
        fn test_increament() {
            let contract_address = deploy_contract();
            let dispatcher = ICounterDispatcher{ contract_address };
            let previous_count = dispatcher.get_current_count();
            dispatcher.increment();

            assert(dispatcher.get_current_count() == previous_count + 1, Errors::INCREAMENT);
        }

        #[test]
        fn test_decreament() {
            let contract_address = deploy_contract();
            let dispatcher = ICounterDispatcher{ contract_address };
            let previous_count = dispatcher.get_current_count();
            dispatcher.decrement();

            assert(dispatcher.get_current_count() == previous_count - 1, Errors::DECREAMENT);
        }

        mod Errors {
            const INVALID_COUNT: felt252 = 'Invalid count';
            const INCREAMENT: felt252 = 'Increament not working';
            const DECREAMENT: felt252 = 'Decreament not working'; 
        }

        #[test]
        mod Account {
            use core::option::OptionTrait;
            use starknet::ContractAddress;
            use core::traits::TryInto;

            fn user1() -> ContractAddress {
                'joy'.try_into().unwrap()
            }

            fn user2() -> ContractAddress {
                'caleb'.try_into().unwrap()
            }
            fn admin() -> ContractAddress {
                'admin'.try_into().unwrap()
            }
        }
    }
}
