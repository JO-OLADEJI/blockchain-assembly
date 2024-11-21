object "StoreYul" {
    code {
        // contract deployment
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return (0, datasize("runtime"))
    }

    object "runtime" {
        code {
            // function dispatcher
            switch selector()

            // updateHorseNumber(uint256)
            case 0xcdfead2e {

            }

            // readNumberOfHorses()
            case 0xe026c017 {

            }

            default {
                revert(0, 0)
            }
        }
    }
}
