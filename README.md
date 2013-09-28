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
| main_at_x               | 0x1 * has_main_town    | int   |                                |
| main_at_y               | 0x1 * has_main_town    | int   |                                |
| main_at_z               | 0x1 * has_main_town    | int   | underworld or not              |
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
| type_needed        | victory_type != 0xff       | int   | ID#artefacts,units                    |
| count_needed       | 0x4 * victory_type != 0xff | int   | #artefacts,units                      |

## Next
| contents                  | size     | type  | description (optional)                         |
|---------------------------|----------|-------|------------------------------------------------|
| next_starts               | 0x0      | bytes |                                                |
| unknown_0xff              | 0x1      | bytes | 0xff for simple maps                           |
| unknown_0x00              | 0x1      | bytes | 0x00 for simple maps                           |
| unknown_0xffs             | 0x9      | bytes | Multiple 0xffs for simple maps                 |
| unknown_next 0x100 bytes  | 0x100    | bytes | What's next?                                   |

