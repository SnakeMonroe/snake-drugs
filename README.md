# Snake Drugs - Core Drug System for RSG

## Description

This resource provides a core drug system for the RedM server, allowing players to gather ingredients, process them into drugs, and potentially distribute or consume them.

## Implemented Features

-   Opium processing
-   Drug selling

## Configuration

The drug system is configured through the `config.lua` file. This file defines the available drugs, their ingredients, output, and processing locations.

### `config.lua`

-   **`Config.Drugs`**: A table containing definitions for each drug.
    -   **`label`**: The name of the drug.
    -   **`ingredients`**: A table listing the required ingredients and their amounts.
    -   **`output`**: A table defining the output item and amount.
    -   **`enabled`**: A boolean indicating whether the drug is enabled.
    -   **`sell`**: A table containing selling related configurations.
        -   **`enabled`**: A boolean indicating whether selling is enabled for the drug.
        -   **`price`**: The price per unit sold.
        -   **`lawAlertChance`**: The chance to alert law enforcement when selling.
    -   **`locations`**: A table containing the processing locations for the drug.

    -   **`Config.Tools`**: A table containing configurations for tools.
        -   **`pestleandmortar`**: Configuration for the pestle and mortar tool.
            -   **`degrade`**: A boolean indicating whether the tool degrades with use.
            -   **`loss`**: The amount of quality lost per use.
            -   **`breakAt`**: The quality level at which the tool breaks.
            -   **`defaultQuality`**: The starting quality of the tool.

## Usage

1.  Gather the required ingredients for a drug.
2.  Travel to a processing location defined in `config.lua`.
3.  Use the appropriate interaction (e.g., through `ox_target`) to start processing the drug.
4.  The system will check for the required ingredients, remove them from the player's inventory, and give the player the output item.

## Client Side

The client side handles the following:

-   Displaying notifications to the player.
-   Handling drug processing zones.
-   Toggling drug selling mode with the `/drugsell` command.
-   Spawning drug buyer NPCs when selling is active.

## Server Side

The server side handles the following:

-   Processing drug requests from players.
-   Checking for required ingredients.
-   Removing ingredients from the player's inventory.
-   Giving the player the output item.
-   Handling drug selling logic.
-   Alerting law enforcement based on drug selling configuration.

## Dependencies

-   RedM
-   `ox_lib`
-   `ox_target`
-   `rsg-inventory`
-   `rsg-core`

## Installation

1.  Place the `snake-drugs` resource folder in your server's resources directory.
2.  Add `ensure snake-drugs` to your server's `server.cfg` file.
3.  Configure the drugs and processing locations in `config.lua`.
4.  Ensure that `ox_lib`, `ox_target`, `rsg-inventory`, and `rsg-core` are installed and running on your server.

## Credits

-   This resource was created by \[Snake].

## License

This resource is licensed under the MIT License.
