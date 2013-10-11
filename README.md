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
| level_cap               | map_version != 0xE  | int   | Armageddon and Shadow of death only         |

## Player
| contents            | size                                                  | type  | description (optional)         |
|---------------------|-------------------------------------------------------|-------|--------------------------------|
| player_start        | 0x0                                                   | bytes | offset of where the player is  |
| human_playable      | 0x1                                                   | bool  |                                |
| exists              | 0x1                                                   | bool  |                                |
| computer_behaviour  | 0x1                                                   | bytes |                                |
| unknown_shadow      | 0x1 * map_version == 0x1C                             | bytes | Shadow only                    |
| race_bits           | 0x1                                                   | int   | random hero if 255             |
| unknown#2           | 0x1 * map_version != 0xE                              | bytes |                                |
| unknown#3           | 0x1                                                   | bytes | 0xA0 on non-existant players   |
| has_main_town       | 0x1                                                   | bool  |                                |
| generate_hero       | 0x1 * map_version != 0xE * has_main_town * exists     | bytes | Arma and  Shadow of death only |
| main_town_type      | 0x1 * map_version != 0xE * has_main_town * exists     | int   |                                |
| main_town           | 0x3 * has_main_town                                   | coord | Coordinate of main town.       |
| unknown#4           | 0x1                                                   | bytes |                                |
| champion            | 0x1                                                   | int   | Is 0xff if there are no heroes |
| champion_exists     | 0x1 * champion != 0xFF * race_bits != 0xFF            | bool  | Exists if champion isn't 0xff  |
| champ_name_length   | 0x4 * champion_exists * race_bits != 0xFF             | int   |                                |
| champ_customname    | 0x1 * champ_name_length                               | str   |                                |
| champ_sha           | 0x1 * map_version != 0xE * exists                     | int   |                                |
| champ_exists_sha    | 0x1 * map_version != 0xE * champ_sha != 0xFF          | bool  |                                |
| unknown#5           | 0x4 * map_version != 0xE * race_bits != 0xFF * exists | bytes |                                |
| champ_arma_sha_len  | 0x4 * map_version != 0xE * race_bits != 0xFF          | int   |                                |
| champ_arma_sha_name | 0x1 * champ_arma_sha_len * champ_sha != 0xFF          | str   |                                |
| player_end          | 0x0                                                   | bytes | offset of where the player is  |

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
| unknown#1          | 0x1 * map_version != 0xE   | int   | 0xff when none                        |
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

