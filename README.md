# H3M file format

## Info
| contents                | size                | type  | description (optional)                      |
|-------------------------|---------------------|-------|---------------------------------------------|
| map_version             | 0x4                 | int   | Restoration(14), Armageddon(21), Shadow(28) |
| map_playable            | 0x1                 | bool  |                                             |
| map_size                | 0x4                 | int   | Maps are square, this is one side.          |
| has underground         | 0x1                 | bool  |                                             |
| title length            | 0x4                 | int   |                                             |
| title                   | title length        | str   |                                             |
| description length      | 0x4                 | int   |                                             |
| description             | description length  | str   |                                             |
| difficulty              | 0x1                 | int   |                                             |
| unknown#1               | map_version != 0xE  | bytes | Shadow of death only                        |

## Player
| contents                | size                   | type  | description (optional)         |
|-------------------------|------------------------|-------|--------------------------------|
| player_start            | 0x0                    | bytes | offset of where the player is  |
| human_playable          | 0x1                    | bool  | minimum index: 0x13            |
| exists                  | 0x1                    | bool  |                                |
| computer_behaviour      | 0x1                    | int   |                                |
| unknown_arma_shadow     | map_version == 0x1C    | bytes | Armageddon and Shadow only     |
| unknown#1               | 0x1                    | bytes | related to exists              |
| unknown_shadow          | map_version != 0xE     | bytes | Shadow of death only           |
| unknown#2               | 0x1                    | bytes |                                |
| has_main_town           | 0x1                    | bool  |                                |
| main                    | 0x3 * has_main_town    | coord | Coordinate of main town.       |
| unknown#3               | 0x1                    | bytes |                                |
| champion                | 0x1                    | int   | Is 0xff if there are no heroes |
| champion_exists         | champion != 0xff       | bool  | Exists if champion isn't 0xff  |
| champ_name_length       | 0x4 * champion_exists  | int   |                                |
| champ_customname        | champ_name_length      | str   |                                |

## Victory
| contents           | size                       | type  | description (optional)                |
|--------------------|----------------------------|-------|---------------------------------------|
| victory_starts     | 0x0                        | bytes |                                       |
| victory_type       | 0x1                        | int   | 0xff when none                        |
| also allow normal  | victory_type != 0xff       | bool  | 1 when also allow normal victory      |
| applies to pc too  | victory_type != 0xff       | bool  | victory condition also applies to PC  |
| item_to_aquire     | 0x1 * victory_type == 0x0  | int   | Item referece, if artefact victory    |
| creatures_type     | 0x1 * victory_type == 0x1  | int   | Type of creature, if resouce victory  |
| creatures_needed   | 0x4 * victory_type == 0x1  | int   | Num of creatures, if creature victory |
| resources_type     | 0x1 * victory_type == 0x2  | int   | Type of resource, if resource victory |
| resources_needed   | 0x4 * victory_type == 0x2  | int   | Num of resources, if resource victory |
| town_to_upgrade    | 0x3 * victory_type == 0x3  | coord | Coordonates of the town to upgrade    |
| hall_upgrade       | 0x1 * victory_type == 0x3  | int   | Hall level for, if upgrade victory    |
| castle_upgrade     | 0x1 * victory_type == 0x3  | int   | Castle level for, if upgrade victory  |
| town_to_grail      | 0x3 * victory_type == 0x4  | coord | Coordonate of the town to grail       |
| hero_to_defeat     | 0x3 * victory_type == 0x5  | coord | Coordonate of the hero to defeat      |
| town_to_capture    | 0x3 * victory_type == 0x6  | coord | Coordonate of the town to capture     |
| moster_to_defeat   | 0x3 * victory_type == 0x7  | coord | Coordonate of monsters to defeat      |
| item_to_transport  | 0x1 * victory_type == 0xA  | int   | Item referece, if transport victory   |
| item_destination   | 0x3 * victory_type == 0xA  | coord | Coordonate to transport item to       |
| defeat_type        | 0x1                        | int   | 0xff when none                        |
| defeat_hero_dies   | 0x3 * defeat_type == 0x0   | coord | Lose if this hero dies                |
| defeat_town_lost   | 0x3 * defeat_type == 0x1   | coord | Lose if this town is captured         |
| defeat_time_days   | 0x2 * defeat_type == 0x2   | int   | Lose after this many days             |

## Teams
| contents                  | size                         | type  | description (optional)                         |
|---------------------------|------------------------------|-------|------------------------------------------------|
| number_of_teams           | 0x1                          | int   | Number of teams on the map (< #players)        |
| red_in_team_number        | number_of_teams != 0x0       | int   |                                                |
| blue_in_team_number       | number_of_teams != 0x0       | int   |                                                |
| tan_in_team_number        | number_of_teams != 0x0       | int   |                                                |
| green_in_team_number      | number_of_teams != 0x0       | int   |                                                |
| orange_in_team_number     | number_of_teams != 0x0       | int   |                                                |
| purple_in_team_number     | number_of_teams != 0x0       | int   |                                                |
| teal_in_team_number       | number_of_teams != 0x0       | int   |                                                |
| pink_in_team_number       | number_of_teams != 0x0       | int   |                                                |

