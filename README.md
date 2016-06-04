# PatreonSlurp

**Using Patreon API Keys; pulls list of patrons to a file and cents donated to a configurable file.**

## Installation

To get started, follow the guide below:

  1. Ensure [Elixir](http://elixir-lang.org/install.html) is fully installed on the target machine.
  2. Clone this repo to the target machine.
  3. Navigate to <repo folder>/config/config.exs. Modify this file following the notes provided.
  4. Navigate a shell window to the repo folder and type the following to download dependencies:

        mix deps.get

  5. Now type the following to build the project:

        **WINDOWS(cmd):**
        set "MIX_ENV=prod" && mix escript.build
        **UNIX(bash)**
        MIX_ENV=prod mix escript.build

        **NOTE: This needs to be run after any following config changes.**

  6. Use the following command under the repo directory to run it:
        
        escript patreon_slurp

  7. File output will look like the following:

        <patron_name_1>
        <cents_donated_1>
        <patron_name_2>
        <cents_donated_2>
        <patron_name_n>
        <cents_donated_n>
