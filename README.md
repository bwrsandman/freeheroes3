# Freeheroes 3


Freeheroes 3 is a reimplementation of Heroes of Might and Magic 3.

The framework used is [LOVE2D](https://love2d.org/) for its simplicity and for the fact it is easily ported to mobile and web.


There is a python branch for implementation using pygame.


The aim of this project is to:


1. [ ] Read the map file formats for all three versions
1. [ ] Display the assets properly
1. [ ] Re-implement gameplay
1. [ ] Re-implement the editor
1. [ ] Improve upon the game


# H3M file format


This is a breakdown (work in progress) of the Heroes of Might and Magic 3 h3m map file format.


The official maps are compressed using gz compression, to have a look at the file contents, rename it to .gz and extract it, then use a hex editor like ghex.


The maps come with the game which you can get through GOG.


For the game to find these maps, edit conf.lua.


## General file structure (in order)

### Info
| contents                  | size                                                | type   | description (optional)                      |
|---------------------------|-----------------------------------------------------|--------|---------------------------------------------|
| map_version               | 0x4                                                 | int    | Restoration(14), Armageddon(21), Shadow(28) |
| map_playable              | 0x1                                                 | bool   |                                             |
| map_size                  | 0x4                                                 | int    | Maps are square, this is one side.          |
| has underground           | 0x1                                                 | bool   |                                             |
| title length              | 0x4                                                 | int    |                                             |
| title                     | title length                                        | str    |                                             |
| description length        | 0x4                                                 | int    |                                             |
| description               | description length                                  | str    |                                             |
| difficulty                | 0x1                                                 | int    |                                             |
| level_cap                 | map_version != 0xE                                  | int    | Armageddon and Shadow of death only         |
| players                   | 0x8                                                 | player |                                             |
| victory_condition_start   | 0x0                                                 | bytes  | ================ VICTORY ================== |
| victory_type              | 0x1                                                 | int    | 0xff when none                              |
| allow_normal_victory      | victory_type != 0xff                                | bool   | 1 when also allow normal victory            |
| victory_applies_to_pc     | victory_type != 0xff                                | bool   | victory condition also applies to PC        |
| item_to_acquire           | 0x1 * victory_type == 0x0                           | int    | Item reference, if artifact victory         |
| unknown_arma_sha0         | 0x1 * map_version != 0xE * victory_type == 0x0      | int    |                                             |
| creatures_type            | 0x1 * victory_type == 0x1                           | int    | Type of creature, if resource victory       |
| unknown_arma_sha1         | 0x1 * map_version != 0xE * victory_type == 0x1      | int    |                                             |
| creatures_needed          | 0x4 * victory_type == 0x1                           | int    | Num of creatures, if creature victory       |
| resources_type            | 0x1 * victory_type == 0x2                           | int    | Type of resource, if resource victory       |
| resources_needed          | 0x4 * victory_type == 0x2                           | int    | Num of resources, if resource victory       |
| town_to_upgrade           | 0x3 * victory_type == 0x3                           | coord  | Coordinates of the town to upgrade          |
| hall_upgrade              | 0x1 * victory_type == 0x3                           | int    | Hall level for, if upgrade victory          |
| castle_upgrade            | 0x1 * victory_type == 0x3                           | int    | Castle level for, if upgrade victory        |
| town_to_grail             | 0x3 * victory_type == 0x4                           | coord  | Coordinate of the town to grail             |
| hero_to_defeat            | 0x3 * victory_type == 0x5                           | coord  | Coordinate of the hero to defeat            |
| town_to_capture           | 0x3 * victory_type == 0x6                           | coord  | Coordinate of the town to capture           |
| monster_to_defeat         | 0x3 * victory_type == 0x7                           | coord  | Coordinate of monsters to defeat            |
| item_to_transport         | 0x1 * victory_type == 0xA                           | int    | Item reference, if transport victory        |
| item_destination          | 0x3 * victory_type == 0xA                           | coord  | Coordinate to transport item to             |
| defeat_type               | 0x1                                                 | int    | 0xff when none                              |
| defeat_hero_dies          | 0x3 * defeat_type == 0x0                            | coord  | Lose if this hero dies                      |
| defeat_town_lost          | 0x3 * defeat_type == 0x1                            | coord  | Lose if this town is captured               |
| defeat_time_days          | 0x2 * defeat_type == 0x2                            | int    | Lose after this many days                   |
| team_start                | 0x0                                                 | bytes  | ================= TEAMS =================== |
| number_of_teams           | 0x1                                                 | int    | Number of teams on the map (< #players)     |
| red_in_team_number        | number_of_teams != 0x0                              | int    |                                             |
| blue_in_team_number       | number_of_teams != 0x0                              | int    |                                             |
| tan_in_team_number        | number_of_teams != 0x0                              | int    |                                             |
| green_in_team_number      | number_of_teams != 0x0                              | int    |                                             |
| orange_in_team_number     | number_of_teams != 0x0                              | int    |                                             |
| purple_in_team_number     | number_of_teams != 0x0                              | int    |                                             |
| teal_in_team_number       | number_of_teams != 0x0                              | int    |                                             |
| pink_in_team_number       | number_of_teams != 0x0                              | int    |                                             |
| next_start                | 0x0                                                 | bytes  | =============UNKNOWN TERRITORY==============|
| available_heroes          | 0x10                                                | bytes  |                                             |
| available_heroes_arma_sha | 0x4 * map_version != 0xE                            | bytes  |                                             |
| unknown_arma_sha2         | 0x4 * map_version != 0xE                            | bytes  | What's next?                                |
| unknown_list_len          | 0x1 * map_version != 0xE                            | int    | What's next?                                |
| unknown_list              | 0x7 * unknown_list_len                              | bytes  | What's next?                                |
| unknown_arma_sha3         | 0x10 * map_version != 0xE                           | bytes  | What's next?                                |
| unknown_arma_sha4         | 0xF * unknown_list_len != 0                         | bytes  | What's next?                                |
| unknown0                  | 0x1F                                                | bytes  | What's next?                                |
| unknown_sha0              | 0xF * map_version == 0x1C * unknown_list_len == 0x0 | bytes  | Does not work with A Viking We Shall Go but not A Warm and Familiar Place |
| rumor_count               | 0x4                                                 | int    | How big is the list of rumours              |
| rumors                    | rumor_count                                         | rumor  |                                             |
| unknown_sha1              | 0xAB * map_version == 0x1C                          | bytes  | What's next?                                |
| unknown1                  | 0x10                                                | bytes  | What's next?                                |

### Player
| contents            | size                                                  | type  | description (optional)         |
|---------------------|-------------------------------------------------------|-------|--------------------------------|
| player_start        | 0x0                                                   | bytes | Offset of where the player is  |
| human_playable      | 0x1                                                   | bool  |                                |
| exists              | 0x1                                                   | bool  |                                |
| computer_behaviour  | 0x1                                                   | bytes |                                |
| custom_alignment    | 0x1 * map_version == 0x1C                             | bool  | Shadow only                    |
| race_bits           | 0x1                                                   | int   | Random hero if 0xFF            |
| unknown_arma_sha#1  | 0x1 * map_version != 0xE                              | bytes |                                |
| unknown#1           | 0x1                                                   | bytes |                                |
| has_main_town       | 0x1                                                   | bool  |                                |
| generate_hero       | 0x1 * map_version != 0xE * has_main_town * exists     | bool  | Arma and Shadow of death only  |
| main_town_type      | 0x1 * map_version != 0xE * has_main_town * exists     | int   |                                |
| main_town           | 0x3 * has_main_town                                   | coord | Coordinate of main town        |
| unknown#2           | 0x1                                                   | bytes |                                |
| champion            | 0x1                                                   | int   | Is 0xFF if there are no heroes |
| unknown#3           | 0x1 * champion != 0xFF                                | int   |                                |
| champ_name_length   | 0x4 * champion != 0xFF                                | int   |                                |
| champ_custom_name   | 0x1 * champ_name_length                               | bytes |                                |
| champ_sha           | 0x1 * map_version != 0xE                              | int   |                                |
| champ_count         | 0x1 * champ_sha != 0xFF * map_version != 0xE * exists | int   |                                |
| unknown_arma_sha#2  | 0x2 * map_version != 0xE                              | bytes |                                |
| unknown_arma_sha#3  | 0x2 * map_version != 0xE * champ_count == 0x0 * exists==0x0 | bytes |                          |
| champ_empty_list    | 0x1 * map_version != 0xE * champ_count == 0x0 * exists| bytes |                                |
| champ_nonempty_list | 0x1 * map_version != 0xE * champ_count != 0x0 * exists| bytes |                                |
| champ_name_list     | champ_count                                           | champ | Champion namelist (id, string) |
| player_end          | 0x0                                                   | bytes |                                |

### Champ
| contents       | size                     | type  | description (optional)    |
|----------------|--------------------------|-------|---------------------------|
| champ_id       | 0x1                      | int   | id number of champ        |
| champ_name_len | 0x1                      | int   |                           |
| champ_unknown  | 0x3                      | bytes |                           |
| champ_name     | 0x1 * champ_name_len     | str   |                           |

### Rumor
| contents    | size        | type  | description (optional)         |
|-------------|-------------|-------|--------------------------------|
| start       | 0x0         | bytes |                                |
| title_len   | 0x4         | int   | How long is the rumour content |
| title       | title_len   | str   |                                |
| content_len | 0x4         | int   | How long is the rumour content |
| content     | content_len | str   |                                |

## Custom types

### Champ
| contents       | size                     | type  | description (optional)    |
|----------------|--------------------------|-------|---------------------------|
| champ_id       | 0x1                      | int   | id number of champ        |
| champ_name_len | 0x1                      | int   |                           |
| champ_unknown  | 0x3                      | bytes |                           |
| champ_name     | 0x1 * champ_name_len     | str   |                           |

### Rumor
| contents    | size        | type  | description (optional)         |
|-------------|-------------|-------|--------------------------------|
| start       | 0x0         | bytes |                                |
| title_len   | 0x4         | int   | How long is the rumour content |
| title       | title_len   | str   |                                |
| content_len | 0x4         | int   | How long is the rumour content |
| content     | content_len | str   |                                |

